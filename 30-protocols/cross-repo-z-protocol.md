# Cross-Repo Z Protocol · 跨仓 Z 协议

> [active] 2026-07-18 · v0.8.25 · Z 顿悟的跨仓扩展
>
> **Z 顿悟的局限**：v0.8.24 的 `scripts/z-enforce.sh` 只检 cognitive-systems 仓内部 `feat(20-systems|80-meta|10-frameworks|30-protocols)` + `fix(20-systems|80-meta)` commit。**但 5 仓飞轮里，其他 4 仓 (system-self / thoughtspace-notes / beauty-crm / agent-memory) 的 `feat` commit 同样产生元方法论信号**——这些信号被 cognitive-systems 仓的 evolution.md 漏接。
>
> **跨仓 Z 协议解决**：当其他仓 `feat(XX)` commit 体现 cognitive-systems 协议 (e.g. `feat(cobweb)` 实做 v25dt 时间轴 = 拓扑学 U 协议落地)，cognitive-systems 应自动在 `insights/cross-repo-evolution.md` 加段，记录"哪仓哪个 commit 触发了哪个协议落地"。
>
> 配套：[`evolution-sync-protocol.md`](./evolution-sync-protocol.md) · [`evolution-depth-protocol.md`](./evolution-depth-protocol.md) · `scripts/z-enforce.sh` (v0.8.24) · `scripts/cross-repo-evolution.sh` (v0.8.25)

---

## 1. 协议的核心理念

**Z 协议 v0.8.24 的盲点**：enforcement 只看 cognitive-systems 仓自身。但 cognitive-systems 的真正价值是 **"5 仓元方法论的总线"**——如果其他仓 commit 没被汇总到 cognitive-systems，bus 就断了。

**v0.8.25 跨仓 Z 协议强制 4 仓 → cognitive-systems 总线**：
- 触发器：4 仓任意 `feat(scope)` commit
- 检：commit 描述中是否引用 cognitive-systems 协议编号 (e.g. v25dt, v0.8.22, U 协议, Y 顿悟)
- 动作：在 `insights/cross-repo-evolution.md` 加段，记录"哪仓哪个 commit 触发了哪个协议"
- 跟 v0.8.24 内部 enforcement 互补：内部管 cognitive-systems 自身一致性，跨仓管总线完整性

---

## 2. WHEN — 什么时候必须触发跨仓 Z 协议

| 源仓 commit 类型 | 必须触发？ | 理由 |
|---|---|---|
| `feat(XX-systems)` (system-self) | ✅ 是 | 系统自反思 = 30-protocols/evolution-* 协议落地 |
| `feat(v2-s2)` (thoughtspace-notes) | ✅ 是 | 3D 拓扑实施 = 拓扑学 U 协议 |
| `feat(XX)` (beauty-crm) | ✅ 是 | 用户可见功能 = 7-15 协议 (可观测性) |
| `feat(notes)` (agent-memory) | ⚠ 视情况 | history 沉淀是 process meta, 不一定引协议 |
| `chore/auto/docs:` | ❌ 否 | 机械动作 |
| `fix(XX-systems)` | ⚠ 视情况 | bug 修可能暗含协议违例, 但默认不要求 |

**默认行为**：commit msg 含 "v0.8.X / X 顿悟 / Y 协议 / Z 协议 / U 协议 / 拓扑 / 镜子" 任一关键词 → 触发。

---

## 3. WHO — 谁来写跨仓 evolution 段

- **执行者**：`scripts/cross-repo-evolution.sh` (v0.8.25 新增, bash 实现, 0 依赖)
- **写入位置**：`insights/cross-repo-evolution.md` (新增, 跟 cross-repo-status.md 平行)
- **触发方式**：
  - 手动：`bash scripts/cross-repo-evolution.sh`
  - Cron：6h 一次（跟 cross-repo-status 同频）
  - CI：z-enforce.yml 加一个 job 调它
- **commit 策略**：脚本自动 commit 到 cognitive-systems 仓（auto(cross-repo) 协议，跟 cross-repo-status 一致）

---

## 4. HOW — 实施细节

### 4.1 抽取规则

```bash
# 4 仓最近 N=10 commit
for repo in system-self thoughtspace-notes beauty-crm agent-memory; do
  git log --oneline -n 10 --no-merges "$repo"
done

# 筛 feat(scope) 类型
grep -E "^feat\("

# 检 commit msg 引用关键词
grep -E "(v0\.8\.[0-9]+|顿悟|协议|拓扑|镜子|M[0-9])"
```

### 4.2 段格式

```markdown
## 2026-07-XX · system-self v25dt 时间轴 (U 协议落地)

| 项 | 值 |
|---|---|
| 源仓 | system-self |
| commit | `1b74103` |
| 触发协议 | 拓扑学 U 协议 (双窗口) |
| evolution 段 | `20-systems/agent-harness/evolution.md` v0.8.22 |
| 验证 | 公网时间轴 slider 双向 + 跨窗边高亮 |
```

### 4.3 z-enforce.sh v0.8.25 扩展

```bash
# v0.8.25 加: 检最近 N commit 中跨仓 commit 是否被 cross-repo-evolution.md 收
if [ "$N_COMMITS" -ge 10 ]; then
  # cron 模式累积性 enforcement
  python3 scripts/check_cross_repo_evolution.py || exit 1
fi
```

---

## 5. 验证清单

- [x] `scripts/cross-repo-evolution.sh` 跑 4 仓最近 10 commit, 抽 6+ 段
- [x] `insights/cross-repo-evolution.md` 生成 ≥ 5 段 (7-12 到 7-18 跨仓)
- [x] `scripts/z-enforce.sh` v0.8.25 加跨仓检分支, 不破 v0.8.24 行为
- [x] `20-systems/agent-harness/evolution.md` 加 v0.8.25 段 (5 维度 + 决策回顾 + 验证 + 同认知)

---

## 6. 跟既有协议关系

| 协议 | 关系 |
|---|---|
| evolution-sync-protocol.md (X) | X 强 commit 必补 evolution; 跨仓 Z 协议是其跨仓变体 |
| evolution-depth-protocol.md (Y) | Y 测深度; 跨仓 Z 协议要求每段 ≥ 100 字符 (跟 Y 对齐) |
| z-enforce.sh (Z v0.8.24) | 仓内 enforcement; v0.8.25 加跨仓 enforcement |
| cross-repo-status.sh | 元数据视图 (commit/version/date); 跨仓 Z 协议是 evolution 视图 |

---

沉淀人: Mavis · 凌晨 5 点长程推进 (2026-07-18)
