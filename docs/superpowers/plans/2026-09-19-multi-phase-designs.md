# 多阶段设计（Multi-Phase Designs）实施计划

> **写给 agent 工作者：** 必需的子技能（REQUIRED SUB-SKILL）：使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 来逐任务实施本计划。步骤使用复选框（`- [ ]`）语法以便跟踪进度。

**目标（Goal）：** 当目标太大、一个设计无法承载时，Superpowers 工作流支持顺序阶段：路线图文档串联各阶段，每阶段走自己的 规格 → 计划 → 实施 循环，收尾后衔接下一阶段的设计。

**架构（Architecture）：** 路线图作为一种轻量新文档类型（`docs/superpowers/roadmaps/`），在 5 个现有技能中做小节级增量改动（方案 A，增量锚点式），不重构任何技能的整体结构。每个任务先追加 grep 断言（RED）→ 编辑技能文档 → 断言通过（GREEN）→ 提交。

**技术栈（Tech Stack）：** 纯 Markdown 技能文档；验证用 bash + grep 断言脚本。

**规格说明（Spec）：** `docs/superpowers/specs/2026-09-19-multi-phase-designs-design.md`——计划从规格说明出发进行论证，因此规格要随计划一起走；执行者两者都要读。

## 全局约束

- 不引入新脚本、新依赖或新技能
- 不重构任何技能的整体结构——所有改动都是小节级增量（AGENTS.md：未经 eval 证据不得重构精心调优内容）
- 不修改任何技能的 YAML `name`/`description` 前置元数据（本改动依赖既有触发路径，不改触发行为）
- 不修改 brainstorming 的 dot 流程图（文本是权威；改图属于结构重构，超出本规格范围）
- 术语统一：全文使用"路线图"（Roadmap）、"阶段"（Phase）、"顺序阶段"；路线图路径统一为 `docs/superpowers/roadmaps/`
- 既有内容的措辞、标点保持逐字不变——只做插入和明确的追加，不重写既有句子（核心原则行与两处交接句的追加除外，追加内容在任务中逐字给出）
- 每个任务以一次提交收尾；提交信息用英文（`feat:`/`docs:` 前缀，遵循仓库既有风格）
- 评估证据：静态断言（check.sh）随分支提交到 `docs/superpowers/evals/2026-09-19-multi-phase/`；基于 drill 的完整 eval（superpowers-evals）不在本计划内，作为后续工作记录在 verification.md

---

### 任务 1：基线记录与断言脚本（RED）

**文件（Files）：**
- 新建（Create）：`docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
- 新建（Create）：`docs/superpowers/evals/2026-09-19-multi-phase/baseline.md`

**接口（Interfaces）：**
- 消费（Consumes）：无
- 产出（Produces）：可执行的 `check.sh`（后续任务 2-5 各追加一个断言函数；用法 `bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`，全部断言通过时退出码 0 并打印 `ALL CHECKS PASS`）；`baseline.md` 记录改动前的失败证据

- [ ] **第 1 步：编写断言脚本**

创建 `docs/superpowers/evals/2026-09-19-multi-phase/check.sh`，内容如下（此时只有任务 1 的既有状态断言，后续任务各自追加）：

```bash
#!/usr/bin/env bash
# 多阶段设计改动的结构断言（RED→GREEN）
# 用法：bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh
cd "$(dirname "$0")/../../.." || exit 1
fail=0

check() { # check <名称> <命令...>
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS: $name"
  else
    echo "FAIL: $name"; fail=1
  fi
}

# 任务 1（基线）：改动前，5 个技能都没有"顺序阶段"支持——这些是记录基线用的反向断言
check "基线：brainstorming 无顺序阶段指引" bash -c '! grep -q "顺序阶段" skills/brainstorming/SKILL.md'
check "基线：writing-plans 无路线图字段" bash -c '! grep -q "路线图（Roadmap）" skills/writing-plans/SKILL.md'
check "基线：finishing 无路线图检测" bash -c '! grep -q "路线图检测" skills/finishing-a-development-branch/SKILL.md'

[ "$fail" -eq 0 ] && echo "ALL CHECKS PASS" || echo "CHECKS FAILED"
exit "$fail"
```

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：3 条基线反向断言全部 PASS、打印 `ALL CHECKS PASS`（证明改动前"顺序阶段"支持不存在——这就是 RED 证据的静态部分）

- [ ] **第 2 步：编写基线记录**

创建 `docs/superpowers/evals/2026-09-19-multi-phase/baseline.md`：

```markdown
# 多阶段设计改动 — 基线记录（RED）

