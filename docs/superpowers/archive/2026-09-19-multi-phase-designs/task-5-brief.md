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

