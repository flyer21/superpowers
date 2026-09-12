---
name: executing-plans
description: 当你有一份已写好的实施计划、需要在带审查检查点的独立会话中执行时使用
---

# 执行计划（Executing Plans）

## 概述（Overview）

加载计划、批判性地审查、执行全部任务、完成时汇报。

**开头就宣布：** "我正在用 executing-plans 技能来实现这份计划。"

**注意：** 告诉你的搭档，Superpowers 在能使用子代理时会好用得多（Claude Code、Codex CLI、Codex App、Copilot CLI 和 Gemini CLI 都符合条件；平台相关的工具参考见 `../using-superpowers/references/`）。如果子代理可用，就用 superpowers:subagent-driven-development 而不是本技能。

## 流程（The Process）

### 第 1 步：加载并审查计划（Load and Review Plan）
1. 确保有隔离的工作区：用 superpowers:using-git-worktrees 创建一个，或核实现有的那个
2. 阅读计划文件
3. 批判性地审查——识别对计划的任何疑问或顾虑
4. 如有顾虑：开工之前先向你的人类搭档提出
5. 如无顾虑：为计划条目创建 todos，然后继续

### 第 2 步：执行任务（Execute Tasks）

对每个任务：
1. 标记为进行中（in_progress）
2. 严格按每一步执行（计划里都是小步快跑式的步骤）
3. 按说明运行验证
4. 标记为已完成（completed）
5. 把计划文件中该任务各步骤的复选框勾成 `- [x]`（计划头部声明用复选框跟踪进度）

### 第 3 步：完成开发（Complete Development）

在所有任务完成并通过验证之后：
- 宣布："我正在用 finishing-a-development-branch 技能来完成这份工作。"
- **必需的子技能：** 使用 superpowers:finishing-a-development-branch
- 遵循该技能去验证测试、给出选项、执行选择

## 何时停下求助（When to Stop and Ask for Help）

**遇到以下情况立即停止执行（STOP）：**
- 撞上阻塞点（缺少依赖、测试失败、指令不清楚）
- 计划有关键缺口，导致无法开工
- 你不理解某条指令
- 验证反复失败

**宁可请求澄清，也不要瞎猜。**

## 何时回到前面的步骤（When to Revisit Earlier Steps）

**出现以下情况时回到审查（第 1 步）：**
- 搭档根据你的反馈更新了计划
- 根本方法需要重新思考

**不要硬闯阻塞点** ——停下来问。

## 记住（Remember）
- 先批判性地审查计划
- 严格遵循计划步骤
- 不要跳过验证
- 计划说引用技能时就引用
- 卡住就停下，不要瞎猜
- 未经用户明确同意，绝不在 main/master 分支上开始实现