日期：2026-09-19
规格：docs/superpowers/specs/2026-09-19-multi-phase-designs-design.md

## 基线证据（静态分析，非 LLM 实测）

以下断言在改动前全部成立（见 check.sh 的"基线"反向断言与运行记录）：

1. `skills/brainstorming/SKILL.md` 的范围评估只覆盖"相互独立的子系统"分解，
   没有"顺序阶段"概念——一个顺序阶段型大目标会被误拆为独立子项目，或塞进一份规格。
2. `skills/writing-plans/SKILL.md` 的范围检查与计划头部都没有路线图/阶段概念，
   无法区分"独立子系统拆多计划"与"顺序阶段每阶段一计划"。
3. `skills/executing-plans/SKILL.md`、`skills/subagent-driven-development/SKILL.md`
   进入收尾时不传递任何阶段上下文。
4. `skills/finishing-a-development-branch/SKILL.md` 收尾后直接结束，
   没有回到下一阶段设计的闭环。

## 压力场景（待 drill 实测）

- 场景 A（多阶段目标）：给出明确需要顺序阶段的大目标 → 期望产出路线图而非单一规格。
- 场景 B（阶段闭环）：阶段 1 收尾完成 → 期望自动提示进入阶段 2 头脑风暴。
- 场景 C（无回归）：普通单阶段目标（有界/架构级）→ 行为与现状一致。

## 评估状态

本仓库未配置 superpowers-evals（drill）本地环境。基于 LLM 判定的完整 eval
按 AGENTS.md 要求仍需在 drill 上补充运行（见 verification.md 的后续工作记录）；
本次改动的验证 = 本基线 + check.sh 结构断言 + 整分支自审。
```

- [ ] **第 3 步：运行脚本，确认基线成立**

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：`ALL CHECKS PASS`（3 条基线断言 PASS）

- [ ] **第 4 步：提交**

```bash
git add docs/superpowers/evals/2026-09-19-multi-phase/
git commit -m "docs(eval): add multi-phase baseline evidence and check script"
```

### 任务 2：brainstorming 支持顺序阶段与路线图

**文件（Files）：**
- 修改（Modify）：`skills/brainstorming/SKILL.md:124-125`（范围评估两种分解）、`:172`（自审范围检查）、新增"多阶段路线图"小节（插入在"理解想法"块之后、"探索方案"之前）
- 测试（Test）：`docs/superpowers/evals/2026-09-19-multi-phase/check.sh`（追加断言）

**接口（Interfaces）：**
- 消费（Consumes）：任务 1 的 `check.sh` 骨架（check 函数）
- 产出（Produces）：技能文本中的锚点字符串——"顺序阶段"、"多阶段路线图（Multi-phase roadmaps）"、`docs/superpowers/roadmaps/`、"整条路线图出现在一份规格"（任务 6 的一致性检查引用这些字符串）

- [ ] **第 1 步：追加断言（RED）**

在 `check.sh` 的任务 1 断言块之后追加（注意：先把任务 1 的三条"基线"反向断言整块删除——它们记录的是改动前状态，任务 2 落地后必然 FAIL，属于一次性基线证据，运行记录已留在 baseline.md）：

```bash
# 任务 2（brainstorming）：顺序阶段 + 路线图
check "brainstorming：两种分解" grep -q "后期阶段的设计依赖前期阶段" skills/brainstorming/SKILL.md
check "brainstorming：路线图小节" grep -q "多阶段路线图（Multi-phase roadmaps）" skills/brainstorming/SKILL.md
check "brainstorming：路线图路径" grep -q "docs/superpowers/roadmaps/YYYY-MM-DD-<topic>-roadmap.md" skills/brainstorming/SKILL.md
check "brainstorming：后续阶段回读" grep -q "必须先回读路线图" skills/brainstorming/SKILL.md
check "brainstorming：自审范围检查" grep -q "整条路线图出现在一份规格" skills/brainstorming/SKILL.md
```

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：5 条新断言 FAIL（RED）

- [ ] **第 2 步：编辑技能文档**

三处编辑，既有文字一律不动，只做替换段落中的原句保留 + 追加：

**编辑 2a** — 把 `skills/brainstorming/SKILL.md` 中这一行（第 125 行）：

```markdown
- 如果项目大到一份规格说明装不下，帮助用户把它分解成子项目：独立的组成部分有哪些、它们之间如何关联、应该按什么顺序构建？然后按正常设计流程对第一个子项目做头脑风暴。每个子项目都走自己的 规格 → 计划 → 实施 循环。
```

替换为：

```markdown
- 如果项目大到一份规格说明装不下，先判断是哪种"大"：
  - **独立子系统**——组成部分相互独立、可并行设计：帮助用户把它分解成子项目。独立的组成部分有哪些、它们之间如何关联、应该按什么顺序构建？然后按正常设计流程对第一个子项目做头脑风暴。每个子项目都走自己的 规格 → 计划 → 实施 循环。
  - **顺序阶段**——后期阶段的设计依赖前期阶段**建成并验证的结果**（判断信号：用户说"先……再基于……"、"MVP 之后看情况"，或阶段 N+1 的关键设计决策在阶段 N 建成前无法做出）：走"多阶段路线图"流程，见下文。两种情况可以混合——路线图中的阶段可标注"（含独立子系统，另行拆分）"。
