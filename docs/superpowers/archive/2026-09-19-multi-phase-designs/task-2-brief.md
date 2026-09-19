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

