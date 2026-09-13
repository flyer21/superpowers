#!/usr/bin/env bash
# Tests for the SDD workspace: scripts/sdd-workspace resolves a self-ignoring,
# PER-PLAN working-tree directory for SDD artifacts, and the SDD scripts write
# into their plan's directory. The task-brief cases also cover the task-heading
# shapes it accepts: labeled, bare, and phase-scoped ids.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SDD_SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

FAILURES=0
TEST_ROOT=""

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}

main() {
    echo "=== Test: sdd-workspace ==="

    TEST_ROOT="$(mktemp -d)"
    trap cleanup EXIT

    # Resolve repo to its physical path so string comparisons match the
    # helper's output (git rev-parse --show-toplevel resolves symlinks; on
    # macOS mktemp lives under /var -> /private/var).
    git init -q -b main "$TEST_ROOT/repo"
    local repo
    repo="$(cd "$TEST_ROOT/repo" && git rev-parse --show-toplevel)"

    cat > "$repo/plan-a.md" <<'PLAN'
# Plan A

## Task 1: First thing

Do the first thing.
PLAN
    cat > "$repo/plan-b.md" <<'PLAN'
# Plan B

## Task 1: Other thing

Do the other thing.
PLAN

    # --- argument validation ---
    local rc=0
    (cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "sdd-workspace without a plan errors with exit 2"
    else
        fail "sdd-workspace without a plan errors with exit 2"
        echo "    exit: $rc"
    fi

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" no-such-plan.md >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "sdd-workspace with a missing plan file errors with exit 2"
    else
        fail "sdd-workspace with a missing plan file errors with exit 2"
        echo "    exit: $rc"
    fi

    # --- per-plan resolution ---
    local dir_a dir_b
    dir_a="$(cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" plan-a.md)"
    dir_b="$(cd "$repo" && "$SDD_SCRIPTS/sdd-workspace" plan-b.md)"

    if [[ "$dir_a" == "$repo/.superpowers/sdd/plan-a" ]]; then
        pass "prints <repo-root>/.superpowers/sdd/<plan-basename>"
    else
        fail "prints <repo-root>/.superpowers/sdd/<plan-basename>"
        echo "    got: $dir_a"
    fi

    if [[ "$dir_a" != "$dir_b" && -d "$dir_a" && -d "$dir_b" ]]; then
        pass "two plans resolve to two distinct directories"
    else
        fail "two plans resolve to two distinct directories"
        echo "    a: $dir_a"
        echo "    b: $dir_b"
    fi

    if [[ -f "$repo/.superpowers/sdd/.gitignore" && "$(cat "$repo/.superpowers/sdd/.gitignore")" == "*" ]]; then
        pass "self-ignoring .gitignore created at .superpowers/sdd/ with '*'"
    else
        fail "self-ignoring .gitignore created at .superpowers/sdd/ with '*'"
    fi

    printf 'x\n' > "$dir_a/artifact.md"
    local status
    status="$(cd "$repo" && git status --porcelain)"
    # plan-a.md/plan-b.md are intentionally untracked fixture files; only the
    # workspace must be invisible.
    if [[ "$status" != *".superpowers"* ]]; then
        pass "workspace invisible to git status"
    else
        fail "workspace invisible to git status"
        echo "    status: $status"
    fi

    ( cd "$repo" && git add -A )
    local staged
    staged="$(cd "$repo" && git diff --cached --name-only)"
    if [[ "$staged" != *".superpowers"* ]]; then
        pass "git add -A does not stage the workspace"
    else
        fail "git add -A does not stage the workspace"
        echo "    staged: $staged"
    fi

    # --- task-brief lands in its plan's directory ---
    local brief_out brief_path
    brief_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-a.md 1)"
    brief_path="$(printf '%s\n' "$brief_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
    if [[ "$brief_path" == "$repo/.superpowers/sdd/plan-a/task-1-brief.md" ]]; then
        pass "task-brief writes its brief under the plan's workspace"
    else
        fail "task-brief writes its brief under the plan's workspace"
        echo "    got: $brief_path"
    fi

    # --- task-brief resolves the plan's own task-id shapes ---
    cat > "$repo/plan-ids.md" <<'PLAN'
