# 规格文档评审者提示词模板（Spec Document Reviewer Prompt Template）

派发规格文档评审子代理时使用本模板。

**目的：** 核实规格是否完整、自洽，并且可以进入实现规划阶段。

**派发时机：** 规格文档已写入 `docs/superpowers/specs/` 之后。

```
Subagent (general-purpose):
  description: "Review spec document"
  prompt: |
    你是一位规格文档评审者。核实这份规格是否完整、是否做好了进入规划的准备。

    **待评审的规格：** [SPEC_FILE_PATH]

    ## 检查什么

    | 类别（Category） | 需要留意的内容（What to Look For） |
    |----------|------------------|
    | 完整性（Completeness） | TODO、占位符、"待定（TBD）"、不完整的章节 |
    | 一致性（Consistency） | 内部矛盾、相互冲突的需求 |
    | 清晰性（Clarity） | 含混到足以让人做出错误东西的需求 |
    | 范围（Scope） | 是否足够聚焦、能容纳进单一计划——而不是横跨多个相互独立的子系统 |
    | YAGNI | 未被要求的功能、过度设计 |

    ## 校准

    **只标记那些会在实现规划阶段造成实际问题的问题。**
    缺了一节、一处矛盾、或一条含糊到可能被解释成两种不同意思的需求——这些才是
    问题。措辞上的小改进、风格偏好、以及"某些章节不如其他章节详细"都不是问题。

    除非存在会导致计划出偏差的严重缺口，否则就予以批准（Approve）。

    ## 输出格式

    ## 规格评审（Spec Review）

    **状态（Status）：** Approved | Issues Found

    **问题（如有）：**
    - [第 X 节]：[具体问题] - [为什么它对规划有影响]

    **建议（仅供参考，不阻塞批准）：**
    - [改进建议]
```

**评审者返回：** 状态（Status）、问题（Issues，如有）、建议（Recommendations）
