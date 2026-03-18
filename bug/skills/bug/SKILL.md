---
name: bug
description: Investigate, reproduce, and fix a bug using a structured workflow. Captures a complete bug report, reproduces the issue reliably, finds the true root cause, writes a failing test before fixing, verifies the fix, and optionally files a well-formed GitHub issue.
argument-hint: [description of the bug]
---

# Bug Investigation and Fix

Structured bug workflow: capture → reproduce → root cause → failing test → fix → verify.

## Iron Laws

1. **Reproduce before investigating.** You cannot fix a bug you cannot trigger reliably.
2. **Find root cause before writing any fix.** Symptom fixes are failure. Three failed fix attempts means you haven't found the real cause yet.
3. **Write a failing test before the fix.** The test proves your diagnosis is correct and prevents regression.
4. **One hypothesis at a time.** Test the most likely cause with the smallest possible change. Never change multiple things simultaneously.
5. **Verify with the original repro — not just the unit test.** The user-visible symptom must be confirmed resolved.

---

## Phase 1 — Capture

Collect everything needed to understand and reproduce the issue:

**Required information:**
- What is the observed behavior?
- What is the expected behavior?
- Exact reproduction steps (numbered, specific)
- Environment: OS, version, browser, deployment tier (dev/staging/prod)
- Error messages, stack traces, or logs (exact text, not paraphrased)
- When did it start? Is it consistent or intermittent?
- Impact: how many users/requests affected? Any workaround?

If any of the above are missing, ask before proceeding.

**Check recent changes:**
```bash
git log --oneline -15
git diff HEAD~5 -- <relevant-files>
```

If the bug is a regression ("it worked before"), jump directly to **Regression Detection** below.

---

## Phase 2 — Reproduce

Establish a reliable reproduction before any analysis.

**Reproduction ladder** (try from top to bottom):
1. Failing unit test (fastest, most debuggable)
2. Standalone script that triggers the error
3. `curl` / API call sequence
4. Manual UI steps
5. Loop 50× to catch intermittent failures

Document the exact reproduction command/steps. If you cannot reproduce it consistently, do not proceed to fix — investigate the non-determinism first.

**For intermittent bugs:**
- Loop to find frequency: `for i in {1..50}; do <repro-command>; done`
- Look for: shared mutable state, async ordering issues, race conditions, timing dependencies, test order pollution

---

## Phase 3 — Root Cause Investigation

### Step 1: Form Hypotheses

Generate 3–5 ranked hypotheses. For each:
```
H1 [most likely]: <specific, falsifiable claim>
   Evidence for: <what points here>
   Evidence against: <what would refute this>
```

### Step 2: Instrument and Observe

Add hypothesis-tagged logging at the relevant code boundaries. Route all output to file:

```bash
# All debug output to file — never flood inline
<run-command> > /tmp/bug-debug.log 2>&1
grep '\[BUG-H1\]' /tmp/bug-debug.log
```

Tag every debug log with the hypothesis:
```python
print(f"[BUG-H1-null-user] user={user!r} session={session_id}")
```

### Step 3: Trace Backward to Origin

Starting from the symptom, ask "what caused this?" at each layer:
- What was the unexpected value/state?
- Where did that value come from?
- What should have validated or prevented it?
- Keep tracing until you reach the original trigger

### Step 4: Confirm Root Cause

Before writing any fix, state:
- **Root cause (one sentence):** ...
- **Evidence that proves it:** ...
- **Why the other hypotheses are ruled out:** ...

If 3+ hypotheses have been tested and eliminated → stop. You are fixing symptoms. Step back and re-examine your mental model of the system.

---

## Phase 4 — Write Failing Test First

Before touching production code, write a test that:
1. Reproduces the exact bug
2. Fails with the current code
3. Will pass only when the root cause is fixed (not just the symptom)

```bash
# Verify the test fails before the fix
<test-command> -- <test-name>
# Expected: FAIL
```

Commit the failing test separately if useful:
```
test: add failing test for <bug description>
```

---

## Phase 5 — Fix

```bash
# Clean instrumentation first
git restore .

# Implement the minimal fix at the root cause
# Do not fix anything the user didn't ask about
# Do not refactor surrounding code
```

The fix should be the smallest change that addresses the root cause. If the fix is complex, that's a signal you haven't found the true root cause yet.

---

## Phase 6 — Verify

**Verification checklist:**
- [ ] The failing test now passes
- [ ] The original reproduction steps no longer trigger the bug
- [ ] Full test suite passes (no regressions introduced)
- [ ] For intermittent bugs: loop 50× and confirm no occurrences

Do not claim the bug is fixed until all checklist items are confirmed with actual command output.

---

## Phase 7 — File GitHub Issue (Optional)

If the user wants to file a GitHub issue:

```bash
gh issue create \
  --title "<type>: <concise description>" \
  --body "$(cat <<'EOF'
## Description
<What is happening vs. what should happen>

## Reproduction Steps
1. ...
2. ...
3. ...

## Expected Behavior
<What should happen>

## Actual Behavior
<What actually happens, with exact error message>

## Environment
- Version/commit: <sha>
- OS: <os>
- Other: <relevant config>

## Root Cause
<Identified root cause if known>

## Severity
- [ ] Critical (data loss / security)
- [ ] High (feature broken, no workaround)
- [ ] Medium (feature degraded, workaround exists)
- [ ] Low (edge case, cosmetic)
EOF
)" \
  --label "bug"
```

---

## Regression Detection

For bugs where "it worked before":

```bash
# Automated bisect to find the breaking commit
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-sha>

# Git will check out commits — run your repro to mark each
git bisect run <repro-command>

# Bisect will identify the exact breaking commit
git bisect reset
```

Once the breaking commit is found:
- Read its diff: what changed?
- Read its message: was it a "fix" or "refactor" that unintentionally broke this?
- Check if the same pattern exists elsewhere: `git log -S "<removed-code-pattern>"`

---

## Severity Classification

| Severity | Definition | Response |
|---|---|---|
| **Critical** | Data loss, security vulnerability, service down for all users | Fix immediately, consider production incident protocol |
| **High** | Core feature broken, no workaround available | Fix in current cycle |
| **Medium** | Feature degraded but workaround exists | Fix in next cycle |
| **Low** | Edge case, cosmetic, rare occurrence | Backlog |

---

## Commit Message Template

```
fix(<scope>): <concise description of what was wrong>

Root cause: <one sentence>
Reproduction: <minimum steps to trigger>
Fix: <what was changed and why this addresses the root cause>

Fixes #<issue-number>
```
