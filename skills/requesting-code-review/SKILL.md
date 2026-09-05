---
name: requesting-code-review
description: 在实施计划中的所有任务执行完成之后、合并到主分支之前使用，以核实整体工作是否符合需求
---

# 请求代码评审（Requesting Code Review）

派发一个代码评审子代理，让问题在被合并进主分支、扩散成更大范围的问题之前就被抓住。评审者拿到的是为评估而精心构造的上下文——绝不是你的会话历史。

**核心原则：** 在所有任务执行完成之后才进入整体代码评审——它是交付前的收尾关卡，不是任务之间的例行步骤。

## 何时请求评审（When to Request Review）

**必须（Mandatory）——只有以下时机才进入本技能：**
- 实施计划（或整段工作）中的**所有任务都已执行完成**之后：对全部交付内容做一次整体评审
- 合并到主分支之前：作为合并前的最后一道确认

**不要（Never）在以下时机进入本技能：**
- 计划执行中途、刚完成个别任务时——单任务把关属于执行流程内部（例如 subagent-driven development 每个任务之后的规格/质量审查），不要打断执行去请求整体评审
- 卡住、重构前或修复复杂 bug 之后想找人看看时——先用相应技能解决眼前的问题，整体代码评审一律留到所有任务执行完成之后

## 如何请求（How to Request）

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git merge-base main HEAD)  # 整段工作的起始提交；简单场景可用 HEAD~1 或 origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派发代码评审子代理：**

派发一个 `general-purpose` 子代理，填入 [code-reviewer.md](code-reviewer.md) 中的模板。

**占位符：**
- `{DESCRIPTION}` - 简要说明你构建了什么
- `{PLAN_OR_REQUIREMENTS}` - 它应当做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动：**
- 立即修复严重（Critical）问题
- 在继续之前修复重要（Important）问题
- 把次要（Minor）问题记下来稍后处理
- 如果评审者错了就反驳（附上理由）

## 示例（Example）

```
[实施计划中的所有任务（Task 1-3）都已执行完成，工作已全部提交在分支上]

你：所有任务都完成了，现在进入整体代码评审。

BASE_SHA=$(git merge-base main HEAD)   # 这段工作的起始提交
HEAD_SHA=$(git rev-parse HEAD)

[派发代码评审子代理]
  DESCRIPTION: 按计划完成全部任务：添加了 verifyIndex() 和 repairIndex()，覆盖 4 种问题类型
  PLAN_OR_REQUIREMENTS: docs/superpowers/plans/deployment-plan.md（全部任务）
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]：
  Strengths: 架构干净，测试真实
  Issues:
    Important: 缺少进度指示器
    Minor: 报告间隔的魔法数字（100）
  Assessment: 需要修复（With fixes）

你：[修复进度指示器，重跑相关测试]
[对修复范围做一次限定范围复审，确认干净后] 进入合并，使用 superpowers:finishing-a-development-branch 收尾。
```

## 常见的自我合理化（Common Rationalizations）

| 借口（Excuse） | 现实（Reality） |
|--------|---------|
| "我自己内联看一下 diff 就行了，不用派评审者" | 你是协调者——内联看 diff 会烧掉你需要用来继续推进工作的上下文窗口。派一个评审子代理：diff 和评估都在它的上下文里，只有结论回到你这里。 |
| "评审者需要我的整个会话历史才能理解这次改动" | 交给它精心构造的上下文，绝不是你的会话历史。这样能让评审者专注于工作成果，而不是你的思考过程。 |

## 危险信号（Red Flags）

**绝不（Never）：**
- 因为"很简单"就跳过评审
- 无视严重（Critical）问题
- 带着未修复的重要（Important）问题继续
- 跟合理的技术反馈抬杠

**如果评审者错了：**
- 用技术理由反驳
- 用代码 / 测试证明它能工作
- 请求澄清

模板见：[code-reviewer.md](code-reviewer.md)