```

**编辑 2b** — 在"理解想法"块的最后一个列表项（"- 聚焦于理解：目的、约束、成功标准"）与"**探索方案（Exploring approaches）：**"之间插入新小节：

```markdown
**多阶段路线图（Multi-phase roadmaps）：** 识别出顺序阶段后：

1. 一次一个问题，澄清：整体目标、阶段的自然边界（哪些能力必须先存在）、每阶段的验收标准
2. 在聊天中呈现路线图（按复杂度缩放），获得你的（人类）搭档批准
3. 把路线图写入 `docs/superpowers/roadmaps/YYYY-MM-DD-<topic>-roadmap.md` 并提交到 git——路线图只承载阶段边界，不承载设计细节
4. 然后仅对**阶段 1** 走正常的架构级流程；其规格头部注明"路线图：<路径>（阶段 1：<名称>）"
5. 阶段 N（N>1）的头脑风暴开始时，必须先回读路线图和阶段 1..N-1 的规格与建成成果；基于学习修订本阶段范围时，把修订记入路线图的"修订记录"小节，并更新受影响的后续阶段——修订导致阶段重排或废弃时，只标记状态变更，不删除历史行。被延后到本阶段的设计决策，现在正式进入设计
6. 发现路线图与实际进度不符（阶段状态未更新、文档与代码脱节）：停下来向你的（人类）搭档指出并确认真实状态——先修路线图，再继续

路线图的必需小节：**目标**（一段话）、**为何分阶段**（哪些设计决策被延后）、**阶段列表**（每阶段：名称 / 一句话目标 / 依赖的前序阶段 / 验收标准 / 状态——待开始、设计中、执行中、已完成）、**被延后的设计决策**、**修订记录**。
```

**编辑 2c** — 把规格自审中这一条（第 172 行）：

```markdown
3. **范围检查：** 是否足够聚焦到能放进一份实施计划？还是需要再分解？
```

替换为：

```markdown
3. **范围检查：** 是否足够聚焦到能放进一份实施计划？还是需要再分解？如果本规格属于某个路线图的阶段，检查的是本阶段——整条路线图出现在一份规格里，就是需要回到路线图再分解的信号。
```

- [ ] **第 3 步：运行断言，确认通过**

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：`ALL CHECKS PASS`

- [ ] **第 4 步：提交**

```bash
git add skills/brainstorming/SKILL.md docs/superpowers/evals/2026-09-19-multi-phase/check.sh
git commit -m "feat(brainstorming): support sequential phases with roadmap documents"
```

### 任务 3：writing-plans 区分两种拆分并加路线图字段

**文件（Files）：**
- 修改（Modify）：`skills/writing-plans/SKILL.md:23`（范围检查）、计划文档头部模板（`**规格说明（Spec）：**` 行之后）
- 测试（Test）：`docs/superpowers/evals/2026-09-19-multi-phase/check.sh`

**接口（Interfaces）：**
- 消费（Consumes）：任务 1 的 `check.sh` 骨架
- 产出（Produces）：计划头部字段 `**路线图（Roadmap）：**`（任务 4、5 的技能引用它；执行者据它判断计划所属阶段）

- [ ] **第 1 步：追加断言（RED）**

在 `check.sh` 的任务 2 断言之后追加：

```bash
# 任务 3（writing-plans）：两种拆分 + 计划头部路线图字段
check "writing-plans：每阶段一份计划" grep -q "每个阶段一份计划" skills/writing-plans/SKILL.md
check "writing-plans：计划头部路线图字段" grep -q '路线图（Roadmap）：' skills/writing-plans/SKILL.md
check "writing-plans：不横跨阶段" grep -q "绝不允许一份计划横跨多个阶段" skills/writing-plans/SKILL.md
```

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：3 条新断言 FAIL（RED）

- [ ] **第 2 步：编辑技能文档**

**编辑 3a** — 把范围检查这一段（第 23 行）：

```markdown
如果规格说明涵盖多个相互独立的子系统，那么它在头脑风暴阶段本应已被拆成子项目规格说明。如果没有，建议把它拆成多个独立计划——每个子系统一份。每份计划都应能独立产出可运行、可测试的软件。
```

替换为：

```markdown
如果规格说明涵盖多个相互独立的子系统，那么它在头脑风暴阶段本应已被拆成子项目规格说明。如果没有，建议把它拆成多个独立计划——每个子系统一份。每份计划都应能独立产出可运行、可测试的软件。

