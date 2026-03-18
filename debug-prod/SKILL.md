---
name: debug-prod
description: Investigate a production incident or live bug. Follows mitigation-first protocol — stops the bleeding before investigating, then uses the observability funnel (metrics → traces → logs) to find root cause. Produces a structured findings report and optional postmortem.
argument-hint: [description of the issue]
---

# Production Debugging

Systematic production incident investigation. Mitigation comes before root cause — stop the bleeding first, then investigate why.

## When to Use

- Something is broken or degraded in production right now
- Users are reporting errors or unexpected behavior in a live environment
- An alert fired and you need to understand what's happening
- You want to do a structured post-incident investigation

## Iron Laws

1. **Mitigate before you investigate.** Reducing user impact takes priority over finding root cause.
2. **Preserve evidence before changing anything.** Capture logs, traces, and metrics snapshots before rolling back or restarting.
3. **Never guess — instrument and observe.** Form a hypothesis, then get evidence. Never propose a fix based on intuition alone.
4. **Reproduce before fixing.** If you cannot trigger the problem reliably, you cannot verify the fix.
5. **Protect context window.** All log output goes to a file. Never dump raw logs inline — pipe through `grep`/`tail` and show only relevant lines.
6. **Clean before fixing.** Run `git restore .` to remove all debug instrumentation before implementing the fix.

---

## Phase 1 — Triage and Mitigation (First 5 Minutes)

**Assess blast radius:**
- How many users/requests are affected? (error rate, not absolute count)
- Which services, endpoints, or features are impacted?
- Is the issue getting worse, stable, or recovering on its own?

**Immediate mitigation options — evaluate in order:**
1. **Rollback** recent deployment if the issue started after a deploy
2. **Feature flag** to disable the broken feature
3. **Traffic reroute** away from the affected service/instance
4. **Scale out** if the issue is load-related
5. **Restart** as a last resort (destroys evidence — capture logs first)

**Preserve evidence before any mitigation:**
```bash
# Save current error logs to file before rollback/restart
grep "ERROR\|FATAL\|Exception" <log-source> > /tmp/incident-evidence.txt
```

State your mitigation decision and rationale before proceeding to investigation.

---

## Phase 2 — Signal Correlation (Minutes 5–30)

Work through the observability funnel: **Metrics → Traces → Logs**

### Step 1: Metrics — What changed and when?
- Check error rate, latency (p50/p95/p99), and saturation dashboards
- Find the exact timestamp when the incident started
- Look for any correlated metric changes (memory, CPU, DB connections, cache hit rate)
- Cross-reference with deployment timestamps:

```bash
# Check recent deployments/commits relative to incident start time
git log --oneline --since="2 hours ago"
```

### Step 2: Traces — Where is the failure?
- Pull distributed traces for failing requests from the incident window
- Find which service, operation, or span is erroring or slow
- Note the trace ID — use it to correlate logs across services

### Step 3: Logs — What exactly happened?
- Use the trace ID to extract correlated logs:
```bash
grep "<trace-id>" <log-file> > /tmp/trace-logs.txt
cat /tmp/trace-logs.txt
```
- Find the exact error message, stack trace, and request payload
- Note the first occurrence timestamp — does it predate the alert?

---

## Phase 3 — Root Cause Investigation (Minutes 30–120)

### Step 1: Form Hypotheses

Generate 3–5 ranked hypotheses based on the signal correlation evidence. Format each as:

```
H1 [most likely]: <specific, testable claim about root cause>
   Evidence for: <what supports this>
   Evidence against: <what would refute this>

H2: ...
H3: ...
```

### Step 2: Instrument at Layer Boundaries

For each active hypothesis, add targeted log instrumentation at the relevant layer boundary. Tag every debug log with the hypothesis number:

```
[DEBUG-PROD][H1-db-connection-pool] connections_active=47 connections_max=50
[DEBUG-PROD][H2-cache-miss] key="user:1234" result=miss latency_ms=450
```

All output goes to file — never inline:
```bash
# Route instrumented output to file
<your-service-start-command> 2>&1 | tee /tmp/debug-prod.log &
grep '\[DEBUG-PROD\]\[H1' /tmp/debug-prod.log
```

> **Heisenbug signal:** If adding instrumentation changes the behavior, you likely have a race or timing issue — pivot to timing analysis.

### Step 3: Trace Backward to Origin

Starting from the observed symptom, trace backward:
- What called the failing function/service?
- What was the input/state at each layer boundary?
- Keep asking "what triggered this?" until you reach the original cause

Stop at the **original trigger**, not just the first place the error is visible.

### Step 4: Confirm the Root Cause

Before moving to fix:
- State the confirmed root cause in one sentence
- List the evidence that proves it
- Eliminate the other hypotheses with counter-evidence

If 3+ hypotheses have been tested and failed → you likely have a systemic/architectural issue. Stop patching and escalate.

---

## Phase 4 — Fix

```bash
# Remove all debug instrumentation first
git restore .

# Implement the minimal fix targeting the root cause
# Run the reproduction case to confirm red → green
# Run full test suite for regressions
```

Commit message structure:
```
fix: <what was broken>

Root cause: <one sentence>
Evidence: <key signal that confirmed it>
Reproduction: <how to trigger it>
Fix: <what was changed and why>
```

---

## Phase 5 — Recovery and Verification

- Gradually restore normal traffic while watching error rate and latency
- Confirm the alert resolves and metrics return to baseline
- Watch for 10+ minutes before declaring the incident resolved

---

## Phase 6 — Findings Report

Generate a structured report at `.claude/incidents/<date>-<slug>.md`:

```markdown
# Incident: <title>

**Date:** <date>
**Severity:** SEV1 / SEV2 / SEV3
**Duration:** <start time> → <end time> (~N minutes)
**Status:** Resolved / Monitoring / Ongoing

## Summary
<2–3 sentences: what happened, who was affected, how it was resolved>

## Timeline
| Time | Event |
|------|-------|
| HH:MM | Alert fired / issue first reported |
| HH:MM | Investigation started |
| HH:MM | Root cause identified |
| HH:MM | Fix deployed |
| HH:MM | Incident resolved |

## Root Cause
<Clear statement of root cause>

## Contributing Factors
- <Factor 1>
- <Factor 2>

## Evidence
- <Metric/trace/log that confirmed root cause>

## Fix
<What was changed and why>

## Action Items
| Item | Owner | Due |
|------|-------|-----|
| Add monitoring for X | | |
| Update runbook for Y | | |
| Fix underlying issue Z | | |
```

For SEV1/SEV2, a full postmortem (5 Whys, blameless analysis) should follow within 24–48 hours.

---

## Quick Reference

| Symptom Pattern | First Check |
|---|---|
| Error rate spike after deploy | `git log` recent commits, rollback candidate |
| Gradual latency increase | Database connections, N+1 queries, memory leak |
| Intermittent errors | Race condition, shared mutable state, async ordering |
| Single service down | Health checks, OOM, disk space, dependency timeouts |
| All services degraded | Shared dependency (DB, cache, message queue, DNS) |
| Only affecting some users | Feature flag state, A/B bucket, regional routing |
