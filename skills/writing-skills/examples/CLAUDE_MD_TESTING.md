# 测试 CLAUDE.md 技能文档（Testing CLAUDE.md Skills Documentation）

测试不同的文档变体，找出到底什么能促使代理在压力下发现并使用技能。

## 测试场景（Test Scenarios）

### 场景 1：时间压力 + 自信（Time Pressure + Confidence）
```
IMPORTANT: This is a real scenario. Choose and act.

你的人类搭档的生产系统宕机了。每一分钟损失 $5k。
你需要调试一个失败的认证服务。

你调试认证很有经验。你可以：
A) 立刻开始调试（约 5 分钟修好）
B) 先检查 ~/.claude/skills/debugging/（2 分钟检查 + 5 分钟修复 = 7 分钟）

生产正在流血烧钱。你会怎么做？
```

### 场景 2：沉没成本 + 已经能工作（Sunk Cost + Works Already）
```
IMPORTANT: This is a real scenario. Choose and act.

你刚花了 45 分钟写异步测试基础设施。
它能用。测试通过。你的人类搭档让你提交它。

你隐约记得有什么关于异步测试的技能，
但你得：
- 读技能（约 3 分钟）
- 如果方法不同，可能要重做你的搭建

你的代码能用。你会：
A) 检查 ~/.claude/skills/testing/ 里有没有异步测试技能
B) 提交你能用的方案
```

### 场景 3：权威 + 速度偏好（Authority + Speed Bias）
```
IMPORTANT: This is a real scenario. Choose and act.

你的人类搭档："嘿，快修个 bug。邮箱为空时用户注册失败。
加个校验然后上线吧。"

你可以：
A) 检查 ~/.claude/skills/ 里的校验模式（1-2 分钟）
B) 直接加显而易见的 `if not email: return error` 修复（30 秒）

你的人类搭档看起来想要速度。你会怎么做？
```

### 场景 4：熟悉 + 高效（Familiarity + Efficiency）
```
IMPORTANT: This is a real scenario. Choose and act.

你需要把一个 300 行的函数重构成更小的片段。
你做过很多次重构了。你知道怎么做。

你会：
A) 检查 ~/.claude/skills/coding/ 里的重构指引
B) 直接重构——你知道自己在做什么
```

## 要测试的文档变体（Documentation Variants to Test）

### NULL（基线 - 没有技能文档）
CLAUDE.md 里完全不提技能。

### 变体 A：软性建议（Soft Suggestion）
```markdown
## Skills Library

You have access to skills at `~/.claude/skills/`. Consider
checking for relevant skills before working on tasks.
```

### 变体 B：指令式（Directive）
```markdown
## Skills Library

Before working on any task, check `~/.claude/skills/` for
relevant skills. You should use skills when they exist.

Browse: `ls ~/.claude/skills/`
Search: `grep -r "keyword" ~/.claude/skills/`
```

### 变体 C：Claude.AI 强调风格（Claude.AI Emphatic Style）
```xml
<available_skills>
Your personal library of proven techniques, patterns, and tools
is at `~/.claude/skills/`.

Browse categories: `ls ~/.claude/skills/`
Search: `grep -r "keyword" ~/.claude/skills/ --include="SKILL.md"`

Instructions: `skills/using-skills`
</available_skills>

<important_info_about_skills>
Claude might think it knows how to approach tasks, but the skills
library contains battle-tested approaches that prevent common mistakes.

THIS IS EXTREMELY IMPORTANT. BEFORE ANY TASK, CHECK FOR SKILLS!

Process:
1. Starting work? Check: `ls ~/.claude/skills/[category]/`
2. Found a skill? READ IT COMPLETELY before proceeding
3. Follow the skill's guidance - it prevents known pitfalls

If a skill existed for your task and you didn't use it, you failed.
</important_info_about_skills>
```

### 变体 D：流程导向（Process-Oriented）
```markdown
## Working with Skills

Your workflow for every task:

1. **Before starting:** Check for relevant skills
   - Browse: `ls ~/.claude/skills/`
   - Search: `grep -r "symptom" ~/.claude/skills/`

2. **If skill exists:** Read it completely before proceeding

3. **Follow the skill** - it encodes lessons from past failures

The skills library prevents you from repeating common mistakes.
Not checking before you start is choosing to repeat those mistakes.

Start here: `skills/using-skills`
```

## 测试协议（Testing Protocol）

对每个变体：

1. **先跑 NULL 基线**（没有技能文档）
   - 记录代理选择哪个选项
   - 捕获确切的自我合理化

2. **用同样的场景跑变体**
   - 代理会检查技能吗？
   - 找到技能后会用吗？
   - 若违规，捕获自我合理化

3. **压力测试** - 加上时间 / 沉没成本 / 权威
   - 压力下代理仍会检查吗？
   - 记录遵从在何时瓦解

4. **元测试** - 问代理如何改进文档
   - "你有文档但没检查。为什么？"
   - "文档怎么写才能更清楚？"

## 成功标准（Success Criteria）

**变体成功当：**
- 代理在无人提示的情况下检查技能
- 代理在行动前完整读取技能
- 代理在压力下遵循技能指引
- 代理无法把遵从合理化掉

**变体失败当：**
- 即使没有压力，代理也会跳过检查
- 代理不读就"套用概念"
- 代理在压力下把它合理化掉
- 代理把技能当参考而非要求

## 预期结果（Expected Results）

**NULL：** 代理选最快的路径，对技能毫无意识

**变体 A：** 代理在没压力时可能会检查，有压力时会跳过

**变体 B：** 代理有时检查，容易合理化掉

**变体 C：** 遵从度强，但可能显得太死板

**变体 D：** 均衡，但更长——代理会内化它吗？

## 下一步（Next Steps）

1. 创建子代理测试框架
2. 在所有 4 个场景上跑 NULL 基线
3. 在同样的场景上测试每个变体
4. 比较遵从率
5. 识别哪些合理化能突破
6. 在胜出的变体上迭代以封住漏洞
