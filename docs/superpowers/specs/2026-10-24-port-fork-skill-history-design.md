# 移植 fork 技能历史（superpowers5 → 本项目）设计文档

日期：2026-10-24
状态：待审阅

## 问题

`/home/frf/superpowers5` 是 `flyer21/superpowers` 的克隆，与上游在 `b36e082`（v6.3.0）分叉，之后有 36 个本地提交：1 个全量中译提交、约 19 个功能改动、13 个版本号 bump 与 eval 记录。那些功能改动是在真实使用中长出来的：多阶段路线图、SDD 执行链的评审与归档改造、TDD 循环精简。

本项目 `/home/frf/superpowers` 停在**上游 v7.0.1 + 全量中译**，没有这些改动。目标是把 fork 的功能历史搬过来。

难点是基线错位：v6.4.x 重做了 SDD（新增 `references/` 子目录）与 writing-plans，v7.0.0 重写了 brainstorming。fork 的改动落在旧结构上，几乎无法 cherry-pick，只能按语义在新文件里重新实现。

## 目标

- 按 fork 的提交历史顺序，把 19 个功能改动逐个重新实现到本项目的中文技能上，保持每个改动原有的语义与措辞意图。
- 每个改动落点明确、可单独提交、可单独回退。
- 落完后 `skills/` 内部自洽：跨技能的契约（计划头部字段 → 执行交接语 → 收尾检测）必须闭合。

## 非目标

- 不引入新脚本、新技能、新依赖（与 fork 多阶段 spec 的非目标一致）。
- 不动 `package.json` 版本号、`RELEASE-NOTES.md`、fork 的 eval 记录与其 `docs/superpowers/specs|plans` 开发记录。
- 不改 `diagnosing-superpowers`（fork 未改动它）。
- 不追求与 fork 逐字一致：本项目是 v7 结构 + 既有中译文风，落点不同、措辞需适配。

## 反目标（什么会让它失败）

- **静默 cherry-pick**：v7 结构下 patch 会打歪或打空，看似落了实则没生效。
- **半套替换**：只改中文台账标记、不改 `resuming.md` / `fix-loop.md` 的模式匹配与测试断言，恢复协议会断。
- **契约断裂**：只改 brainstorming 写路线图、不改 finishing 消费它（或反过来），多阶段闭环仍然缺失。
- **覆盖式整文件替换**：v7.0.1 的文件里混有上游新增内容，整文件覆盖会连带删掉本仓库比 fork 更新的部分（典型：`scripts/sdd-workspace` 上游比 fork 更强）。

## 约束

- 文案全中文，与既有译文风格一致：直引号 `"`（fork 的 `1632e55` 专门修过弯引号）、术语统一为 路线图 / 阶段 / 台账 / 简报 / 自审。
- 只做小节级改动，不重构任何技能的整体结构（AGENTS.md 对行为塑造内容的门槛）。
- 路线图作为**新文档类型**引入，路径 `docs/superpowers/roadmaps/YYYY-MM-DD-<topic>-roadmap.md`；不新增 skills 下的配套文档。
- 改动若使 `tests/` 下的现有断言失效，必须同步更新断言——行为确实变了。

## 方法

考虑过三条路：

1. **按 commit 顺序逐个移植**（cherry-pick 语义补丁）——可追溯，但会在已被 v6.4/v7 重写的落点上做无用功，还可能把上游已推翻的做法塞回去。
2. **先审计再按文件实施**——先分类（上游已覆盖 / 可直接落 / 需改写 / 冲突放弃）再按文件一次成型。避免返工，但打散了历史顺序，回退粒度变粗。
3. **三方合并净差异**（base `b36e082`, ours v7.0.1, theirs fork main）——理论上最省事，实际不可行：两仓库都是中译本但译文不同，diff 噪声淹没语义增量。

**选定：按 fork 提交历史顺序逐个重新实现**（1 的顺序 + 2 的审计判断）。即：严格按 fork 的历史推进，每个提交先判定它在 v7.0.1 的落点状态，然后**重写**而非打补丁。已对每个提交完成落点审计，结论见下节。

## 变更清单（按 fork 历史顺序）

判定列含义：可直接落 / 需改写 / 上游已覆盖 / 无落点 / 冲突（需覆盖上游）。

