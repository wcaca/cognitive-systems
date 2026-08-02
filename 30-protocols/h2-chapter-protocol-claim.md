# H2 Chapter Protocol Claim Protocol · H2 章节协议归属协议

> [draft] 2026-08-02 · v0.8.29 · 调研结论 (不实做)

## 1. 调研背景 (Why this protocol exists)

**v0.8.28 H2 章节扫描调研结论**:
- 30-protocols/*.md H2 章节大量是协议元描述 (e.g. "协议的核心理念" / "已知局限" / "实施步骤" / "验证清单"),不是协议名
- 即使加 3 层过滤 (em-dash / 日期 / meta 关键词), 仍有 1-3 个误判漏网
- 8-1 决策: H2 扫描留 v0.8.29+ 调研 frontmatter 显式声明 或 "X 子协议" 命名约定

**8-2 调研三种方案**:

| 方案 | 描述 | 准确度 | 维护成本 | 推荐度 |
|---|---|---|---|---|
| A. frontmatter `protocol_h2:` | 协议文件 YAML 头加 `protocol_h2: [...]` 数组, 扫 H2 时严格匹配 | 高 | 8 协议全要加 frontmatter, 加新协议要记加 | ⭐⭐⭐ (稳但重) |
| B. "X 子协议" 命名约定 | H2 章节标题包含"X 协议" / "X 子协议" 才识别, 配合排除词表 | 中 | 写协议时按约定即可, 排除词表需维护 | ⭐⭐ (轻但仍误判) |
| C. frontmatter + 距离约束 | 协议文件 frontmatter 声明协议名白名单, H2 章节跟 frontmatter 协议名距离 ≤ N 字 | 高 | 同 A, 但鲁棒: 章节名 "X 协议协同 Y 协议" 也算 | ⭐⭐⭐ (最稳) |

## 2. 推荐: 方案 C frontmatter + 距离约束

**核心思路**:
```yaml
---
protocol_names: ["跨仓 Z 协议", "Cross-Repo Z Protocol", "Z 协议"]
protocol_h2_match_distance: 30  # H2 章节名跟 protocol_names 任何一项编辑距离 ≤ 30 算关联
---
```

**优势**:
- 协议名由 frontmatter 显式声明, 跟 v0.8.27 多语言协议自发现 (AB 顿悟) 一致: 协议名 SSOT 在 frontmatter, 不靠 H2 章节扫描反推
- 距离约束允许 "X 协议落地" / "X 协议协同" / "X 协议限制" 等合法章节名, 但拒绝 "协议的核心理念" (距离太远)
- 兼容现有 8 个协议文件, 只需在每个文件顶部加 frontmatter 段 (8 个文件机械动作)

**劣势**:
- 8 协议文件都要改 (一次性成本)
- 新协议创建时作者必须记加 frontmatter (留 v0.8.30+ 跟"协议自发现"机制联动: 扫到新 H1 协议名时自动补 frontmatter)

## 3. 决策 (8-2 锁定)

**v0.8.29 = 调研 + 文档化, 不实做**:
- 本协议 (本文档) 沉淀 3 方案对比 + 方案 C 详细设计
- 不动 `scripts/protocol-disambiguation.sh` (避免 v0.8.28 已 stable 的 export 子命令被新逻辑污染)
- 不加 frontmatter (8 文件, 等 v0.8.30 一次性 commit)
- 留 v0.8.30+ 实做 2 件事:
  - 8 协议文件加 `protocol_names` + `protocol_h2_match_distance` frontmatter
  - `protocol-disambiguation.sh` 加 `scan_h2` 子命令 (跟 `export` 同级), 读 frontmatter + 距离约束过滤 + 写 `.protocol-h2-claims.txt`

**为什么 v0.8.29 不实做**:
- 调研完但实际工作量需要: 8 文件 frontmatter + 新子命令 + 测试 + pre-commit 集成, 单 sprint 30 分钟不够 (经验: v0.8.28 用了 ~15min, v0.8.29 调研+框架 ~20min 预算)
- v0.8.28 export 子命令已稳定, 不应该 sprint 中间换方案 (8-1 教训: "verifier-worthy 验证" 优先)
- v0.8.30 实做时, 调研文档已就位, 实施可以 1 sprint 闭环

## 4. 实施路径 (留 v0.8.30+)

**v0.8.30 任务**:
1. 8 协议文件加 frontmatter (3-5 行每文件, 1 文件 1 commit, 不混):
   - `cross-repo-z-protocol.md`: `protocol_names: ["跨仓 Z 协议", "Cross-Repo Z Protocol", "Z 协议"]`
   - `evolution-depth-protocol.md`: `protocol_names: ["Evolution 深度协议", "Evolution Depth Protocol", "Y 协议"]`
   - `evolution-sync-protocol.md`: `protocol_names: ["Evolution-Sync Protocol", "元方法论同步协议"]`
   - `export-protocol-names.md`: `protocol_names: ["Export Protocol Names Protocol", "协议白名单导出协议", "AC 协议"]`
   - `fill-order-coordination.md`: `protocol_names: ["Fill-Order Coordination Protocol", "填实顺序协调协议"]`
   - `insight-extraction-protocol.md`: `protocol_names: ["Insight Extraction Protocol", "顿悟提取协议"]`
   - `multilingual-protocol-self-discovery.md`: `protocol_names: ["Multilingual Protocol Self-Discovery Protocol", "多语言协议自发现协议", "AB 协议"]`
   - `protocol-disambiguation.md`: `protocol_names: ["Protocol Disambiguation Protocol", "协议 vs 形容词去歧协议", "AA 协议"]`
2. `scripts/protocol-disambiguation.sh` 加 `scan_h2` 子命令 (跟 `export` 同级):
   - 读 8 文件 frontmatter `protocol_names` + `protocol_h2_match_distance` (默认 30)
   - 扫 H2 章节 (`grep "^## "`)
   - 计算 H2 章节名跟 frontmatter `protocol_names` 任何一项的编辑距离 (bash 4 字符级别, 或 spawn python 调 `python-Levenshtein`)
   - 距离 ≤ 阈值 → 写入 `.protocol-h2-claims.txt` (`# 协议名 → H2 章节列表`)
3. 加 `tests/v0.8.30-h2-claim.test.sh` 验证:
   - 8 协议文件 frontmatter 格式正确
   - `scan_h2` 输出包含 "协议的核心理念" 跟 frontmatter 距离 > 30 (应拒绝)
   - `scan_h2` 输出包含 "X 协议落地" 跟 frontmatter 距离 ≤ 30 (应接受)
4. pre-commit hook 集成 (跟 v0.8.28 export 联动):
   - `pre-commit` 跑 `bash scripts/protocol-disambiguation.sh scan_h2` → 写 `.protocol-h2-claims.txt`
   - 跟 `.protocol-names.txt` 一样 git ignored, 运行时生成

## 5. 风险 & 已知未知

**风险**:
- 8 协议文件加 frontmatter 时, 已有 H1 (e.g. `# Cross-Repo Z Protocol · 跨仓 Z 协议`) 跟 frontmatter `protocol_names` 有重叠 (短名 vs 全名), 需要前端 edit 工具人 (Mavis) 决定 SSOT: frontmatter 是 SSOT, H1 是 display
- bash 字符级编辑距离实现不准 (中文 UTF-8 字符 vs 拉丁字符按字节算 vs 按字符算), 推荐 spawn python `python3 -c "import Levenshtein; print(Levenshtein.distance('a', 'b'))"` 调外部 lib
- v0.8.27 多语言协议自发现 (AB 顿悟) 跟 frontmatter 协议名可能冲突: `scan_protocols` 输出 A, frontmatter 输出 B, 需要 SSOT 决定

**未知**:
- 编辑距离阈值 30 怎么定? 8-2 没实测, 留 v0.8.30 实做时跑 8 文件 H2 全量, 看距离分布
- 协议 H2 章节是协议"使用"还是协议"定义"? 区分: 协议"使用"章节 (e.g. "实施步骤") 应该跟"使用"白名单匹配, 协议"定义"章节 (e.g. "协议的核心理念") 应该跟"定义"白名单匹配. 留 v0.8.31+ 二维分类

## 6. 关联协议

- [`multilingual-protocol-self-discovery.md`](./multilingual-protocol-self-discovery.md) · v0.8.27 协议自发现 (AB 顿悟) — `protocol_names` SSOT 思路源头
- [`protocol-disambiguation.md`](./protocol-disambiguation.md) · v0.8.26 协议去歧 (AA 顿悟) — 协议名跟形容词的区分基础
- [`export-protocol-names.md`](./export-protocol-names.md) · v0.8.28 协议白名单导出 (AC 顿悟) — 本协议依赖的 export 子命令
- 配套脚本: `scripts/protocol-disambiguation.sh` (v0.8.28 export 已实做, v0.8.30+ 加 scan_h2)
