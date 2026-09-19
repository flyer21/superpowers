#!/usr/bin/env bash
# 多阶段设计改动的结构断言（RED→GREEN）
# 用法：bash docs/superpowers/evals/2026-09-19-multi-phase/check.sh
cd "$(dirname "$0")/../../../../" || exit 1
fail=0

check() { # check <名称> <命令...>
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "PASS: $name"
  else
    echo "FAIL: $name"; fail=1
  fi
}

# 任务 2（brainstorming）：顺序阶段 + 路线图
check "brainstorming：两种分解" grep -q "后期阶段的设计依赖前期阶段" skills/brainstorming/SKILL.md
check "brainstorming：路线图小节" grep -q "多阶段路线图（Multi-phase roadmaps）" skills/brainstorming/SKILL.md
check "brainstorming：路线图路径" grep -q "docs/superpowers/roadmaps/YYYY-MM-DD-<topic>-roadmap.md" skills/brainstorming/SKILL.md
check "brainstorming：后续阶段回读" grep -q "必须先回读路线图" skills/brainstorming/SKILL.md
check "brainstorming：自审范围检查" grep -q "整条路线图出现在一份规格" skills/brainstorming/SKILL.md

# 任务 3（writing-plans）：两种拆分 + 计划头部路线图字段
check "writing-plans：每阶段一份计划" grep -q "每个阶段一份计划" skills/writing-plans/SKILL.md
check "writing-plans：计划头部路线图字段" grep -q '路线图（Roadmap）：' skills/writing-plans/SKILL.md
check "writing-plans：不横跨阶段" grep -q "绝不允许一份计划横跨多个阶段" skills/writing-plans/SKILL.md

# 任务 4（执行技能）：向收尾传递阶段上下文
check "executing-plans：交接传递路线图" grep -q "finishing 的路线图检测以此为准" skills/executing-plans/SKILL.md
check "subagent-driven-development：交接传递路线图" grep -q "finishing 的路线图检测以此为准" skills/subagent-driven-development/SKILL.md

# 任务 5（finishing）：第 7 步路线图检测
check "finishing：路线图检测小节" grep -q "路线图检测（Roadmap Check）" skills/finishing-a-development-branch/SKILL.md
check "finishing：状态更新在基分支" grep -q "在基分支上把本阶段标记为" skills/finishing-a-development-branch/SKILL.md
check "finishing：下一阶段提示" grep -q "要现在开始它的头脑风暴吗" skills/finishing-a-development-branch/SKILL.md
check "finishing：无路线图零变化" grep -q "没有路线图信息时" skills/finishing-a-development-branch/SKILL.md

# 任务 6（跨技能一致性）
check "一致性：5 个技能都提到路线图" bash -c 'for f in skills/brainstorming/SKILL.md skills/writing-plans/SKILL.md skills/executing-plans/SKILL.md skills/subagent-driven-development/SKILL.md skills/finishing-a-development-branch/SKILL.md; do grep -q "路线图" "$f" || exit 1; done'
check "一致性：术语不漂移（无 Phase 大写混用为中文语境主词）" bash -c '! grep -rn "多阶段 Phase" skills/'
check "一致性：前后端描述同一交接契约" bash -c 'grep -q "路线图检测以此为准" skills/executing-plans/SKILL.md && grep -q "路线图检测以此为准" skills/subagent-driven-development/SKILL.md && grep -q "路线图检测（Roadmap Check）" skills/finishing-a-development-branch/SKILL.md'

# 补充（规格 §5 收口）：路线图全部完成时的归档建议
check "finishing：全部完成时建议归档" grep -q "并建议你的（人类）搭档归档路线图" skills/finishing-a-development-branch/SKILL.md

[ "$fail" -eq 0 ] && echo "ALL CHECKS PASS" || echo "CHECKS FAILED"
exit "$fail"
