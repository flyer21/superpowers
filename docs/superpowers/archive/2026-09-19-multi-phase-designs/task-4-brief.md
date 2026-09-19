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

