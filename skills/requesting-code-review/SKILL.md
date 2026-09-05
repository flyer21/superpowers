---
name: requesting-code-review
description: 在完成任务、实现重大特性或合并之前使用，以核实工作是否符合需求
---

# 请求代码评审（Requesting Code Review）

派发一个代码评审子代理，让问题在级联扩散之前就被抓住。评审者拿到的是为评估而精心构造的上下文——绝不是你的会话历史。

**核心原则：** 尽早评审，经常评审。

## 何时请求评审（When to Request Review）

**必须（Mandatory）：**
<!-- - 在 subagent-driven development 中完成每个任务之后 -->
<!-- - 完成重大特性之后 -->
- 合并到主分支之前

**可选但有价值（Optional but valuable）：**
- 卡住的时候（换个新鲜视角）
- 重构之前（基线检查）
- 修复复杂 bug 之后

## 如何请求（How to Request）

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
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
[刚完成 Task 2：添加验证函数]

你：在继续之前，我先请求一次代码评审。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[派发代码评审子代理]
  DESCRIPTION: 添加了 verifyIndex() 和 repairIndex()，覆盖 4 种问题类型
  PLAN_OR_REQUIREMENTS: docs/superpowers/plans/deployment-plan.md 中的 Task 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]：
  Strengths: 架构干净，测试真实
  Issues:
    Important: 缺少进度指示器
    Minor: 报告间隔的魔法数字（100）
  Assessment: 可以继续

你：[修复进度指示器]
[继续到 Task 3]
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
