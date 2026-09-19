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

# 任务 1（基线）：改动前，5 个技能都没有“顺序阶段”支持——这些是记录基线用的反向断言
check "基线：brainstorming 无顺序阶段指引" bash -c '! grep -q "顺序阶段" skills/brainstorming/SKILL.md'
check "基线：writing-plans 无路线图字段" bash -c '! grep -q "路线图（Roadmap）" skills/writing-plans/SKILL.md'
check "基线：finishing 无路线图检测" bash -c '! grep -q "路线图检测" skills/finishing-a-development-branch/SKILL.md'

[ "$fail" -eq 0 ] && echo "ALL CHECKS PASS" || echo "CHECKS FAILED"
exit "$fail"