| # | fork 提交 | 语义 | 本仓库落点 | 判定 |
|---|---|---|---|---|
| 1 | `b32beec` `ffcdbf6` | 评审时机反转：整体代码评审是**所有任务执行完成后的收尾关卡**，不是任务之间的例行步骤 | `skills/requesting-code-review/SKILL.md` frontmatter、核心原则、何时请求审查 | 需改写（与现有"每个任务之后"语义相反） |
| 2 | `23cc99a` | 逐任务评审 → 所有任务完成后一次统一评审，删掉每任务后的审查者派遣 | `skills/subagent-driven-development/SKILL.md` 流程与"审查任务"；`task-reviewer-prompt.md` | 冲突：v7 明确恢复逐任务审查 |
| 3 | `b72ad66` | 任务边界 = 承载自身完整测试周期、一次提交收尾；步骤粒度 5 步→4 步；交接语加"任务之间不审查" | `skills/writing-plans/SKILL.md` 任务大小调整、步骤粒度 | 需改写（现有为含"运行它以确保失败"的 5 步） |
| 4 | `917d61f` | 评审 → 控制器亲自读 diff 自审；实现者不再写报告文件，改 ≤12 行最终汇报；`sdd-workspace` 按计划分目录 | `skills/subagent-driven-development/SKILL.md` 派遣/处理报告；`implementer-prompt.md`；`re-review-prompt.md`；`references/final-review.md` | 冲突（报告文件是 v7 硬契约）／`sdd-workspace` 部分**上游已覆盖，跳过** |
| 5 | `3c52268` | 子代理协调：不要求子代理自审、不要求写总结；常见错误补"❌要总结" | `skills/dispatching-parallel-agents/SKILL.md` 代理提示词结构、常见错误 | 可直接落（package.json 版本号改动忽略） |
| 6 | `32c6781` | `task-brief` 支持中文任务标题（`任务`/`阶段` 标签、`：` 分隔符） | `skills/subagent-driven-development/scripts/task-brief` | 需改写（并入第 11 项的脚本替换，或单独落） |
| 7 | `dea3407` | 台账完成行改中文前缀 `任务 <ID>: 完成`；修复改为整分支**三轮修复波** | `skills/subagent-driven-development/SKILL.md` 设置/完成任务；`references/resuming.md`；`references/fix-loop.md` | 冲突：上游用英文 `Task <N>: complete` 作恢复协议、每任务 5 轮。决定全量替换（含测试断言） |
| 8 | `647f665` | 测试断言去 locale/timezone 依赖（C locale 下 GNU grep 把 `[：:]` 当字节集） | `tests/claude-code/test-helpers.sh`；`tests/codex`、`tests/hermes` 按实际存在情况 | 可直接落（与本仓库 skills 无关，属测试可移植性） |
| 9 | `e845218` | 任务完成即把计划文件该步骤 `- [ ]` 勾成 `- [x]` | `skills/executing-plans/SKILL.md` 完成任务；`skills/subagent-driven-development/SKILL.md` 完成任务 | 可直接落（语法上游已有，缺的是勾选动作） |
| 10 | `1eed178` | 简报/台账归档到计划旁 | — | 无落点（被第 12 项取代，跳过） |
| 11 | `6a4fc55` | `task-brief` 接受 phase-scoped 任务 id（`1` / `1.1` / `C1-1` / `A1`），阶段标题截断简报，歧义报错 | `skills/subagent-driven-development/scripts/task-brief`；`task-reviewer-prompt.md` | 需改写：脚本整体替换，但**必须保留本仓库 `${BASH:-bash}` 包装**（#2040 zipfile 丢执行位） |
| 12 | `534e7ae` | 归档到 per-plan 目录：`$ARCHIVE_DIR/<plan-slug>/ledger.md` + `task-<ID>-brief.md`，随计划文件提交 | `skills/subagent-driven-development/references/final-review.md`（删除工作区之前） | 需改写（上游终态是 `rm -rf`，无归档）；须遵守 per-plan 隔离 |
| 13 | `8ad56ce` | 先写完整测试**不运行**，运行集中在最后一步；全套测试提交前跑一次；实现者汇报加 TDD 证据 | `skills/test-driven-development/SKILL.md` 概述与红-绿-重构（含 dot 图）；`implementer-prompt.md`；`skills/systematic-debugging/SKILL.md` 第四阶段；`skills/writing-plans/SKILL.md`；`README.md` 对应描述 | 需改写（大改：TDD 循环改"精简 3 步"，dot 图替换）；`task-reviewer-prompt.md`、`verification-before-completion` 部分**上游已覆盖，跳过** |
| 14 | `0d4a386` | `writing-good-code.md` 全文 + TDD SKILL.md「好代码」段 | `skills/test-driven-development/writing-good-code.md`、`SKILL.md` | **已完成**（工作区已有未提交改动，与 fork 逐节一致，无遗漏） |
| 15 | `26edb3b` | brainstorming 范围评估区分**独立子系统** vs **顺序阶段**；新增"多阶段路线图"6 步流程与路线图必需小节 | `skills/brainstorming/SKILL.md` 评估工作规模（91-104）、书面设计（106-138） | 需改写：v7 已重写，无"规格自审"小节 → 自审那条范围检查并入书面设计 |
| 16 | `374d8a1` | writing-plans：每阶段一份计划，禁止跨阶段；计划头部新增可选字段 `**路线图（Roadmap）：** <路径>（阶段 N：<名称>）`，否则整行省略 | `skills/writing-plans/SKILL.md` 范围检查（19-21）、计划文档头部（47-73，插在"规格说明"之后） | 可直接落 |
| 17 | `894b097` | 执行侧转入收尾时带上"（路线图 <路径>，阶段 N：<名称>）"，作为收尾检测的唯一依据 | `skills/executing-plans/SKILL.md` 完成（152-158）；`skills/subagent-driven-development/SKILL.md` 最终审查（190-193）+ `references/final-review.md` | 可直接落（executing-plans 用 `## 完成`，不写"第 3 步"）；SDD 侧改动已移入 reference，需同步 |
| 18 | `5185a12` `1858856` | finishing 新增**第 7 步 路线图检测**：仅在收到路径时运行；基分支上标记本阶段"已完成"并提交；有未完成阶段则报告并等待（同意 → 调 brainstorming）；全部完成则建议归档 | `skills/finishing-a-development-branch/SKILL.md` 第 6 步之后（145-178 之后）；核心原则行 | 可直接落（保持"仅在调用方传递时运行"，**不加自动扫描逻辑**） |
| 19 | `1632e55` | 弯引号改回直引号，与计划原文逐字一致 | 无独立落点 | 写作纪律：插入文案一律直引号 |

