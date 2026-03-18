---
name: review-pr
description: Review a pull request or set of code changes. Filters to issues introduced by this PR (not pre-existing), scores confidence, and produces a prioritized report with severity tiers. Requires user approval before posting anything to GitHub.
argument-hint: [PR number or branch name]
---

# Code Review

Structured pull request review. Focuses on issues *introduced* by this change, not pre-existing ones. Produces a prioritized report — nothing is posted to GitHub without your approval.

## When to Use

- Reviewing a PR before merge
- Reviewing your own code before opening a PR
- Security or correctness audit of a specific diff
- Reviewing code after implementing a feature (incremental review)

## What NOT to Do

- Do not flag pre-existing issues the author didn't touch
- Do not block on style/formatting — that's what linters are for
- Do not rewrite code to a personal preference
- Do not list speculative risks without evidence
- Do not post anything to GitHub without explicit user approval

---

## Phase 1 — Context Gathering (Before Looking at Code)

Read the following before examining any diff:

1. **PR description** — What is this change trying to do?
2. **Linked issues** — What problem is being solved?
3. **Commit messages** — What was the author's intent at each step?
4. **CLAUDE.md / CONTRIBUTING.md** — Any project-specific conventions?

```bash
# Get PR metadata
gh pr view <pr-number>

# Get the diff
gh pr diff <pr-number>

# Get list of changed files
gh pr diff <pr-number> --name-only
```

If the PR is a draft, has `WIP` in the title, or is already closed — ask the user before proceeding.

For PRs with >400 lines changed: flag this to the user and suggest splitting. Proceed only with their confirmation.

---

## Phase 2 — Filter to What This PR Introduced

Only report issues that are new in this diff. Use `git blame` to confirm an issue was introduced by this change, not inherited from existing code:

```bash
# Check who introduced a specific line
git log -p --follow -S "<suspicious code>" -- <file>

# Security regression check: was this code previously removed for a reason?
git log --all --oneline -S "<removed-code-pattern>"
```

If a suspicious pattern exists elsewhere in the codebase and is not new here, mark it as `pre-existing` and skip it (or note it separately as a background observation).

---

## Phase 3 — Review Dimensions

Work through these categories in priority order:

### 1. Security (Highest Priority)
- **Injection:** SQL, command, LDAP, XPath, template injection
- **Authentication/Authorization:** missing auth checks, privilege escalation, JWT/session issues
- **Sensitive data:** secrets, credentials, or PII in code, logs, or error messages
- **Input validation:** unvalidated user input reaching dangerous operations
- **Cryptography:** weak algorithms, hardcoded keys, insecure random
- **Dependency risk:** new packages added — are they trustworthy, maintained, minimal?

For each finding: state the exploit scenario concretely, not just "this could be insecure."

**Blast radius check for security issues:**
```bash
# How many callers does this modified function have?
grep -rn "<function-name>" --include="*.ts" --include="*.py" --include="*.go" | wc -l
```
If blast radius is high (many callers), escalate severity.

### 2. Correctness
- Logic errors, off-by-one, null/undefined handling
- Async/await correctness, unhandled promise rejections
- Edge cases: empty input, zero, negative numbers, max values
- Error propagation — are errors being swallowed silently?
- Race conditions or shared mutable state

### 3. Performance
- N+1 queries (database calls inside loops)
- Missing indexes for new query patterns
- Unbounded operations (no pagination, no limits)
- Unnecessary blocking operations in async code
- Large payloads loaded entirely into memory

### 4. Maintainability
- Functions doing too much (>30 lines warrants scrutiny)
- Deep nesting (>3 levels)
- Magic numbers/strings without explanation
- Variable/function names that are misleading
- Dead code introduced

### 5. Test Coverage
- Does the happy path have a test?
- Are edge cases and error paths tested?
- Are the test assertions meaningful (not just "it doesn't throw")?
- Was existing test coverage inadvertently broken?

### 6. Error Handling
- Empty catch blocks that silence errors
- Missing `finally` for cleanup operations
- User-facing error messages that leak internal details

### 7. Documentation (Lowest Priority)
- Public API changes without updated docs
- Complex logic with no explanation comment
- Outdated comments that now contradict the code

---

## Phase 4 — Confidence Filtering

Before including a finding in the report, ask:
- Can I point to the exact file + line?
- Can I describe a concrete scenario where this causes a real problem?
- Is my confidence ≥ 80%?

If any answer is no → drop the finding or downgrade to a question/suggestion.

Skip findings that:
- A linter would already catch
- Require speculative future scenarios to be a problem
- Are purely stylistic with no functional impact
- Are pre-existing (not introduced by this PR)

---

## Phase 5 — Build the Review Report

Format findings with severity tiers:

```markdown
## Code Review: <PR title> (#<number>)

**Branch:** `<branch>` → `main`
**Files changed:** N | **Lines:** +X / -Y

---

### 🔴 Blocking — Must fix before merge
Issues that will cause bugs, security vulnerabilities, or data loss.

**[Security] SQL injection in user search** · `src/api/users.ts:47`
Raw user input interpolated into query string. Attacker can extract any table.
```ts
// Current
db.query(`SELECT * FROM users WHERE name = '${req.query.name}'`)
// Fix
db.query('SELECT * FROM users WHERE name = $1', [req.query.name])
```
Confidence: 95%

---

### 🟡 Important — Should fix before merge
Real issues that don't block functionality but create risk.

**[Correctness] Unhandled promise rejection** · `src/jobs/sync.ts:23`
...

---

### 🔵 Nit — Fix if easy, otherwise fine
Minor issues that won't cause problems but improve quality.

**[Maintainability] Magic number** · `src/config.ts:8`
...

---

### 💡 Suggestions
Optional improvements worth considering.

---

### ✅ Positive Observations
<Acknowledge good decisions, clean abstractions, well-tested changes>

---

**Summary:** N blocking · N important · N nits
**Verdict:** ✅ Approve / 🔄 Request Changes / ❓ Comment
```

---

## Phase 6 — Human Approval Before Posting

**Show the full review report to the user first.** Ask:

> "Ready to post this review to GitHub? I can post it as:
> - A review comment (approve / request changes / comment)
> - Inline comments on specific lines
> - Both"

Wait for explicit confirmation. Do not post anything without it.

---

## Phase 7 — Post to GitHub

After approval:

```bash
# Post review with inline comments
gh pr review <pr-number> \
  --request-changes \
  --body "<summary comment>"

# Post an inline comment on a specific line
gh api repos/{owner}/{repo}/pulls/<pr-number>/comments \
  --method POST \
  --field body="<comment>" \
  --field commit_id="<head-sha>" \
  --field path="<file-path>" \
  --field line=<line-number> \
  --field side="RIGHT"
```

---

## Severity Reference

| Tier | Label | Meaning |
|---|---|---|
| 🔴 | **Blocking** | Security vulnerability, data loss risk, broken functionality — fix before merge |
| 🟡 | **Important** | Real bug or risk, should fix but not emergency |
| 🔵 | **Nit** | Minor quality issue, fix if trivial |
| 💡 | **Suggestion** | Optional improvement |
| ✅ | **Praise** | Good work worth acknowledging |
| 👻 | **Pre-existing** | Issue exists but was not introduced by this PR |