如果规格来自一份多阶段路线图，那么**每个阶段一份计划**——绝不允许一份计划横跨多个阶段；阶段间的衔接是路线图的职责，不是计划的职责。计划头部必须注明所属路线图与阶段（见下方"计划文档头部"）。
```

**编辑 3b** — 在计划文档头部模板中，把这一行：

```markdown
**规格说明（Spec）：** [本计划所依据的规格/设计文档的路径——计划从规格说明出发进行论证，因此规格要随计划一起走；执行者两者都要读]
```

替换为：

```markdown
**规格说明（Spec）：** [本计划所依据的规格/设计文档的路径——计划从规格说明出发进行论证，因此规格要随计划一起走；执行者两者都要读]

**路线图（Roadmap）：** [仅当规格来自路线图时填写：<路线图路径>（阶段 N：<阶段名称>）；否则整行省略——不写"无"。收尾技能据此衔接下一阶段]
```

- [ ] **第 3 步：运行断言，确认通过**

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：`ALL CHECKS PASS`

- [ ] **第 4 步：提交**

```bash
git add skills/writing-plans/SKILL.md docs/superpowers/evals/2026-09-19-multi-phase/check.sh
git commit -m "feat(writing-plans): distinguish phase plans and add roadmap header field"
```

### 任务 4：执行技能向收尾传递阶段上下文

**文件（Files）：**
- 修改（Modify）：`skills/executing-plans/SKILL.md:34-39`（第 3 步"完成开发"的宣布语）、`skills/subagent-driven-development/SKILL.md:250`（"收尾"小节末行）
- 测试（Test）：`docs/superpowers/evals/2026-09-19-multi-phase/check.sh`

**接口（Interfaces）：**
- 消费（Consumes）：任务 3 的计划头部字段 `**路线图（Roadmap）：**`
- 产出（Produces）：两处交接语中的字符串"finishing 的路线图检测以此为准"（任务 5 的 finishing 技能是这些交接的接收方）

- [ ] **第 1 步：追加断言（RED）**

在 `check.sh` 的任务 3 断言之后追加：

```bash
# 任务 4（执行技能）：向收尾传递阶段上下文
check "executing-plans：交接传递路线图" grep -q "finishing 的路线图检测以此为准" skills/executing-plans/SKILL.md
check "subagent-driven-development：交接传递路线图" grep -q "finishing 的路线图检测以此为准" skills/subagent-driven-development/SKILL.md
```

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：2 条新断言 FAIL（RED）

- [ ] **第 2 步：编辑技能文档**

**编辑 4a** — 在 `skills/executing-plans/SKILL.md` 第 3 步中，把这两行：

```markdown
在所有任务完成并通过验证之后：
- 宣布："我正在用 finishing-a-development-branch 技能来完成这份工作。"
```

替换为：

```markdown
在所有任务完成并通过验证之后：
- 宣布："我正在用 finishing-a-development-branch 技能来完成这份工作。"如果计划头部声明了路线图（Roadmap）字段，宣布时带上"（路线图 <路径>，阶段 N：<名称>）"——finishing 的路线图检测以此为准
```

**编辑 4b** — 在 `skills/subagent-driven-development/SKILL.md` 的"收尾（Finish）"小节中，把这一行（第 250 行）：

```markdown
使用 superpowers:finishing-a-development-branch。
```

替换为：

```markdown
使用 superpowers:finishing-a-development-branch。计划头部声明了路线图（Roadmap）字段时，转入时带上路线图路径与阶段号——finishing 的路线图检测以此为准。
```

- [ ] **第 3 步：运行断言，确认通过**

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：`ALL CHECKS PASS`

- [ ] **第 4 步：提交**

```bash
git add skills/executing-plans/SKILL.md skills/subagent-driven-development/SKILL.md docs/superpowers/evals/2026-09-19-multi-phase/check.sh
git commit -m "feat(execution): pass roadmap context to finishing skill"
```

### 任务 5：finishing 新增路线图检测步骤

**文件（Files）：**
- 修改（Modify）：`skills/finishing-a-development-branch/SKILL.md:10`（核心原则行追加）、第 6 步之后新增第 7 步（插入在"## 快速参考（Quick Reference）"之前）
- 测试（Test）：`docs/superpowers/evals/2026-09-19-multi-phase/check.sh`

**接口（Interfaces）：**
- 消费（Consumes）：任务 4 的交接字符串（路线图路径 + 阶段号）；路线图文档的"阶段列表 / 状态 / 修订记录"小节（由 brainstorming 技能产出）
- 产出（Produces）：技能中的"路线图检测（Roadmap Check）"小节——闭环的终点：同意后调用 brainstorming 开始下一阶段

- [ ] **第 1 步：追加断言（RED）**

在 `check.sh` 的任务 4 断言之后追加：

```bash
# 任务 5（finishing）：第 7 步路线图检测
check "finishing：路线图检测小节" grep -q "路线图检测（Roadmap Check）" skills/finishing-a-development-branch/SKILL.md
check "finishing：状态更新在基分支" grep -q "在基分支上把本阶段标记为" skills/finishing-a-development-branch/SKILL.md
check "finishing：下一阶段提示" grep -q "要现在开始它的头脑风暴吗" skills/finishing-a-development-branch/SKILL.md
check "finishing：无路线图零变化" grep -q "没有路线图信息时" skills/finishing-a-development-branch/SKILL.md
```

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：4 条新断言 FAIL（RED）

- [ ] **第 2 步：编辑技能文档**

**编辑 5a** — 把核心原则行（第 10 行）：

```markdown
**核心原则：** 验证测试 → 检测环境 → 给出选项 → 执行选择 → 清理。
```

替换为：

```markdown
**核心原则：** 验证测试 → 检测环境 → 给出选项 → 执行选择 → 清理 →（仅当有路线图）衔接下一阶段。
```

**编辑 5b** — 在"## 快速参考（Quick Reference）"之前插入新小节（第 6 步"清理工作区"小节之后）：

```markdown
## 第 7 步：路线图检测（Roadmap Check）