## 冲突决定

两处与上游 v7.0.1 **硬冲突**，按"按历史重新实现"的指示，采用 fork 语义并覆盖上游：

1. **评审模型**（#2 #4 #7）：fork 是"所有任务完成后统一自审 + 三轮修复波"，上游是"每任务审查 + 报告文件 + 每任务 5 轮"。采用 fork。连带影响：`task-reviewer-prompt.md` 的定位、`references/handling-reports.md`、`references/fix-loop.md` 需整体改写为整分支模型；`tests/claude-code/test-subagent-driven-development*.sh` 的相关断言同步改。
2. **评审时机**（#1）：整体评审是执行完成后的收尾关卡。采用 fork，与上面的自审模型一致。

**不覆盖**的部分：`scripts/sdd-workspace` 用本仓库版本（上游强于 fork）；`verification-before-completion`、`task-reviewer-prompt.md` 中"不要重新运行套件"沿用上游。

**体积约束的处理（构建者提出）：** `skills/subagent-driven-development/SKILL.md` 现有 18.14 KB，而 `tests/skill-size/test-skill-size.sh` 的硬上限是 20000 字节（超过会被 Claude Code 压缩截断）。fork 的自审与修复波内容（约 8-10 KB）**不塞进 SKILL.md**，改写进两个现有 reference：`references/final-review.md`（现在是"派审查者做整分支审查"→ 整体改写为"控制器亲自读 diff"）、`references/fix-loop.md`（每任务 5 轮 → 整分支三轮修复波，保留断路器）。不新增文件，不动 `test-skill-size.sh`。

**测试的处理（构建者提出）：** 不移植 fork 的 `tests/claude-code/test-plan-checkbox-tracking.sh`（21 KB，依赖 fork 自己的目录布局）。改为在本仓库已有的 `tests/claude-code/test-executing-plans-scripts.sh` 与 SDD 相关测试里补勾选与标记断言。

## 已确认的决定

**A. 台账完成行：全量中文化（选 a）。**

`executing-plans/SKILL.md` 的完成行格式、`scripts/task-done` 写入的字符串、`tests/claude-code/test-executing-plans-scripts.sh:92,120,148` 的断言，与 SDD 侧一并改成中文 `任务 <N>: 完成 (commits <base7>..<head7>, tests: ...)`。理由：SDD 与 executing-plans 共享同一份工作区与账本（`skills/executing-plans/SKILL.md:80`，可中途互换执行者），留英文等于恢复协议半套。协议里不再保留英文写法——不双认。

**B. 审查配套文档：改写复用（选 b）。**

- `task-reviewer-prompt.md` → 改写为**控制器自审清单**（不再派遣审查者子代理）
- `re-review-prompt.md` → 改写为**复检清单**
- `references/cannot-verify.md` → 按 fork `SKILL.md:185` 语义改写：无法从 diff/计划确认的需求当作真实缺口进入修复波
- `references/handling-reports.md` → 相应改写；非 DONE 状态处理随评审模型一并调整

不新增文件；两个 prompt 文件仍被 SKILL.md 引用，不留死文件。

## 路线图文档格式

不复制 fork 的 spec/plan 开发记录到 `docs/`。路线图模板以"必需小节"清单形式写进 brainstorming SKILL.md（fork `26edb3b` 也是这么做的），必需小节：**目标**、**为何分阶段**、**阶段列表**（名称 / 一句话目标 / 依赖 / 验收标准 / 状态：待开始·设计中·执行中·已完成）、**被延后的设计决策**、**修订记录**。

## 验收

- 每个改动落完后用 grep 断言检查关键句是否到位（如 `grep -rn "路线图（Roadmap）" skills/`）。
- 多阶段闭环端到端自查：brainstorming 写路线图 → writing-plans 头部带字段 → executing-plans 交接语带字段 → finishing 第 7 步消费。四处字段名逐字一致。
- 冲突项落完后跑 `tests/claude-code/` 下 SDD 相关脚本，确认同步更新后的断言通过。

## 留给构建者

- 每个改动单独一个 commit，commit message 沿用 fork 的 `type(scope): subject` 风格并注明来源 sha。
- 落点行号以实施时实际文件为准（本表行号来自审计时快照）。
- 若某改动在 v7 结构中找不到合理落点，停下来报告，不要硬塞。
