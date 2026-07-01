# Contributing · 贡献指南

## 怎么提一个 issue

- **讨论**：标题写 [discussion] xxx
- **错误**：标题写 [bug] xxx，附上原文引用
- **新方向**：标题写 [proposal] xxx，先聊聊再写文档

## 怎么提一个 PR

1. 先看 [`research-map.md`](../../00-essence/research-map.md) 确认这个内容在范围内
2. 小步提交：一个 PR 一个主题，别大杂烩
3. 命名：用连字符 `-`，别用下划线 `_`
4. 文件位置：参考 README 的目录结构

## 写作风格

- 中文为主，英文术语可夹用
- 第一稿可以粗糙，注明 `[draft]`
- 引用外部资料用链接，别抄
- 错的判断可以保留，但**必须标注 `~~删除线~~` 或 `[deprecated: 原因]`**

## 状态标签

每个文件可以在 frontmatter 或第一行加状态：
- `[seed]` — 刚种下的想法
- `[draft]` — 草稿
- `[active]` — 当前重点
- `[stable]` — 较成熟，少改动
- `[archived]` — 退役但保留

## 怎么归档

不要直接删除。移动到对应目录的 `_archive/` 子目录，或在文件头加 `[archived]` 标签。

## commit 规范

- 中文可以，但动词用英文：add / fix / refactor / drop / move
- 例：`add: agent-harness 维护维度 v0.1`、`fix: research-map 链接错误`

## 维护节奏

- 每周至少一次自我 review
- 路线图变更必须更新 README 的状态表
- 重大发现（推翻先前结论）单独写一篇 [`80-meta/`](../../80-meta/) 文档
