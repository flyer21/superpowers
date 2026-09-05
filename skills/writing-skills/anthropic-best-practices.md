# 技能编写的最佳实践（Skill authoring best practices）

> 学习如何编写可被代理发现并成功使用的有效技能（Skills）。

好的技能是简洁的、结构良好的、并经真实使用检验过的。本指南提供实用的编写决策，帮助你写出代理能够发现并有效使用的技能。

关于技能工作方式的概念背景，见 [技能概述](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)。

## 核心原则（Core principles）

### 简洁是关键（Concise is key）

[上下文窗口](https://platform.claude.com/docs/en/build-with-claude/context-windows) 是一种公共资源。你的技能要和代理需要知道的其他一切共享上下文窗口，包括：

* 系统提示
* 对话历史
* 其他技能的元数据
* 你的实际请求

不是技能里的每一个 token 都有立即可见的代价。启动时，只会预加载所有技能里的元数据（名称和描述）。代理只在技能变得相关时才读取 SKILL.md，并且只在需要时读取其他文件。然而，SKILL.md 写得简洁仍然重要：一旦代理加载了它，每一个 token 都要和对话历史及其他上下文竞争。

**默认假设：** 代理已经很聪明了

只添加代理还没有的上下文。对每一段信息提出质疑：

* "代理真的需要这个解释吗？"
* "我能不能假定代理已经知道这个？"
* "这一段配得上它的 token 代价吗？"

**好示例：简洁**（约 50 token）：

````markdown  theme={null}
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**坏示例：过于啰嗦**（约 150 token）：

```markdown  theme={null}
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
```

简洁版本假定代理知道 PDF 是什么、库是如何工作的。

### 设定恰当的自由度（Set appropriate degrees of freedom）

让具体程度匹配任务的脆弱性与可变性。

**高自由度**（基于文本的指令）：

何时使用：

* 多种做法都成立
* 决策取决于上下文
* 启发式指引方法

示例：

```markdown  theme={null}
## Code review process

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions
```

**中等自由度**（带参数的伪代码或脚本）：

何时使用：

* 存在一个偏好的模式
* 允许一定的变化
* 配置会影响行为

示例：

````markdown  theme={null}
## Generate report

Use this template and customize as needed:

```python
def generate_report(data, format="markdown", include_charts=True):
    # Process data
    # Generate output in specified format
    # Optionally include visualizations
```
````

**低自由度**（具体脚本，参数很少或没有）：

何时使用：

* 操作脆弱且易错
* 一致性至关重要
* 必须遵循特定顺序

示例：

````markdown  theme={null}
## Database migration

Run exactly this script:

```bash
python scripts/migrate.py --verify --backup
```

Do not modify the command or add additional flags.
````

**类比（Analogy）：** 把代理想象成一条路上探索的机器人：

* **两侧都是悬崖的窄桥**：只有一条安全的路。提供具体的护栏和精确的指令（低自由度）。示例：必须按精确顺序运行的数据库迁移。
* **没有危险的旷野**：很多路都能通向成功。给出大致方向，信任代理自己找到最佳路线（高自由度）。示例：代码评审，具体上下文决定最佳做法。

### 用你计划使用的所有模型来测试（Test with all models you plan to use）

技能是对模型的补充，所以有效性取决于底层模型。用你计划配合使用技能的所有模型来测试。

**按模型的测试考量：**

* **Claude Haiku**（快速、经济）：技能是否提供了足够的指引？
* **Claude Sonnet**（均衡）：技能是否清晰高效？
* **Claude Opus**（强大推理）：技能是否避免了过度解释？

对 Opus 完美的写法，可能对 Haiku 就需要更多细节。如果你计划在多个模型间使用技能，目标是写出对所有模型都适用的指令。

## 技能结构（Skill structure）

<Note>
  **YAML Frontmatter（YAML 前置元数据）**：SKILL.md 的前置元数据要求两个字段：

  * `name` - 技能的人类可读名称（最多 64 个字符）
  * `description` - 一行描述，说明技能做什么以及何时使用（最多 1024 个字符）

  关于完整的技能结构细节，见[技能概述](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名约定（Naming conventions）

使用一致的命名模式，让技能更容易被引用和讨论。我们建议技能名用**动名词形式（gerund form，动词 + -ing）**，因为它能清晰地描述技能提供的活动或能力。

**好的命名示例（动名词形式）：**

* "Processing PDFs"
* "Analyzing spreadsheets"
* "Managing databases"
* "Testing code"
* "Writing documentation"

**可接受的替代：**

* 名词短语："PDF Processing"、"Spreadsheet Analysis"
* 动作导向："Process PDFs"、"Analyze Spreadsheets"

**要避免的：**

* 模糊的名字："Helper"、"Utils"、"Tools"
* 过于通用："Documents"、"Data"、"Files"
* 技能集合内不一致的模式

一致的命名让你更容易：

* 在文档和对话里引用技能
* 一眼看出技能是做什么的
* 在多个技能中组织与搜索
* 维护一个专业、连贯的技能库

### 编写有效的描述（Writing effective descriptions）

`description` 字段使技能可被发现，应该既包含技能做什么，也包含何时使用。

<Warning>
  **始终用第三人称写。** 描述会被注入系统提示，人称不一致会造成发现方面的问题。

  * **好：** "Processes Excel files and generates reports"
  * **避免：** "I can help you process Excel files"
  * **避免：** "You can use this to process Excel files"
</Warning>

**要具体，并包含关键术语。** 既包含技能做什么，也包含何时使用的具体触发条件 / 上下文。

每个技能恰好有一个 description 字段。描述对技能选择至关重要：代理用它从可能 100+ 个可用技能里选出正确的那一个。你的描述必须提供足够细节让代理知道何时选择该技能，而 SKILL.md 的其余部分提供实现细节。

有效的示例：

**PDF Processing 技能：**

```yaml  theme={null}
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Excel Analysis 技能：**

```yaml  theme={null}
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```

**Git Commit Helper 技能：**

```yaml  theme={null}
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

避免这样的模糊描述：

```yaml  theme={null}
description: Helps with documents
```

```yaml  theme={null}
description: Processes data
```

```yaml  theme={null}
description: Does stuff with files
```

### 渐进式披露模式（Progressive disclosure patterns）

SKILL.md 起概述作用，在需要时把代理指向详细材料，就像入职指南里的目录。关于渐进式披露如何运作的解释，见概述里的 [技能如何工作](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

**实用指引：**

* 让 SKILL.md 正文保持在 500 行以内以获得最佳性能
* 接近该上限时把内容拆到单独文件里
* 用下面的模式有效组织指令、代码和资源

#### 视觉总览：从简单到复杂

一个基础技能从只有一个 SKILL.md 文件开始，内含元数据和指令：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="Simple SKILL.md file showing YAML frontmatter and markdown body" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

随着技能成长，你可以捆绑只在需要时才被代理加载的额外内容：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="Bundling additional reference files like reference.md and forms.md." data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

完整的技能目录结构可能长这样：

```
pdf/
├── SKILL.md              # Main instructions (loaded when triggered)
├── FORMS.md              # Form-filling guide (loaded as needed)
├── reference.md          # API reference (loaded as needed)
├── examples.md           # Usage examples (loaded as needed)
└── scripts/
    ├── analyze_form.py   # Utility script (executed, not loaded)
    ├── fill_form.py      # Form filling script
    └── validate.py       # Validation script
```

#### 模式 1：带参考的高层指南（High-level guide with references）

````markdown  theme={null}
---
name: PDF Processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

# PDF Processing

## Quick start

Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
**Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
````

代理只在需要时加载 FORMS.md、REFERENCE.md 或 EXAMPLES.md。

#### 模式 2：按领域组织（Domain-specific organization）

对于含多个领域的技能，按领域组织内容，避免加载无关上下文。当用户询问销售指标时，代理只需要读销售相关的 schema，而不是财务或市场数据。这样能保持低 token 用量和聚焦的上下文。

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

````markdown SKILL.md theme={null}
# BigQuery Data Analysis

## Available datasets

**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Opportunities, pipeline, accounts → See [reference/sales.md](reference/sales.md)
**Product**: API usage, features, adoption → See [reference/product.md](reference/product.md)
**Marketing**: Campaigns, attribution, email → See [reference/marketing.md](reference/marketing.md)

## Quick search

Find specific metrics using grep:

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
````

#### 模式 3：条件式细节（Conditional details）

展示基础内容，链接到进阶内容：

```markdown  theme={null}
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

代理只在用户需要那些特性时才读 REDLINING.md 或 OOXML.md。

### 避免深层嵌套的引用（Avoid deeply nested references）

代理在文件被其他引用文件引用时，可能只读一部分。遇到嵌套引用时，代理可能用 `head -100` 之类的命令预览内容，而不是读整个文件，导致信息不完整。

**让引用只从 SKILL.md 深入一层。** 所有引用文件都应该直接从 SKILL.md 链接，确保代理在需要时能读完整文件。

**坏示例：太深：**

```markdown  theme={null}
# SKILL.md
See [advanced.md](advanced.md)...

# advanced.md
See [details.md](details.md)...

# details.md
Here's the actual information...
```

**好示例：一层深：**

```markdown  theme={null}
# SKILL.md

**Basic usage**: [instructions in SKILL.md]
**Advanced features**: See [advanced.md](advanced.md)
**API reference**: See [reference.md](reference.md)
**Examples**: See [examples.md](examples.md)
```

### 用目录组织更长的参考文件（Structure longer reference files with table of contents）

对于超过 100 行的参考文件，在顶部放一个目录。这能确保即使代理用部分读取预览，也能看到可用信息的全貌。

**示例：**

```markdown  theme={null}
# API Reference

## Contents
- Authentication and setup
- Core methods (create, read, update, delete)
- Advanced features (batch operations, webhooks)
- Error handling patterns
- Code examples

## Authentication and setup
...

## Core methods
...
```

代理随后可以读完整文件，或按需跳到特定小节。

关于这种基于文件系统的架构如何实现渐进式披露，见下方"高级"一节的 [Runtime environment](#runtime-environment)。

## 工作流与反馈循环（Workflows and feedback loops）

### 复杂任务使用工作流（Use workflows for complex tasks）

把复杂操作拆成清晰、有序的步骤。对特别复杂的工作流，提供一个检查清单，让代理可以复制到自己的回复里，随进度勾选。

**示例 1：研究综合工作流**（用于不含代码的技能）：

````markdown  theme={null}
## Research synthesis workflow

Copy this checklist and track your progress:

```
Research Progress:
- [ ] Step 1: Read all source documents
- [ ] Step 2: Identify key themes
- [ ] Step 3: Cross-reference claims
- [ ] Step 4: Create structured summary
- [ ] Step 5: Verify citations
```

**Step 1: Read all source documents**

Review each document in the `sources/` directory. Note the main arguments and supporting evidence.

**Step 2: Identify key themes**

Look for patterns across sources. What themes appear repeatedly? Where do sources agree or disagree?

**Step 3: Cross-reference claims**

For each major claim, verify it appears in the source material. Note which source supports each point.

**Step 4: Create structured summary**

Organize findings by theme. Include:
- Main claim
- Supporting evidence from sources
- Conflicting viewpoints (if any)

**Step 5: Verify citations**

Check that every claim references the correct source document. If citations are incomplete, return to Step 3.
````

这个示例展示工作流如何应用于不需要代码的分析任务。检查清单模式适用于任何复杂、多步骤的过程。

**示例 2：PDF 表单填写工作流**（用于含代码的技能）：

````markdown  theme={null}
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```

**Step 1: Analyze the form**

Run: `python scripts/analyze_form.py input.pdf`

This extracts form fields and their locations, saving to `fields.json`.

**Step 2: Create field mapping**

Edit `fields.json` to add values for each field.

**Step 3: Validate mapping**

Run: `python scripts/validate_fields.py fields.json`

Fix any validation errors before continuing.

**Step 4: Fill the form**

Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: Verify output**

Run: `python scripts/verify_output.py output.pdf`

If verification fails, return to Step 2.
````

清晰的步骤能防止代理跳过关键的验证。检查清单帮助你和代理在多步骤工作流中一起追踪进度。

### 实现反馈循环（Implement feedback loops）

**常见模式：** 运行校验器 → 修复错误 → 重复

这个模式能大幅提升输出质量。

**示例 1：风格指南遵从**（用于不含代码的技能）：

```markdown  theme={null}
## Content review process

1. Draft your content following the guidelines in STYLE_GUIDE.md
2. Review against the checklist:
   - Check terminology consistency
   - Verify examples follow the standard format
   - Confirm all required sections are present
3. If issues found:
   - Note each issue with specific section reference
   - Revise the content
   - Review the checklist again
4. Only proceed when all requirements are met
5. Finalize and save the document
```

这展示用参考文档而非脚本的验证循环模式。"校验器"是 STYLE_GUIDE.md，代理通过阅读和比对来执行检查。

**示例 2：文档编辑流程**（用于含代码的技能）：

```markdown  theme={null}
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

验证循环能及早抓住错误。

## 内容准则（Content guidelines）

### 避免时效性信息（Avoid time-sensitive information）

不要包含会过时的信息：

**坏示例：有时效性**（会变错）：

```markdown  theme={null}
If you're doing this before August 2025, use the old API.
After August 2025, use the new API.
```

**好示例**（用"旧模式"小节）：

```markdown  theme={null}
## Current method

Use the v2 API endpoint: `api.example.com/v2/messages`

## Old patterns

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>

The v1 API used: `api.example.com/v1/messages`

This endpoint is no longer supported.
</details>
```

旧模式小节在不让主要内容变乱的前提下提供历史背景。

### 使用一致的术语（Use consistent terminology）

挑一个词，并在整个技能里始终用它：

**好——一致：**

* 始终用 "API endpoint"
* 始终用 "field"
* 始终用 "extract"

**坏——不一致：**

* 混用 "API endpoint"、"URL"、"API route"、"path"
* 混用 "field"、"box"、"element"、"control"
* 混用 "extract"、"pull"、"get"、"retrieve"

一致性帮助代理理解和遵循指令。

## 常见模式（Common patterns）

### 模板模式（Template pattern）

为输出格式提供模板。把严格程度匹配到你的需要。

**对严格要求**（如 API 响应或数据格式）：

````markdown  theme={null}
## Report structure

ALWAYS use this exact template structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data
- Finding 2 with supporting data
- Finding 3 with supporting data

## Recommendations
1. Specific actionable recommendation
2. Specific actionable recommendation
```
````

**对灵活指引**（当需要适配时）：

````markdown  theme={null}
## Report structure

Here is a sensible default format, but use your best judgment based on the analysis:

```markdown
# [Analysis Title]

## Executive summary
[Overview]

## Key findings
[Adapt sections based on what you discover]

## Recommendations
[Tailor to the specific context]
```

Adjust sections as needed for the specific analysis type.
````

### 示例模式（Examples pattern）

对于输出质量取决于见过示例的技能，提供输入 / 输出对，就像普通提示一样：

````markdown  theme={null}
## Commit message format

Generate commit messages following these examples:

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**Example 3:**
Input: Updated dependencies and refactored error handling
Output:
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

Follow this style: type(scope): brief description, then detailed explanation.
````

示例比纯描述更能帮代理理解想要的风格与详细程度。

### 条件工作流模式（Conditional workflow pattern）

引导代理走过决策点：

```markdown  theme={null}
## Document modification workflow

1. Determine the modification type:

   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below

2. Creation workflow:
   - Use docx-js library
   - Build document from scratch
   - Export to .docx format

3. Editing workflow:
   - Unpack existing document
   - Modify XML directly
   - Validate after each change
   - Repack when complete
```

<Tip>
  如果工作流变得庞大或复杂、步骤很多，考虑把它们推进单独的文件里，并告诉代理根据手头的任务读取对应文件。
</Tip>

## 评估与迭代（Evaluation and iteration）

### 先建评估（Build evaluations first）

**在写大量文档之前先创建评估。** 这能确保你的技能解决的是真实问题，而不是文档化想象中的问题。

**评估驱动的开发（Evaluation-driven development）：**

1. **识别缺口**：不给技能，让代理在代表性的任务上运行。记录具体的失败或缺失的上下文
2. **创建评估**：构建三个测试这些缺口的场景
3. **建立基线**：在没有技能的情况下测量代理的表现
4. **编写最小指令**：只创建足以解决缺口并通过评估的内容
5. **迭代**：执行评估，对照基线比较，再精炼

这个方法确保你解决的是实际问题，而不是预想那些也许永远不会出现的需求。

**评估结构：**

```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  这个示例展示了一种带简单测试细则的数据驱动评估。我们目前不提供运行这些评估的内建方式。用户可以建立自己的评估系统。评估是你度量技能有效性的真相来源。
</Note>

### 与代理一起迭代式开发技能（Develop Skills iteratively with the agent）

最有效的技能开发流程要把代理本身卷进来。与一个实例（"Agent A"）合作，创建一个将供其他实例（"Agent B"）使用的技能。Agent A 帮你设计和精炼指令，Agent B 在真实任务里测试它们。这之所以有效，是因为底层模型既理解如何编写有效的代理指令，也理解代理需要什么信息。

**创建一个新技能：**

1. **不带技能完成一个任务**：用普通提示和 Agent A 走一遍问题。在这个过程中，你会自然地提供上下文、解释偏好、分享过程性知识。留意哪些信息你反复提供。

2. **识别可复用的模式**：任务完成后，识别你提供过、且对未来类似任务有用的上下文。

   **示例**：如果你走完一次 BigQuery 分析，你可能提供了表名、字段定义、过滤规则（比如"总是排除测试账号"）和常用查询模式。

3. **请 Agent A 创建一个技能**："创建一个技能，捕获我们刚才用的这个 BigQuery 分析模式。包含表 schema、命名约定，以及过滤测试账号那条规则。"

   <Tip>
     现代代理原生理解技能格式和结构。你不需要特殊的系统提示或一个"编写技能"的技能就能得到创建技能方面的帮助。直接请代理创建一个技能，它会生成结构正确的 SKILL.md 内容，带合适的前置元数据和正文。
   </Tip>

4. **检查简洁性**：检查 Agent A 有没有加不必要的解释。问："删掉关于胜率是什么意思的解释——代理已经知道了。"

5. **改进信息架构**：请 Agent A 更有效地组织内容。例如："这样组织，让表 schema 放在单独的参考文件里。我们以后可能还会加更多表。"

6. **在类似任务上测试**：让 Agent B（一个加载了该技能的全新实例）在相关的用例上使用该技能。观察 Agent B 能否找到正确的信息、正确地应用规则、成功处理任务。

7. **基于观察迭代**：如果 Agent B 挣扎或漏掉什么，带着具体情况回到 Agent A："当代理用这个技能时，它忘了为 Q4 按日期过滤。我们要不要加一小节讲日期过滤模式？"

**在既有技能上迭代：**

改进技能时延续同样的层级模式。你在以下之间交替：

* **与 Agent A 合作**（帮助精炼技能的专家）
* **用 Agent B 测试**（用技能执行真实工作的代理）
* **观察 Agent B 的行为**并把洞见带回给 Agent A

1. **在真实工作流里使用技能**：给 Agent B（已加载技能）真实任务，而不是测试场景

2. **观察 Agent B 的行为**：留意它在哪里挣扎、成功、或做出意料之外的选择

   **示例观察**："当我请 Agent B 出一份区域销售报告时，它写了查询但忘了过滤掉测试账号，尽管技能里提到了这条规则。"

3. **回到 Agent A 寻求改进**：分享当前的 SKILL.md，描述你观察到的。问："我注意到我请 Agent B 出区域报告时它忘了过滤测试账号。技能里提到了过滤，但也许它不够突出？"

4. **审查 Agent A 的建议**：Agent A 可能建议重组让规则更突出、用更强的措辞如"MUST filter"而不是"always filter"，或重组工作流小节。

5. **应用并测试改动**：用 Agent A 的精炼更新技能，再在类似的请求上拿 Agent B 测试

6. **基于使用情况重复**：当你遇到新场景时，继续这个观察-精炼-测试的循环。每一次迭代都基于真实代理行为改进技能，而不是基于假设。

**收集团队反馈：**

1. 与队友共享技能，观察他们的使用情况
2. 问：技能是否在预期时被激活？指令清晰吗？缺了什么？
3. 纳入反馈，处理你自己使用模式中的盲区

**为什么这种方法有效**：Agent A 理解代理的需要，你提供领域专长，Agent B 通过真实使用暴露缺口，迭代式精炼基于观察到的行为（而非假设）改进技能。

### 观察代理如何浏览技能（Observe how agents navigate Skills）

当你在技能上迭代时，注意代理在实践中实际如何使用它们。留意：

* **出人意料的开掘路径**：代理读取文件的顺序出乎你的预料吗？这可能说明你的结构没有你想象的那么直观
* **错失的连接**：代理没能跟随到重要文件的引用吗？你的链接可能需要更明确或更突出
* **过度依赖某些小节**：如果代理反复读同一个文件，考虑那些内容是否应该放进主 SKILL.md
* **被忽略的内容**：如果代理从不访问某个捆绑文件，它可能是不必要的，或在主指令里信号不良

基于这些观察迭代，而不是基于假设。你技能元数据里的 `name` 和 `description` 尤其关键。代理在决定是否针对当前任务触发技能时使用它们。确保它们清楚地描述技能做什么、何时使用。

## 要避免的反模式（Anti-patterns to avoid）

### 避免 Windows 风格路径（Avoid Windows-style paths）

即使在 Windows 上，也始终在文件路径里用正斜杠：

* ✓ **好**：`scripts/helper.py`、`reference/guide.md`
* ✗ **避免**：`scripts\helper.py`、`reference\guide.md`

Unix 风格路径跨所有平台可用，而 Windows 风格路径会在 Unix 系统上引发错误。

### 避免提供过多选项（Avoid offering too many options）

除非必要，不要摆出多种做法：

````markdown  theme={null}
**Bad example: Too many choices** (confusing):
"You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or..."

**Good example: Provide a default** (with escape hatch):
"Use pdfplumber for text extraction:
```python
import pdfplumber
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
````

## 高级：带可执行代码的技能（Advanced: Skills with executable code）

下面的小节聚焦包含可执行脚本的技能。如果你的技能只用 markdown 指令，跳到 [有效技能的检查清单](#checklist-for-effective-skills)。

### 解决，别推诿（Solve, don't punt）

为技能写脚本时，要处理错误条件，而不是把球踢回给代理。

**好示例：显式处理错误：**

```python  theme={null}
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # Create file with default content instead of failing
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # Provide alternative instead of failing
        print(f"Cannot access {path}, using default")
        return ''
```

**坏示例：踢回给代理：**

```python  theme={null}
def process_file(path):
    # Just fail and let the agent figure it out
    return open(path).read()
```

配置参数也应该有理由和文档，以避免"巫毒常量"（voodoo constants，Ousterhout 定律）。如果你不知道正确的值，代理又怎么可能确定它？

**好示例：自文档化：**

```python  theme={null}
# HTTP requests typically complete within 30 seconds
# Longer timeout accounts for slow connections
REQUEST_TIMEOUT = 30

# Three retries balances reliability vs speed
# Most intermittent failures resolve by the second retry
MAX_RETRIES = 3
```

**坏示例：魔法数字：**

```python  theme={null}
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

### 提供工具脚本（Provide utility scripts）

即使你的代理能写脚本，预制的脚本也有优势：

**工具脚本的好处：**

* 比生成的代码更可靠
* 节省 token（无需在上下文里包含代码）
* 节省时间（无需代码生成）
* 确保各次使用之间的一致

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="Bundling executable scripts alongside instruction files" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

上图展示可执行脚本如何与指令文件协同工作。指令文件（forms.md）引用脚本，代理可以在不把脚本内容加载进上下文的情况下执行它。

**重要区分：** 在你的指令里讲清楚代理应该：

* **执行脚本**（最常见）："运行 `analyze_form.py` 来提取字段"
* **作为参考读取它**（对复杂逻辑）："看 `analyze_form.py` 了解字段提取算法"

对大多数工具脚本，执行是首选，因为它更可靠、更高效。脚本执行如何工作的细节见下方 [Runtime environment](#runtime-environment) 小节。

**示例：**

````markdown  theme={null}
## Utility scripts

**analyze_form.py**: Extract all form fields from PDF

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

Output format:
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**: Check for overlapping bounding boxes

```bash
python scripts/validate_boxes.py fields.json
# Returns: "OK" or lists conflicts
```

**fill_form.py**: Apply field values to PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 使用视觉分析（Use visual analysis）

当输入可以渲染成图像时，让代理分析它们：

````markdown  theme={null}
## Form layout analysis

1. Convert PDF to images:
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. Analyze each page image to identify form fields
3. The agent can see field locations and types visually
````

<Note>
  在这个示例里，你需要自己编写 `pdf_to_images.py` 脚本。
</Note>

代理的视觉能力帮助理解布局和结构。

### 创建可验证的中间输出（Create verifiable intermediate outputs）

当代理执行复杂、开放式的任务时，它们可能犯错。"计划-验证-执行"（plan-validate-execute）模式让代理先以结构化格式创建计划、在执行前用脚本验证该计划，从而及早抓住错误。

**示例**：想象你让代理根据一张电子表格更新 PDF 里的 50 个表单字段。没有验证的话，它可能引用不存在的字段、产生冲突的值、漏掉必填字段，或错误地应用更新。

**解决方案**：用上面展示的工作流模式（PDF 表单填写），但在应用改动之前加一个会被验证的中间 `changes.json` 文件。工作流变成：分析 → **创建计划文件** → **验证计划** → 执行 → 验证。

**为什么这个模式有效：**

* **及早抓住错误**：验证在改动被应用之前发现问题
* **可机器验证**：脚本提供客观验证
* **计划可逆**：代理可以在不碰原件的情况下迭代计划
* **清晰的调试**：错误信息指向具体问题

**何时使用**：批量操作、破坏性改动、复杂验证规则、高风险的运维。

**实现提示**：让验证脚本啰嗦些，给出具体的错误信息，比如"找不到字段 'signature_date'。可用字段：customer_name、order_total、signature_date_signed"，以帮助代理修复问题。

### 打包依赖（Package dependencies）

技能在带平台特定限制的代码执行环境里运行：

* **claude.ai**：可以从 npm 和 PyPI 安装包，从 GitHub 仓库拉取
* **Anthropic API**：没有网络访问，也没有运行时包安装

在 SKILL.md 里列出所需包，并在[代码执行工具文档](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool)中确认它们可用。

### 运行时环境（Runtime environment）

技能运行在一个带文件系统访问、bash 命令和代码执行能力的代码执行环境里。关于该架构的概念解释，见概述里的 [技能架构](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#the-skills-architecture)。

**这对你的编写意味着什么：**

**代理如何访问技能：**

1. **元数据预加载**：启动时，所有技能 YAML 前置元数据里的名称和描述会被加载进系统提示
2. **按需读取文件**：代理用文件读取工具在需要时从文件系统访问 SKILL.md 和其他文件
3. **高效执行脚本**：工具脚本可以通过 bash 执行，无需把完整内容加载进上下文。只有脚本的输出消耗 token
4. **大文件无上下文代价**：参考文件、数据或文档在被真正读取之前不消耗上下文 token

* **文件路径很重要**：代理像浏览文件系统一样浏览你的技能目录。用正斜杠（`reference/guide.md`），不要用反斜杠
* **文件名要能表达内容**：用表明内容的名称：`form_validation_rules.md`，而不是 `doc2.md`
* **为发现而组织**：按领域或特性组织目录
  * 好：`reference/finance.md`、`reference/sales.md`
  * 坏：`docs/file1.md`、`docs/file2.md`
* **捆绑完整资源**：包含完整的 API 文档、大量的示例、大数据集；在访问之前没有上下文代价
* **确定性操作优先用脚本**：写 `validate_form.py`，而不是让代理去生成验证代码
* **让执行意图清晰**：
  * "运行 `analyze_form.py` 来提取字段"（执行）
  * "看 `analyze_form.py` 了解提取算法"（作为参考读取）
* **测试文件访问模式**：用真实请求验证代理能否在你的目录结构里导航

**示例：**

```
bigquery-skill/
├── SKILL.md (overview, points to reference files)
└── reference/
    ├── finance.md (revenue metrics)
    ├── sales.md (pipeline data)
    └── product.md (usage analytics)
```

当用户询问收入时，代理读取 SKILL.md，看到对 `reference/finance.md` 的引用，并调用 bash 只读那个文件。sales.md 和 product.md 留在文件系统里，在需要前消耗零上下文 token。正是这种基于文件系统的模型实现了渐进式披露。代理可以导航并有选择地加载每个任务恰好需要的内容。

关于技术架构的完整细节，见技能概述里的 [技能如何工作](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

### MCP 工具引用（MCP tool references）

如果你的技能使用 MCP（Model Context Protocol）工具，始终用完全限定的工具名，避免"找不到工具"错误。

**格式**：`ServerName:tool_name`

**示例**：

```markdown  theme={null}
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.
```

其中：

* `BigQuery` 和 `GitHub` 是 MCP 服务器名
* `bigquery_schema` 和 `create_issue` 是这些服务器里的工具名

没有服务器前缀，代理可能找不到该工具，尤其是存在多个 MCP 服务器时。

### 避免假定工具已安装（Avoid assuming tools are installed）

不要假定包是可用的：

````markdown  theme={null}
**Bad example: Assumes installation**:
"Use the pdf library to process the file."

**Good example: Explicit about dependencies**:
"Install required package: `pip install pypdf`

Then use it:
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
````

## 技术说明（Technical notes）

### YAML 前置元数据要求（YAML frontmatter requirements）

SKILL.md 的前置元数据要求 `name`（最多 64 个字符）和 `description`（最多 1024 个字符）字段。完整的结构细节见[技能概述](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#skill-structure)。

### Token 预算（Token budgets）

让 SKILL.md 正文保持在 500 行以内以获得最佳性能。如果内容超过它，用前面描述的渐进式披露模式拆成多个文件。架构细节见[技能概述](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

## 有效技能的检查清单（Checklist for effective Skills）

共享一个技能之前，验证：

### 核心质量（Core quality）

* [ ] 描述具体并包含关键术语
* [ ] 描述既包含技能做什么，也包含何时使用
* [ ] SKILL.md 正文在 500 行以内
* [ ] 额外细节放在单独文件里（如果需要）
* [ ] 没有时效性信息（或放在"旧模式"小节）
* [ ] 整个技能术语一致
* [ ] 示例具体，而非抽象
* [ ] 文件引用只有一层深
* [ ] 恰当使用渐进式披露
* [ ] 工作流步骤清晰

### 代码与脚本（Code and scripts）

* [ ] 脚本解决问题而非踢回给代理
* [ ] 错误处理显式且有帮助
* [ ] 没有"巫毒常量"（所有值都有理由）
* [ ] 必需包已在指令里列出并验证可用
* [ ] 脚本有清晰的文档
* [ ] 没有 Windows 风格路径（全是正斜杠）
* [ ] 关键操作有验证 / 校验步骤
* [ ] 质量攸关的任务包含反馈循环

### 测试（Testing）

* [ ] 至少创建三个评估
* [ ] 用 Haiku、Sonnet 和 Opus 测试过
* [ ] 用真实使用场景测试过
* [ ] 纳入团队反馈（如适用）

## 下一步（Next steps）

<CardGroup cols={2}>
  <Card title="Get started with Agent Skills" icon="rocket" href="https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart">
    Create your first Skill
  </Card>

  <Card title="Use Skills in Claude Code" icon="terminal" href="https://code.claude.com/docs/en/skills">
    Create and manage Skills in Claude Code
  </Card>

  <Card title="Use Skills with the API" icon="code" href="https://platform.claude.com/docs/en/build-with-claude/skills-guide">
    Upload and use Skills programmatically
  </Card>
</CardGroup>
