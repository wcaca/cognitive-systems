# 多 Writer 协调协议 · 顿悟 R 的升级

> 2026-07-03 · v0.8.15 框架升级
> 起源: 顿悟 Q (v0.8.14 + sas-graph v0.6.18) 暴露
> 关联: `cross-repo-sync.md` (v0.8.14)
> 核心命题: **多仓 sync = 多 writer, 协调协议必须显式**

## 顿悟 R 现象

v0.8.14 + v0.6.18 之后, 跨仓 sync 有 3 个潜在 writer:

| Writer | 触发 | 频率 | 写入 |
|---|---|---|---|
| 1. LLM session (root) | 用户推进时 | 不定 | insights/cross-repo-status.md |
| 2. CI workflow (cron) | 每 6h 或 push | 定时 | insights/cross-repo-status.md |
| 3. 仓内其他脚本 | 跨仓依赖变化 | 罕见 | cross-repo-status.md |

**问题**:
- 2 个 writer 同时跑 → git push 冲突 (last-write-wins, 之前 writer 的内容丢)
- CI workflow 跑 → push 失败 (因为本地的 commit 还没推)
- LLM session 跑 → CI workflow 后续也跑 → diff 看起来 stale

**没协调协议 = 隐式冲突 = 数据可能丢**.

## 升级: 多 Writer 协调协议 (v0.8.15)

### 协议 1: Lock 文件 (advisory lock)

```bash
LOCK_FILE="/tmp/cross-repo-status.lock"

# 取锁 (10 分钟超时)
if [[ -f "$LOCK_FILE" ]]; then
  lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE") ))
  if [[ $lock_age -gt 600 ]]; then
    echo "WARN: stale lock, removing"
    rm -f "$LOCK_FILE"
  else
    echo "SKIP: another writer holds lock"
    exit 0
  fi
fi
echo $$ > "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# ... 跑 cross-repo-status.sh ...

# 释放锁
rm -f "$LOCK_FILE"
```

**优点**: 简单, 不需要外部服务
**缺点**: 只在同一台机器生效; 跨机器 race 仍有

### 协议 2: Pull-then-push (single writer per仓)

```bash
# 在每个 writer 跑前先 pull, 跑完 push
git pull --rebase origin main
bash scripts/cross-repo-status.sh
git add insights/cross-repo-status.md
git commit -m "auto(cross-repo): refresh status"
git push

# 如果 push 失败 (race lost)
if [[ $? -ne 0 ]]; then
  echo "Race lost, re-pull and retry"
  git pull --rebase origin main
  bash scripts/cross-repo-status.sh
  git add insights/cross-repo-status.md
  git commit -m "auto(cross-repo): refresh status (retry after race)"
  git push
fi
```

**优点**: 跨机器协调 (git 本身就是分布式锁)
**缺点**: 多 retry 可能无限循环; 需要 exponential backoff

### 协议 3: Hash 内容 (skip if no change)

```bash
# 算生成内容的 hash
new_hash=$(bash scripts/cross-repo-status.sh | sha256sum | head -c 16)

# 跟上次 commit 的 hash 比
git log -1 --format=%s | grep -q "$new_hash"
if [[ $? -eq 0 ]]; then
  echo "No content change, skip push"
  exit 0
fi

# 否则 push
git add insights/cross-repo-status.md
git commit -m "auto(cross-repo): refresh status $new_hash"
git push
```

**优点**: 即使 race, 内容相同的 push 不冲突
**缺点**: hash 算法要稳定 (sha256)

### 协议 4: Owner 模式 (单仓 owner, 其他仓 read)

| 仓 | Owner | Read |
|---|---|---|
| cognitive-systems | ✅ 写 cross-repo-status | 创建-循环 cron 写 |
| sas-graph | ✅ 写 cross-repo-status | 创建-循环 cron 写 |
| creation-loop | ✅ 写 cross-repo-status | 创建-循环 cron 写 |
| agent-memory | ✅ 写 cross-repo-status + 视图 | LLM 写 |

**每个仓自己 owner 自己的视图, 跨仓视图不互相覆盖**.

**优点**: 没有跨仓 push 冲突
**缺点**: 每个仓都跑同一份脚本, 内容冗余但不冲突

### 协议 5: 视图分级 (own view vs global view)

```
仓内视图 (每个仓自己的 insights/cross-repo-status.md):
  - 4 仓的最新 commit
  - 跟本仓相关的元数据

全局视图 (cognitive-systems 仓独有的 insights/global-status.md):
  - 所有仓的最新 commit
  - 跨仓依赖关系
  - 协议版本
```

**优点**: 各仓只关心自己, 全局视图单独维护
**缺点**: 维护成本翻倍

## 推荐组合 (v0.8.15)

3 个协议组合使用:

```
Protocol 1 (lock) + Protocol 2 (pull-push) + Protocol 4 (own view per仓)
```

- Lock: 同机器避免 race
- Pull-push: 跨机器避免 race
- Own view per仓: 视图分仓, 不互相覆盖

## 实施 (本 commit 配套)

1. `80-meta/multi-writer-coordination.md` (本文)
2. 修改 `scripts/cross-repo-status.sh`:
   - 加 lock (协议 1)
   - 加 pull-push 模式 (协议 2)
   - 默认输出 own view per仓 (协议 4)
3. 加 `scripts/cross-repo-push.sh` (专用 push 脚本, 处理 race)

## 跟已有体系连接

- **v0.8.14 跨仓 sync**: 单 writer 假设
- **v0.8.15 多 writer 协调** (本文): 多 writer 现实
- **v0.8.13 CI enforcement**: 强制跑 = 多个 writer (cron + push trigger)
- **cron-as-system-mirror** (v0.2.1): cron 是 1 类 writer

## 4 个开放问题

1. **Cron race 怎么处理?** 多 cron 同时跑 + lock 文件 race
2. **Push 失败重试策略?** exponential backoff? max retry 几次?
3. **Owner 模式的视图一致性?** 各仓 own view 可能不一致 (e.g. cognitive-systems v0.8.14 vs sas-graph v0.6.18 时间差)
4. **LLM session 写仓 = 1 个 writer, 但有不同 prompt / 上下文 = 多个"虚拟 writer"?**

## 预测 v0.8.16 / v0.6.20

按递进认知链规律, v0.8.16 会暴露:
- **S 顿悟**: "跨仓 race 真正发生时 (不只是假设), 怎么恢复丢失的数据?"

## 链接

- 起源: 顿悟 Q (v0.8.14) - 暴露单 writer 假设
- 上承: `cross-repo-sync.md` (v0.8.14)
- 上承: `ci-enforcement.md` (v0.8.13) - CI = 多 writer 源
- 上承: `cron-as-system-mirror.md` (v0.2.1) - cron 是 writer 实例
- 预测: 顿悟 S = 跨仓 race 真实发生时的恢复协议

---

> 沉淀人: Mavis · 2026-07-03
> 月亮引力模式: 小波 (1 协议升级 + 5 协调协议) + 永续 (多 writer 协调在 CI + cron 中持续运转) + 单核心 (R 顿悟 = 多 writer 协调协议必须显式)