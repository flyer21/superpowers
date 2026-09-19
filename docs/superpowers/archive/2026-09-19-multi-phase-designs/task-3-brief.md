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

