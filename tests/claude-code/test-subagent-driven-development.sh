#!/usr/bin/env bash
# Test: subagent-driven-development skill
# Verifies that the skill is loaded and follows correct workflow
#
# No drill coverage: this test asks the agent to *describe* SDD (string-
# matches its verbal explanation against expected keywords like
# "self-review", "skeptical", "worktree", "Step 1", "loop"). Drill scenarios
# test behavior (real subagent dispatch, plan-following, review loops),
# not description-recall. Kept by design.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

CLAUDE_PROMPT_TIMEOUT="${CLAUDE_PROMPT_TIMEOUT:-90}"

echo "=== Test: subagent-driven-development skill ==="
echo ""

# Test 1: Verify skill can be loaded
echo "Test 1: Skill loading..."

output=$(run_claude "What is the subagent-driven-development skill? Describe its key steps briefly." "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "subagent-driven-development\|Subagent-Driven Development\|Subagent Driven" "Skill is recognized"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "Load Plan\|read.*plan\|extract.*tasks\|通读计划\|读取计划" "Mentions loading plan"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 2: Verify whole-branch self-review covers both spec and quality
echo "Test 2: Whole-branch self-review scope..."

output=$(run_claude "In the subagent-driven-development skill, does the whole-branch self-review cover both spec compliance and code quality? Answer using exactly this structure:
Covers spec compliance: <yes or no>
Covers code quality: <yes or no>" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "Covers spec compliance:.*yes" "Covers spec compliance"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "Covers code quality:.*yes" "Covers code quality"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 3: Verify implementers do NOT self-review (whole-branch self-review model)
echo "Test 3: No implementer self-review..."

output=$(run_claude "In the subagent-driven-development skill, do implementers self-review before handoff? Answer using exactly this structure:
Implementer self-review required: <yes or no>
Whole-branch self-review by controller: <yes or no>" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "Implementer self-review required:.*no" "Implementers do not self-review"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "Whole-branch self-review by controller:.*yes" "Controller does whole-branch self-review"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 4: Verify plan is read once
echo "Test 4: Plan reading efficiency..."

output=$(run_claude "In subagent-driven-development, how many times should the controller read the plan file? When does this happen?" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "once\|one time\|single" "Read plan once"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "Step 1\|beginning\|start\|Load Plan" "Read at beginning"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 5: Verify controller self-review is skeptical
echo "Test 5: Controller self-review mindset..."

output=$(run_claude "In subagent-driven-development, what is the controller's attitude when doing the whole-branch self-review? Should they trust the implementer's report?" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "not.*trust\|don't trust\|skeptical\|verify.*independently\|suspiciously\|不.*信任\|独立核实\|怀疑" "Controller is skeptical"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "read.*code\|inspect.*code\|verify.*code\|read.*diff\|trust.*diff\|读.*diff\|读.*代码\|核实" "Controller reads code"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 6: Verify fix wave after self-review
echo "Test 6: Fix wave after self-review..."

output=$(run_claude "In subagent-driven-development, what happens if the whole-branch self-review finds issues? Is there a fix process?" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "fix.*wave\|修复波\|one.*fixer\|一个.*修复\|single.*subagent" "Fix wave with single fixer"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "three.*round\|三轮\|breaker\|熔断\|circuit" "Fix wave has limits"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 7: Verify full task text is provided
echo "Test 7: Task context provision..."

output=$(run_claude "In subagent-driven-development, how does the controller provide task information to the implementer subagent? Answer using exactly this structure:
Controller provides: <directly or by file>
Implementer must read plan file: <yes or no>" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "provide.*directly\|full.*text\|paste\|include.*prompt" "Provides text directly"; then
    : # pass
else
    exit 1
fi

if assert_contains "$output" "Implementer must read plan file:.*no" "Doesn't make subagent read file"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 8: Verify worktree requirement
echo "Test 8: Worktree requirement..."

output=$(run_claude "What workflow skills are required before using subagent-driven-development? List any prerequisites or required skills." "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "using-git-worktrees\|worktree" "Mentions worktree requirement"; then
    : # pass
else
    exit 1
fi

echo ""

# Test 9: Verify main branch warning
echo "Test 9: Main branch red flag..."

output=$(run_claude "In subagent-driven-development, is it okay to start implementation directly on the main branch?" "$CLAUDE_PROMPT_TIMEOUT")

if assert_contains "$output" "worktree\|feature.*branch\|not.*main\|never.*main\|avoid.*main\|don't.*main\|consent\|permission" "Warns against main branch"; then
    : # pass
else
    exit 1
fi

echo ""

echo "=== All subagent-driven-development skill tests passed ==="