# Plan with phases

## 1. Background

Not a task.

## 阶段 C1：生命周期

### 任务 C1-1：空闲超时

改 server.cjs 的空闲超时。

```bash
### 任务 C1-9：围栏里的假标题
```

### C1-2 — 服务端死亡可见

加一个墓碑页。

## 阶段 C2：其他

### 任务 C2-1：别的

不相干的内容。
PLAN

    local ids_path ids_text
    local ids_out
    ids_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-ids.md C1-2)"
    ids_path="$(printf '%s\n' "$ids_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
    if [[ "$ids_path" == "$repo/.superpowers/sdd/plan-ids/task-C1-2-brief.md" ]]; then
        pass "task-brief takes a phase-scoped task id and names the brief after it"
    else
        fail "task-brief takes a phase-scoped task id and names the brief after it"
        echo "    got: $ids_path"
    fi

    ids_text="$(cat "$repo/.superpowers/sdd/plan-ids/task-C1-2-brief.md")"
    if [[ "$ids_text" == *"墓碑"* && "$ids_text" != *"C2-1"* ]]; then
        pass "a bare-id brief stops at the next phase heading"
    else
        fail "a bare-id brief stops at the next phase heading"
        echo "    brief: $ids_text"
    fi

    (cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-ids.md C1-1 >/dev/null)
    ids_text="$(cat "$repo/.superpowers/sdd/plan-ids/task-C1-1-brief.md")"
    if [[ "$ids_text" == *"空闲超时"* && "$ids_text" == *"围栏里的假标题"* && "$ids_text" != *"墓碑"* ]]; then
        pass "a labeled phase-scoped brief keeps fenced lines and stops at the next task heading"
    else
        fail "a labeled phase-scoped brief keeps fenced lines and stops at the next task heading"
        echo "    brief: $ids_text"
    fi

    cat > "$repo/plan-num.md" <<'PLAN'
# Plan that numbers its own sections

## 1. Overview

Not a task.

### 任务 1：真正的任务

任务正文。
PLAN
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-num.md 1 >/dev/null)
    ids_text="$(cat "$repo/.superpowers/sdd/plan-num/task-1-brief.md")"
    if [[ "$ids_text" == *"真正的任务"* && "$ids_text" != *"Overview"* ]]; then
        pass "a labeled heading wins over a same-numbered section heading"
    else
        fail "a labeled heading wins over a same-numbered section heading"
        echo "    brief: $ids_text"
    fi

    # A controller that only knows the task's ordinal still reaches a
    # phase-scoped id: `task-brief PLAN 2` resolves `### C1-2 — …`.
    ids_out="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-ids.md 2)"
    ids_path="$(printf '%s\n' "$ids_out" | sed -n 's/^wrote \(.*\): [0-9][0-9]* lines$/\1/p')"
    ids_text="$(cat "$repo/.superpowers/sdd/plan-ids/task-2-brief.md" 2>/dev/null || true)"
    if [[ "$ids_path" == "$repo/.superpowers/sdd/plan-ids/task-2-brief.md" && "$ids_text" == *"墓碑"* ]]; then
        pass "a trailing task number reaches a phase-scoped id"
    else
        fail "a trailing task number reaches a phase-scoped id"
        echo "    got: $ids_path"
        echo "    brief: $ids_text"
    fi

    cat > "$repo/plan-phases.md" <<'PLAN'
# Two phases, same tail number

### 任务 C1-2：第一个阶段的任务 2

甲。

### 任务 C2-2：第二个阶段的任务 2

乙。
PLAN
    local amb_rc=0 amb_err
    amb_err="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-phases.md 2 2>&1 >/dev/null)" || amb_rc=$?
    if [[ "$amb_rc" -eq 3 && "$amb_err" == *"C1-2"* && "$amb_err" == *"C2-2"* ]]; then
        pass "a tail number that fits two phases fails instead of guessing"
    else
        fail "a tail number that fits two phases fails instead of guessing"
        echo "    exit: $amb_rc"
        echo "    stderr: $amb_err"
    fi

    cat > "$repo/plan-steps.md" <<'PLAN'
# Task with a sub-headed step

## Task 1: First thing

Body.

### Step 1: do it

