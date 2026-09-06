#!/usr/bin/env bash
# Test: subagent-driven-development skill
# Verifies that the skill is loaded and follows the fork's workflow:
# fresh subagent per task, no per-task self-review, and one whole-branch
# self-review by the controller after every task has completed (it replaces
# any external reviewer dispatch), followed by a single fix wave that the
# controller itself re-checks.
#
# No drill coverage: this test asks the agent to *describe* SDD (string-
# matches its verbal explanation against expected keywords like
# "whole-branch self-review", "no second fix wave", "worktree"). Drill
# scenarios test behavior (real subagent dispatch, plan-following, review
# loops), not description-recall. Kept by design.
#
# Note: prompts and assertions are in Chinese to match this fork's Chinese
# skill content. Structured prompts ask the model to copy each line verbatim
# and only replace X with an answer, so label-value assertions stay exact.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

CLAUDE_PROMPT_TIMEOUT="${CLAUDE_PROMPT_TIMEOUT:-90}"

echo "=== Test: subagent-driven-development skill ==="
echo ""

# Test 1: Verify skill can be loaded and names the new-model flow
echo "Test 1: Skill loading..."

output=$(run_claude "subagent-driven-development 是什么技能？请简述它的关键流程。" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "subagent-driven-development\|Subagent-Driven Development\|Subagent Driven\|整分支自审" "Skill is recognized"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "全新的实现子代理\|每个任务一个全新子代理\|每个任务.*全新.*子代理" "Mentions fresh subagent per task"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 2: Verify the whole-branch self-review timing and scope
echo "Test 2: Whole-branch self-review timing and scope..."

output=$(run_claude "关于 subagent-driven-development 的整分支自审，请逐字抄写下面每一行并把 X 替换成答案（是 或 否），不要改动其它内容：
整分支自审发生在所有任务执行完成之后：X
自审覆盖规格符合性：X
自审覆盖代码质量：X" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "整分支自审发生在所有任务执行完成之后[ ]*[：:][ ]*是" "Self-review after all tasks"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "自审覆盖规格符合性[ ]*[：:][ ]*是" "Self-review covers spec compliance"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "自审覆盖代码质量[ ]*[：:][ ]*是" "Self-review covers code quality"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 3: Verify per-task implementer self-review is gone, and the
#         whole-branch self-review replaces the external reviewer
echo "Test 3: No per-task self-review; self-review replaces external review..."

output=$(run_claude "关于 subagent-driven-development 中的自审安排，请逐字抄写下面每一行并把 X 替换成答案（是 或 否），不要改动其它内容：
要求每个实现者子代理在汇报前自审自己的 diff：X
全部任务完成后的整分支自审取代外派审查子代理：X" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "要求每个实现者子代理在汇报前自审自己的 diff[ ]*[：:][ ]*否" "No per-task implementer self-review"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "全部任务完成后的整分支自审取代外派审查子代理[ ]*[：:][ ]*是" "Self-review replaces external review"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 4: Verify the plan file is read once up front, not per task
echo "Test 4: Plan reading efficiency..."

output=$(run_claude "关于 subagent-driven-development 如何阅读计划文件，请逐字抄写下面每一行并把 X 替换成答案（是 或 否），不要改动其它内容：
控制器在开始时通读整份计划文件：X
控制器在派发每个任务前重新通读整份计划：X" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "控制器在开始时通读整份计划文件[ ]*[：:][ ]*是" "Read plan once up front"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "控制器在派发每个任务前重新通读整份计划[ ]*[：:][ ]*否" "No per-task plan re-read"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 5: Verify the self-review verifies against the code, not the report
echo "Test 5: Self-review verifies the code, not the report..."

output=$(run_claude "关于 subagent-driven-development 中控制器对整条分支的自审，请逐字抄写下面每一行并把 X 替换成答案（是 或 否），不要改动其它内容：
控制器自审直接信任实现者的汇报：X
控制器自审亲自阅读分支的 diff/代码：X" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "控制器自审直接信任实现者的汇报[ ]*[：:][ ]*否" "Does not trust the report"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "控制器自审亲自阅读分支的 diff/代码[ ]*[：:][ ]*是" "Reads the actual code/diff"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 6: Verify findings enter one fix wave, re-checked by the controller,
#         with no second fix wave
echo "Test 6: One fix wave, controller re-check, no second wave..."

output=$(run_claude "关于 subagent-driven-development 中发现问题的处理，请逐字抄写下面每一行并把 X 替换成答案（是 或 否），不要改动其它内容：
自审发现的问题进入一次修复波：X
实现者修复后由控制器亲自复检修复 diff：X
修复波存在第二轮：X" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "自审发现的问题进入一次修复波[ ]*[：:][ ]*是" "Findings enter a fix wave"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "实现者修复后由控制器亲自复检修复 diff[ ]*[：:][ ]*是" "Controller re-checks the fix diff"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "修复波存在第二轮[ ]*[：:][ ]*否" "No second fix wave"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 7: Verify task information goes through the task brief, and the
#         implementer never reads the whole plan file
echo "Test 7: Task context provision via task brief..."

output=$(run_claude "关于 subagent-driven-development 如何向实现者提供任务信息，请逐字抄写下面每一行并把 X 替换成答案（是 或 否），不要改动其它内容：
任务信息通过任务简报文件提供给实现者：X
实现者必须通读整个计划文件：X" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "任务信息通过任务简报文件提供给实现者[ ]*[：:][ ]*是" "Provides task text via task brief"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "实现者必须通读整个计划文件[ ]*[：:][ ]*否" "Implementer does not read the whole plan file"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 8: Verify worktree requirement
echo "Test 8: Worktree requirement..."

output=$(run_claude "使用 subagent-driven-development 技能之前需要哪些前置技能或准备？请列出。" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "using-git-worktrees\|worktree\|隔离.*工作区\|git worktree" "Mentions worktree requirement"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 9: Verify main branch warning
echo "Test 9: Main branch red flag..."

output=$(run_claude "在 subagent-driven-development 中，可以直接在 main 或 master 分支上开始实施吗？" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "绝不在.*main\|不能.*直接.*main\|不要在 main\|main/master 之外\|征得.*同意\|明确同意\|worktree" "Warns against main branch"; then
    : # pass
else
    exit 1
fi

echo ""

echo "=== All subagent-driven-development skill tests passed ==="
