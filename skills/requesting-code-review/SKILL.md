---
name: requesting-code-review
description: 当完成任务、实施主要功能或在合并之前验证工作是否符合要求时使用
---

# 请求代码审查

派遣代码审查者子代理以在问题级联之前捕获它们。审查者获得精确构建的上下文进行评估——永远不是你的会话历史。

**核心原则：** 早期审查，经常审查。

## 何时请求审查

**强制：**
- 子代理驱动开发中每个任务之后
- 完成主要功能后
- 合并到 main 之前

**可选但有价值：**
- 卡住时（新鲜视角）
- 重构之前（基线检查）
- 修复复杂 bug 后

## 如何请求

**1. 获取 git SHAs：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或：git merge-base origin/main HEAD
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派遣代码审查者子代理：**

派遣一个 `general-purpose` 子代理，填写 [code-reviewer.md](code-reviewer.md) 的模板

**占位符：**
- `{DESCRIPTION}` - 你构建的内容简要摘要
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈行动：**
- 立即修复关键问题
- 在继续之前修复重要问题
- 记录次要问题供以后处理
- 如果审查者错了就反对（有推理）

## 示例

```
[刚完成任务 2：添加验证函数]

你：让我在继续之前请求代码审查。

BASE_SHA=$(git log --oneline | grep "任务 1" | head -1 | cut -d' ' -f1)
HEAD_SHA=$(git rev-parse HEAD)

[派遣代码审查者子代理]
  DESCRIPTION: 添加了 verifyIndex() 和 repairIndex()，包含 4 种问题类型
  PLAN_OR_REQUIREMENTS: 来自 docs/superpowers/plans/deployment-plan.md 的任务 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]：
  优点：干净的架构，真实的测试
  问题：
    重要：缺少进度指示器
    次要：报告间隔的魔术数字（100）
  评估：准备继续

你：[修复进度指示器]
[继续任务 3]
```

## 常见合理化

| 借口 | 现实 |
|------|------|
| "我就自己审查 diff 而不是派遣审查者" | 你是协调员——内联审查 diff 会烧掉你继续驱动工作所需的上下文窗口。派遣审查者子代理：diff 和评估生活在它的上下文中，只有发现返回给你。 |
| "审查者需要我的完整会话历史来理解更改" | 给它精确构建的上下文，永远不是你的会话历史。这让审查者关注工作产品，而不是你的思考过程。 |

## 危险信号

**永远不要：**
- 因为"很简单"而跳过审查
- 忽略关键问题
- 带着未修复的重要问题继续
- 与有效的技术反馈争论

**如果审查者错了：**
- 用技术推理反对
- 展示证明它工作的代码/测试
- 请求澄清

参见模板：[code-reviewer.md](code-reviewer.md)