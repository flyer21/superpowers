### 任务 6：验证记录与跨技能一致性检查

**文件（Files）：**
- 新建（Create）：`docs/superpowers/evals/2026-09-19-multi-phase/verification.md`
- 测试（Test）：`docs/superpowers/evals/2026-09-19-multi-phase/check.sh`（追加跨技能一致性断言后运行完整脚本）

**接口（Interfaces）：**
- 消费（Consumes）：任务 2-5 产出的全部锚点字符串（"路线图（Roadmap）"、"顺序阶段"、"路线图检测（Roadmap Check）"、"finishing 的路线图检测以此为准"）
- 产出（Produces）：`verification.md`——GREEN 证据与后续 drill eval 的待办记录

- [ ] **第 1 步：追加跨技能一致性断言**

在 `check.sh` 的任务 5 断言之后追加：

```bash
# 任务 6（跨技能一致性）
check "一致性：5 个技能都提到路线图" bash -c 'for f in skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md skills/executing-plans/SKILL.md skills/subagent-driven-development/SKILL.md skills/finishing-a-development-branch/SKILL.md; do grep -q "路线图" "$f" || exit 1; done'
check "一致性：术语不漂移（无 Phase 大写混用为中文语境主词）" bash -c '! grep -rn "多阶段 Phase" skills/'
check "一致性：前后端描述同一交接契约" bash -c 'grep -q "路线图检测以此为准" skills/executing-plans/SKILL.md && grep -q "路线图检测以此为准" skills/subagent-driven-development/SKILL.md && grep -q "路线图检测（Roadmap Check）" skills/finishing-a-development-branch/SKILL.md'
```

- [ ] **第 2 步：编写验证记录**

创建 `docs/superpowers/evals/2026-09-19-multi-phase/verification.md`（内容中的 `<输出>` 由实际运行输出替换，其余照写）：

```markdown
# 多阶段设计改动 — 验证记录（GREEN）

日期：<执行日期>

## 结构断言

`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh` 完整输出：

<输出——必须以 ALL CHECKS PASS 结尾>

## 逐项对照规格

- 规格第 1 节（路线图文档）：brainstorming 小节含必需小节清单与保存路径 → 任务 2 编辑 2b
- 规格第 2 节（brainstorming）：两种分解 / 路线图流程 / 后续阶段回读 / 自审加条 → 任务 2 编辑 2a-2c
- 规格第 3 节（writing-plans）：两种拆分 / 头部字段 → 任务 3 编辑 3a-3b
- 规格第 4 节（执行技能交接）：→ 任务 4 编辑 4a-4b
- 规格第 5 节（finishing 第 7 步）：零变化原则 / 基分支状态更新 / 下一阶段提示 → 任务 5 编辑 5a-5b
- 规格第 6 节（改动清单）：5 个技能、小节级改动、无新脚本无新依赖 → 由整分支自审核实

## 令牌效率

对每个改动文件运行 `wc -w`，记录增量（brainstorming 与 subagent-driven-development 是大文件，增量应控制在净新增 400 词以内/文件）：

- skills/brainstorming/SKILL.md: <wc -w 输出>
- skills/writing-plans/SKILL.md: <wc -w 输出>
- skills/executing-plans/SKILL.md: <wc -w 输出>
- skills/subagent-driven-development/SKILL.md: <wc -w 输出>
- skills/finishing-a-development-branch/SKILL.md: <wc -w 输出>

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
```

- [ ] **第 3 步：运行完整脚本，确认全部通过**

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：`ALL CHECKS PASS`（含任务 6 的 3 条一致性断言）

- [ ] **第 4 步：提交**

```bash
git add docs/superpowers/evals/2026-09-19-multi-phase/
git commit -m "docs(eval): add multi-phase verification record and consistency checks"
```