**只在调用方传递了路线图路径与阶段号时运行**——它们来自计划头部的"路线图（Roadmap）"字段，经 executing-plans / subagent-driven-development 的交接语传递。没有路线图信息时，本技能在第 6 步之后结束，行为与没有这一步完全一致；此时若你注意到 `docs/superpowers/roadmaps/` 下存在未完成路线图，可以问一句"本次工作是否属于某个阶段？"——由你的（人类）搭档确认，不要自行猜测。

有路线图时：

1. 在基分支上把本阶段标记为"已完成"并提交（路线图随阶段 1 的分支合入基分支，本步骤不依赖已清理的工作区）
2. 检查路线图中是否还有未完成阶段：
   - **有**——报告并等待搭档决定，不自动开工：

     > 路线图 `<path>` 中还有未完成阶段。下一阶段是"<阶段 N+1 名称>"。要现在开始它的头脑风暴吗？

     搭档同意 → 调用 brainstorming 技能开始下一阶段（它会先回读路线图与前期阶段成果）；拒绝 → 结束
   - **没有**——报告路线图全部完成，结束
```

- [ ] **第 3 步：运行断言，确认通过**

运行：`bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh`
预期：`ALL CHECKS PASS`

- [ ] **第 4 步：提交**

```bash
git add skills/finishing-a-development-branch/SKILL.md docs/superpowers/evals/2026-09-19-multi-phase/check.sh
git commit -m "feat(finishing): add roadmap check step to close the phase loop"
```

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
