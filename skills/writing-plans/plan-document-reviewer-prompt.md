# 计划文档评审提示词模板（Plan Document Reviewer Prompt Template）

使用本模板派发计划文档评审子代理。

**用途（Purpose）：** 验证计划是否完整、与规格说明一致，且任务分解得当。

**派发时机（Dispatch after）：** 完整计划写完之后。

```
Subagent (general-purpose):
  description: "Review plan document"
  prompt: |
    你是一位计划文档评审者。请验证这份计划是否完整、是否已具备实施条件。

    **待评审的计划（Plan to review）：** [PLAN_FILE_PATH]
    **用于对照的规格说明（Spec for reference）：** [SPEC_FILE_PATH]

    ## 检查项

    | 类别 | 需要查看的内容 |
    |------|----------------|
    | 完整性（Completeness） | TODO、占位符、未完成的任务、缺失的步骤 |
    | 与规格一致（Spec Alignment） | 计划覆盖规格说明中的全部需求，无明显的范围蔓延 |
    | 任务分解（Task Decomposition） | 任务边界清晰，步骤可执行 |
    | 可落地性（Buildability） | 工程师能否照着这份计划走完而不卡住？ |

    ## 尺度把握（Calibration）

    **只标记会在实施阶段真正引发问题的内容。**
    实施者做错了东西、或中途卡住，属于问题。
    措辞细节、风格偏好、"锦上添花"式的建议，不属于问题。

    除非存在严重缺口——遗漏了规格说明中的需求、步骤互相矛盾、出现占位符内容、
    或任务含糊到无法执行——否则都应给出通过（Approve）。

    ## 输出格式

    ## 计划评审（Plan Review）

    **状态（Status）：** 通过（Approved）| 发现问题（Issues Found）

    **问题（Issues，若有）：**
    - [任务 X，步骤 Y]：[具体问题] - [为什么它对实施很重要]

    **建议（Recommendations，仅供参考，不阻塞通过）：**
    - [改进建议]
```

**评审者返回：** 状态（Status）、问题（Issues，若有）、建议（Recommendations）
