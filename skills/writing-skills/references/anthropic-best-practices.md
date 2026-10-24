# 技能编写最佳实践

> 学习如何编写代理可以发现和使用的有效技能。

好的技能简洁、结构良好，并经过真实使用测试。本指南提供实用的编写决策，帮助你编写代理可以有效发现和使用的技能。

有关技能如何工作的概念背景，参见 [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)。

## 核心原则

### 简洁是关键

[上下文窗口](https://platform.claude.com/docs/en/build-with-claude/context-windows) 是公共资源。你的技能与代理需要知道的所有其他内容共享上下文窗口，包括：

* 系统提示
* 对话历史
* 其他技能的元数据
* 你的实际请求

不是你的技能中的每个标记都有直接成本。在启动时，仅所有技能的元数据（名称和描述）被预加载。代理仅在技能变得相关时读取 SKILL.md，并且仅在需要时读取其他文件。但是，在 SKILL.md 中保持简洁仍然重要：一旦代理加载它，每个标记都与对话历史和其他上下文竞争。

**默认假设**：代理已经非常聪明

仅添加代理没有的上下文。挑战每条信息：

* "代理真的需要这个解释吗？"
* "我可以假设代理知道这个吗？"
* "这个段落证明其标记成本吗？"

**好示例：简洁**（约 50 个标记）：

````markdown  theme={null}
## 提取 PDF 文本

使用 pdfplumber 进行文本提取：

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**坏示例：太冗长**（约 150 个标记）：

```markdown  theme={null}
## 提取 PDF 文本

PDF（便携式文档格式）文件是包含文本、图像和其他内容的常见文件格式。要从 PDF 提取文本，你需要使用库。有许多库可用于 PDF 处理，但我们推荐 pdfplumber，因为它易于使用且能很好地处理大多数情况。首先，你需要使用 pip 安装它。然后你可以使用下面的代码...
```

简洁版本假设代理知道 PDF 是什么以及库如何工作。

### 设置适当的自由度

将具体性级别与任务的脆弱性和可变性匹配。

**高自由度**（基于文本的指令）：

当以下情况时使用：

* 多种方法有效
* 决定取决于上下文
* 启发式指导方法

示例：

```markdown  theme={null}
## 代码审查流程

1. 分析代码结构和组织
2. 检查潜在的 bug 或边缘情况
3. 建议提高可读性和可维护性
4. 验证是否遵循项目约定
```

**中等自由度**（伪代码或带有参数的脚本）：

当以下情况时使用：

* 存在首选模式
* 某些变化可接受
* 配置影响行为

示例：

````markdown  theme={null}
## 生成报告

使用此模板并根据需要自定义：

```python
def generate_report(data, format="markdown", include_charts=True):
    # 处理数据
    # 生成指定格式的输出
    # 可选包含可视化
```
````

**低自由度**（特定脚本，很少或没有参数）：

当以下情况时使用：

* 操作脆弱且容易出错
* 一致性至关重要
* 必须遵循特定顺序

示例：

````markdown  theme={null}
## 数据库迁移

精确运行此脚本：

```bash
python scripts/migrate.py --verify --backup
```

不要修改命令或添加额外标志。
````

**类比**：将代理想象为探索路径的机器人：

* **两侧有悬崖的窄桥**：只有一种安全的前进方式。提供特定的护栏和精确指令（低自由度）。示例：必须按精确顺序运行的数据库迁移。
* **没有危险的开阔场地**：许多路径通向成功。给出一般方向并信任代理找到最佳路线（高自由度）。示例：上下文决定最佳方法的代码审查。

### 使用你计划使用的所有模型进行测试

技能充当模型的附加功能，因此有效性取决于底层模型。使用你计划使用的所有模型测试你的技能。

**按模型的测试考虑**：

* **Claude Haiku**（快速、经济）：技能是否提供足够的指导？
* **Claude Sonnet**（平衡）：技能是否清晰高效？
* **Claude Opus**（强大的推理）：技能是否避免过度解释？

对 Opus 完美的东西可能对 Haiku 需要更多细节。如果你计划在多个模型之间使用你的技能，目标是适用于所有它们的指令。

## 技能结构

<Note>
  **YAML Frontmatter**：SKILL.md frontmatter 需要两个字段：

  * `name` - 技能的人类可读名称（最多 64 个字符）
  * `description` - 技能做什么以及何时使用的一行描述（最多 1024 个字符）

  有关完整技能结构详细信息，参见 [Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名约定

使用一致的命名模式，使技能更容易引用和讨论。我们建议使用**动名词形式**（动词 + -ing）作为技能名称，因为这清楚地描述了技能提供的活动或能力。

**好的命名示例（动名词形式）**：

* "Processing PDFs"
* "Analyzing spreadsheets"
* "Managing databases"
* "Testing code"
* "Writing documentation"

**可接受的替代方案**：

* 名词短语："PDF Processing"、"Spreadsheet Analysis"
* 面向行动："Process PDFs"、"Analyze Spreadsheets"

**避免**：

* 模糊的名称："Helper"、"Utils"、"Tools"
* 过于通用："Documents"、"Data"、"Files"
* 技能集合中不一致的模式

一致的命名使更容易：

* 在文档和对话中引用技能
* 一眼了解技能的作用
* 组织和搜索多个技能
* 维护专业、凝聚的技能库

### 编写有效的描述

`description` 字段启用技能发现，应包括技能做什么以及何时使用它。

<Warning>
  **始终使用第三人称编写**。描述被注入系统提示，不一致的观点可能导致发现问题。

  * **好：** "Processes Excel files and generates reports"
  * **避免：** "I can help you process Excel files"
  * **避免：** "You can use this to process Excel files"
</Warning>

**具体并包含关键术语**。包括技能做什么以及何时使用的特定触发器/上下文。

每个技能只有一个描述字段。描述对技能选择至关重要：代理使用它从可能 100+ 可用技能中选择正确的技能。你的描述必须提供足够的细节，使代理知道何时选择此技能，而 SKILL.md 的其余部分提供实施细节。