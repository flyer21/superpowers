# 修复后的复检清单

属于 superpowers:subagent-driven-development。修复波里的一轮修复完成之后、由你本人（控制器）对**修复范围**做复检时使用。

输入：`bash scripts/review-package PLAN_FILE FIX_BASE HEAD` 生成的、只覆盖修复范围的 diff 包（FIX_BASE = 上次自审看到的 HEAD）、上自审记入账本的未决发现清单、计划文件（或规格）。

## 复检范围：只审修复 diff

- 逐条裁决未决发现为**已解决**或**未解决**，依据是修复 diff 本身，裁决结果逐条记入账本
- 只标记修复 diff 中**新引入**的破坏——不要漫游到范围外的代码
- 修复 diff 中的新 Critical / Important 破坏加入未决发现清单
- 范围外的观察记入账本作为延后 Minor，它们不扩展修复波

## 收尾判断

- 全部未决发现已解决且无新破坏 → 修复波结束，进入完成（[references/final-review.md](references/final-review.md)）
- 仍有未决发现 → 按 [references/fix-loop.md](references/fix-loop.md) 的轮次上限与断路器处理：继续下一轮，或到达上限时逐条裁决并记入账本

## 要对抗的偏差

- 不要因为"修复很小"就跳过复检：未复检的修复是回归进入分支的方式
- 不要重跑实现者已经跑过的全套测试；只有当某段代码引发了具体疑虑时才跑一次聚焦测试，并把命令与结果记入账本
