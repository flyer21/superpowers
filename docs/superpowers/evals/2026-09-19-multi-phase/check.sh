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

[ "$fail" -eq 0 ] && echo "ALL CHECKS PASS" || echo "CHECKS FAILED"
exit "$fail"
