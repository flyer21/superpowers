# 多阶段设计改动 — 验证记录（GREEN）

日期：2026-09-19

## 结构断言

`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh` 完整输出：

PASS: brainstorming：两种分解
PASS: brainstorming：路线图小节
PASS: brainstorming：路线图路径
PASS: brainstorming：后续阶段回读
PASS: brainstorming：自审范围检查
PASS: writing-plans：每阶段一份计划
PASS: writing-plans：计划头部路线图字段
PASS: writing-plans：不横跨阶段
PASS: executing-plans：交接传递路线图
PASS: subagent-driven-development：交接传递路线图
PASS: finishing：路线图检测小节
PASS: finishing：状态更新在基分支
PASS: finishing：下一阶段提示
PASS: finishing：无路线图零变化
PASS: 一致性：5 个技能都提到路线图
PASS: 一致性：术语不漂移（无 Phase 大写混用为中文语境主词）
PASS: 一致性：前后端描述同一交接契约
PASS: finishing：全部完成时建议归档
ALL CHECKS PASS

## 逐项对照规格

- 规格第 1 节（路线图文档）：brainstorming 小节含必需小节清单与保存路径 → 任务 2 编辑 2b
- 规格第 2 节（brainstorming）：两种分解 / 路线图流程 / 后续阶段回读 / 自审加条 → 任务 2 编辑 2a-2c
- 规格第 3 节（writing-plans）：两种拆分 / 头部字段 → 任务 3 编辑 3a-3b
- 规格第 4 节（执行技能交接）：→ 任务 4 编辑 4a-4b
- 规格第 5 节（finishing 第 7 步）：零变化原则 / 基分支状态更新 / 下一阶段提示 → 任务 5 编辑 5a-5b；全部完成时建议归档 → 本次补充
- 规格第 6 节（改动清单）：5 个技能、小节级改动、无新脚本无新依赖 → 由整分支自审核实

## 令牌效率

对每个改动文件运行 `wc -w`，记录增量（brainstorming 与 subagent-driven-development 是大文件，增量应控制在净新增 400 词以内/文件）：

- skills/brainstorming/SKILL.md: 650 词（净新增 +42）
- skills/writing-plans/SKILL.md: 265 词（净新增 +4）
- skills/executing-plans/SKILL.md: 139 词（净新增 +3）
- skills/subagent-driven-development/SKILL.md: 1161 词（净新增 +1）
- skills/finishing-a-development-branch/SKILL.md: 568 词（净新增 +39）

## 后续工作（drill eval 债务）

本计划以静态断言 + 整分支自审作为验证；按 AGENTS.md 的技能改动要求，
以下压测场景仍需在 superpowers-evals（drill）上运行并记录前后对照：

- 场景 A（路线图自动产出）、B（阶段闭环）、C（单阶段无回归）——见 baseline.md
- 对抗性场景："我直接把阶段 2 一起设计了"应被 brainstorming 的阶段聚焦指引拒绝
- 完成前不得删除本节——这是显式记录的评估债务，不是待清理的杂物

## 基础设施测试说明

仓库 package.json 无 test 脚本；tests/ 下的测试均为 harness 专用
（claude-code / opencode / codex 等，需要对应环境）。本改动只触碰
skills/*.md 与 docs/，`git diff --stat` 应确认分支上没有任何
hooks/、scripts/、tests/ 文件改动——以此代替"跑基础设施测试"，
风险由整分支自审核实。

注意：`docs/superpowers/evals/` 路径会被 `.gitignore` 中无锚点的 `evals/` 规则匹配，新增的未追踪文件（如本记录）必须用 `git add -f` 提交——照抄计划中的 `git add docs/...` 命令会因 "paths are ignored" 失败。

## 补充修订（2026-09-19，分支 multi-phase-followups）

- 令牌效率：按搭档要求改为记录净新增词数（此前只记绝对值）。
- 规格第 5 节"建议归档"一句原先未落地，已在 finishing 第 7 步补齐（新增 1 条断言，见上）。
- 上述"注意"行的空行为格式修正。