Step body.

## Task 2: Second thing

Other.
PLAN
    (cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-steps.md 1 >/dev/null)
    ids_text="$(cat "$repo/.superpowers/sdd/plan-steps/task-1-brief.md")"
    if [[ "$ids_text" == *"Step body"* && "$ids_text" != *"Other"* ]]; then
        pass "a step sub-heading stays inside its task's brief"
    else
        fail "a step sub-heading stays inside its task's brief"
        echo "    brief: $ids_text"
    fi

    local unknown_rc=0 unknown_err
    unknown_err="$(cd "$repo" && "$SDD_SCRIPTS/task-brief" plan-ids.md Z9 2>&1 >/dev/null)" || unknown_rc=$?
    if [[ "$unknown_rc" -eq 3 && "$unknown_err" == *"C1-1"* ]]; then
        pass "an unknown task id fails with exit 3 and lists the plan's task ids"
    else
        fail "an unknown task id fails with exit 3 and lists the plan's task ids"
        echo "    exit: $unknown_rc"
        echo "    stderr: $unknown_err"
    fi

    # --- review-package takes the plan first and lands in its directory ---
    local git_id=(-c user.email=t@example.com -c user.name=t -c commit.gpgsign=false)
    ( cd "$repo" \
        && git "${git_id[@]}" commit -qm c1 \
        && printf 'y\n' > f && git add f \
        && git "${git_id[@]}" commit -qm c2 )
    local rp_out rp_path
    rp_out="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md HEAD~1 HEAD)"
    rp_path="$(printf '%s\n' "$rp_out" | sed -n 's/^wrote \(.*\): [0-9].*$/\1/p')"
    case "$rp_path" in
        "$repo/.superpowers/sdd/plan-a/review-"*.diff)
            pass "review-package writes its diff under the plan's workspace" ;;
        *)
            fail "review-package writes its diff under the plan's workspace"
            echo "    got: $rp_path"
            ;;
    esac

    rc=0
    (cd "$repo" && "$SDD_SCRIPTS/review-package" HEAD~1 HEAD >/dev/null 2>&1) || rc=$?
    if [[ "$rc" -eq 2 ]]; then
        pass "review-package without a plan errors with exit 2"
    else
        fail "review-package without a plan errors with exit 2"
        echo "    exit: $rc"
    fi

    local rp_explicit
    rp_explicit="$(cd "$repo" && "$SDD_SCRIPTS/review-package" plan-a.md HEAD~1 HEAD "$TEST_ROOT/explicit.diff")"
    if [[ -s "$TEST_ROOT/explicit.diff" && "$rp_explicit" == *"$TEST_ROOT/explicit.diff"* ]]; then
        pass "review-package honors an explicit OUTFILE"
    else
        fail "review-package honors an explicit OUTFILE"
        echo "    got: $rp_explicit"
    fi

    # --- Worktree isolation: a linked worktree resolves its own workspace ---
    local wt="$TEST_ROOT/wt"
    ( cd "$repo" && git worktree add -q "$wt" -b wt-feature )
    local wt_root wt_dir
    wt_root="$(cd "$wt" && git rev-parse --show-toplevel)"
    wt_dir="$(cd "$wt" && "$SDD_SCRIPTS/sdd-workspace" plan-a.md)"
    if [[ "$wt_dir" == "$wt_root/.superpowers/sdd/plan-a" && "$wt_dir" != "$dir_a" ]]; then
        pass "linked worktree resolves its own distinct workspace"
    else
        fail "linked worktree resolves its own distinct workspace"
        echo "    main: $dir_a"
        echo "    wt:   $wt_dir"
    fi

    printf 'y\n' > "$wt_dir/artifact.md"
    local wt_status
    wt_status="$(cd "$wt" && git status --porcelain)"
    if [[ "$wt_status" != *".superpowers"* ]]; then
        pass "worktree workspace invisible to git status"
    else
        fail "worktree workspace invisible to git status"
        echo "    status: $wt_status"
    fi

    echo ""
    if [[ "$FAILURES" -ne 0 ]]; then
        echo "FAILED: $FAILURES assertion(s)."
        exit 1
    fi
    echo "PASS"
}

main "$@"
