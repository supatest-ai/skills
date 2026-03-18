---
name: agent-readiness
description: Evaluate how ready a codebase is for autonomous AI agent work. Produces a scored report across 11 dimensions with a maturity level and prioritized action plan.
---

# Agent Readiness Assessment

Evaluate how ready a codebase (or full SDLC) is for autonomous AI agent work. Produces a
scored report across all dimensions with a maturity level and prioritized action plan.

## When to use this skill

Invoke when the user wants to:
- Assess whether a repo is ready for AI coding agents (Claude Code, Devin, Cursor, etc.)
- Understand what's blocking autonomous agent productivity
- Get a prioritized plan for making a codebase more agent-ready
- Evaluate a new project before onboarding an agent to it
- Audit the full SDLC for agent-readiness beyond just code

Trigger phrases: "agent readiness", "agent-ready", "how ready is this codebase for agents",
"audit for AI agents", "agent readiness report", `/agent-readiness`

## Background

Agent readiness is the degree to which a codebase and its surrounding SDLC allow an AI agent
to operate autonomously, verify its own work, and avoid catastrophic mistakes.

**The core insight**: The bottleneck isn't model capability — it's infrastructure quality.
Humans adapt to incomplete context and implicit knowledge. Agents cannot.

Research from Factory.ai, Simon Willison, Armin Ronacher, Addy Osmani, and the broader
agentic coding community converges on the same finding: codebases that fail with agents
usually have the same problems — hidden context, no fast feedback loop, and no way to
verify correctness without a human.

## Instructions

When invoked, perform a systematic assessment across all 11 dimensions below. Then produce
a full report (see Output Format). Be thorough — read actual files, check configs, look for
evidence rather than assumptions.

---

## Phase 1: Orient

Before scoring, gather context:

1. Read `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `README.md`, `CONTRIBUTING.md` if they exist
2. Run `ls` / explore top-level structure to understand monorepo vs single repo
3. Check `package.json` / `Cargo.toml` / `pyproject.toml` / etc. for available commands
4. Note the tech stack (language, framework, test runner, linter, bundler)
5. Check git log briefly — how active is this repo? How many contributors?

---

## Phase 2: Score Each Dimension

Score each dimension **1–5** using the criteria below. Always cite specific evidence
(file names, presence/absence of configs, actual command output if available).

---

### Dimension 1: Code Comprehensibility
*Can the agent understand what the code does without a human explaining it?*

Agents read code like a new engineer on day one — they need explicit signals, not tribal
knowledge. Every implicit convention that lives in someone's head is a liability.

**Check:**
- Are there strong, explicit types everywhere? (TypeScript strict mode, typed Python, etc.)
- Are names self-descriptive? (no `data`, `tmp`, `obj`, `handleStuff`)
- Is indirection minimized? (barrel file re-exports, deep inheritance chains, excessive HOCs)
- Are functions small, focused, and named for what they do?
- Are domain concepts consistently named across the codebase?
- Is business logic clearly separated from infrastructure/framework code?
- Is there a consistent, predictable file/folder structure? (feature-grouped vs layer-grouped)
- Are magic numbers and strings replaced with named constants?
- Are complex algorithms or non-obvious decisions commented with WHY?

**Scores:**
- 1: Mostly untyped, cryptic names, deep nesting, magic everywhere
- 2: Some typing, some clear code, inconsistent conventions
- 3: Mostly typed, mostly clear naming, some inconsistencies
- 4: Strict types everywhere, very clear naming, predictable structure
- 5: Exemplary — new engineer (or agent) could navigate without any oral briefing

---

### Dimension 2: Context & Documentation
*Does the agent start each session knowing enough to act correctly?*

LLMs are stateless. Without explicit context files, every session starts from zero. The
agent must infer the architecture, conventions, and constraints from cold code reads —
which takes tokens, time, and introduces errors.

**Check:**
- Is there an `AGENTS.md` or `CLAUDE.md` or equivalent? Is it hand-crafted (not auto-generated)?
  - Does it cover: stack, architecture, key file paths, how to run/test/build, constraints?
  - Is it < ~300 lines? (too long = gets ignored or truncated)
  - Does it use pointers to source files rather than duplicating code?
- Does `README.md` explain what the project does and how to set it up?
- Are there `README.md` files in key subdirectories (especially in monorepos)?
- Is there an `ARCHITECTURE.md` or `docs/` explaining key design decisions?
- Are ADRs (Architecture Decision Records) present for major decisions?
- Does inline documentation explain WHY, not just what?
- Are deprecated patterns or files flagged explicitly?

**Scores:**
- 1: No context files, README is a stub
- 2: README exists, no AGENTS.md or equivalent
- 3: AGENTS.md exists and covers basics; README is solid
- 4: Comprehensive AGENTS.md, per-package READMEs, ADRs present
- 5: Rich layered docs — AGENTS.md, architecture docs, decision logs, inline WHY comments

---

### Dimension 3: Verifiability & Testing
*Can the agent check its own work without a human?*

This is the single most important dimension. An agent that can run tests and see red/green
can iterate autonomously. An agent with no tests ships broken code with confidence.

**Check:**
- Is there a test suite? What types? (unit, integration, E2E)
- Can the full test suite be run with a single command?
- Are tests fast enough for an agent feedback loop? (< 2 min for unit tests ideally)
- Are tests deterministic? (no flaky tests, no external dependencies without mocking)
- Do tests cover the happy path AND edge cases?
- Do tests serve as documentation? (clear names, obvious arrange/act/assert structure)
- Is there a type checker? Is it run in strict mode? Is it part of CI?
- Is there a linter with enforced rules (not just advisory)?
- Is there a formatter? Is it automated?
- Are pre-commit hooks set up to catch obvious errors before commit?
- Does CI enforce all of the above as gates (not optional)?

**Scores:**
- 1: No tests, no type checking, no linting
- 2: Some tests exist but spotty coverage; type/lint tools present but not enforced
- 3: Meaningful test suite, type checker in strict mode, linter enforced in CI
- 4: High coverage, fast feedback (< 2 min unit tests), all gates in CI
- 5: Comprehensive suite across all levels, near-instant feedback, zero flakiness

---

### Dimension 4: Dev Environment Reproducibility
*Can the agent (or a new human) set up a working environment without hand-holding?*

Agents operating in cloud sandboxes or fresh checkouts need everything to be scripted.
Any "just ask Bob" setup step is a blocker.

**Check:**
- Is there a `devcontainer.json` or equivalent (Nix flake, Dockerfile for dev)?
- Does a `.env.example` (or equivalent) document all required environment variables?
- Is there a single setup command? (`make setup`, `./scripts/bootstrap.sh`, etc.)
- Are all services (DB, cache, queues) runnable locally via Docker Compose or similar?
- Are dependencies locked? (`pnpm-lock.yaml`, `poetry.lock`, `Cargo.lock`, etc.)
- Does the README have accurate, tested setup instructions?
- Is the Node/Python/language version pinned? (`.nvmrc`, `.python-version`, `rust-toolchain`)

**Scores:**
- 1: No setup instructions; requires tribal knowledge
- 2: README with manual steps; environment variables not documented
- 3: Clear README steps, `.env.example` present, deps locked
- 4: `devcontainer.json` + one-command setup, all services containerized
- 5: Fully reproducible in any environment in < 5 minutes from cold clone

---

### Dimension 5: Style & Validation Tooling
*Are quality standards enforced by machines, not humans?*

Never delegate style enforcement to an LLM. Use deterministic tools. Agents should be able
to run these tools and trust the output.

**Check:**
- Is there a linter configured? (ESLint, Biome, Ruff, Clippy, golangci-lint, etc.)
- Is the linter configured with team-agreed rules (not just defaults)?
- Is there a formatter? (Prettier, Black, gofmt, rustfmt, etc.)
- Are linter + formatter run automatically? (pre-commit hooks, CI step)
- Does the type checker run in strict mode?
- Are these tools' configs at the root (monorepo-friendly)?
- Are there no "TODO: fix lint" suppression comments accumulating?

**Scores:**
- 1: No linter or formatter configured
- 2: Tools exist but are not enforced (just IDE plugins)
- 3: Linter + formatter configured and run in CI
- 4: Strict rules, pre-commit hooks, zero-tolerance CI gates
- 5: Comprehensive toolchain including security linting and automated code review

---

### Dimension 6: Build System
*Can the agent build and verify the artifact deterministically?*

A reproducible build gives agents a verification signal beyond tests: "did this compile?"
is often the first gate after edits.

**Check:**
- Is there a single documented build command?
- Is the build deterministic? (same inputs → same outputs)
- Is build time reasonable? (slow builds = slow agent loops)
- Are build artifacts and dist directories properly gitignored?
- For monorepos: does the build system understand the dependency graph? (Turbo, Nx, Bazel, etc.)
- Are build scripts documented with what they produce and why?
- Is there a watch/HMR mode for fast iteration?

**Scores:**
- 1: No clear build process; requires manual steps
- 2: Build command exists but is fragile or undocumented
- 3: Clear build command, deterministic, documented
- 4: Fast incremental builds, monorepo-aware, well-documented scripts
- 5: Near-instant feedback loop with watch mode; builds serve as verification gates

---

### Dimension 7: Observability & Debuggability
*When something breaks, can the agent diagnose it without a human?*

Runtime visibility is what separates agents that can self-correct from agents that get
stuck in loops. If an agent can't read logs or understand errors, it will hallucinate fixes.

**Check:**
- Does the app produce structured logs (JSON or similarly parseable)?
- Are log levels used correctly? (debug vs info vs warn vs error)
- Are error messages actionable? (include context, not just stack traces)
- Are errors surfaced to places the agent can read? (stdout, log files, not only browser console)
- Is tracing/correlation IDs implemented for request flows?
- Are there health check endpoints for services?
- Is there a clear pattern for where to look when something goes wrong?
- Are service crashes/exits clearly communicated vs silent failures?
- Are pidfiles or similar mechanisms used to prevent duplicate service spawning?

**Scores:**
- 1: console.log debugging, no structure, unreadable errors
- 2: Some logging; errors are often cryptic
- 3: Structured logging, actionable errors, health checks
- 4: Full tracing, correlation IDs, clear diagnostics
- 5: Agent can diagnose any failure purely from logs/traces without external help

---

### Dimension 8: Security & Governance
*Are guardrails in place to prevent agent mistakes from becoming disasters?*

Agents make mistakes. The question is whether those mistakes are reversible and contained.
Governance infrastructure turns "catastrophic bug" into "PR that fails CI."

**Check:**
- Is branch protection enabled on main/master? (no direct pushes)
- Are there CODEOWNERS for sensitive areas?
- Is secret scanning configured? (GitHub Advanced Security, Gitleaks, truffleHog)
- Are secrets properly externalized? (no `.env` files with real secrets committed)
- Is there a `.env.example` without real values?
- Are dependency audits run? (`npm audit`, `pip audit`, `cargo audit`)
- Is there a PR review requirement before merge?
- Are infrastructure changes gated separately from code changes?
- Is least-privilege principle applied to service accounts and API keys?

**Scores:**
- 1: Secrets in repo, direct push to main possible, no scanning
- 2: Some practices in place but gaps exist
- 3: Branch protection + secret scanning + dependency audits running
- 4: CODEOWNERS, automated security scanning in CI, no secrets ever committed
- 5: Full security posture: SBOM, policy as code, automated compliance checks

---

### Dimension 9: Task Discovery & Scoping
*Can the agent find its own work and understand the boundaries of a task?*

Agents need structured work queues. Vague "fix things" instructions lead to agents
inventing scope. Clear task structure — with acceptance criteria — enables autonomy.

**Check:**
- Are there issue/PR templates that require structured descriptions?
- Do issues include: clear problem statement, acceptance criteria, affected files/areas?
- Are tasks broken into units an agent can complete in one session (< 500 LoC change)?
- Is there a `CONTRIBUTING.md` explaining the workflow?
- Are there labels/milestones for categorizing work?
- Is there a defined "definition of done" per task type?
- Are tasks linked to specs or PRDs?
- Is there a `plan.md` or similar artifact for complex multi-step work?

**Scores:**
- 1: No templates, no structure, work tracked ad-hoc in Slack/verbal
- 2: Some templates; tasks are often too large or vague
- 3: Issue templates with acceptance criteria; tasks are reasonably scoped
- 4: All tasks have measurable ACs, linked specs, clear "done" definition
- 5: Full task graph with dependencies; agents can self-assign and track progress

---

### Dimension 10: Spec & Planning Quality
*Is the upstream intent clear enough for an agent to implement without guessing?*

This covers the pre-code phases: requirements, specs, and design. An agent implementing
a vague spec will produce technically correct but functionally wrong code.

**Check:**
- Are there written specs or PRDs for features before implementation?
- Do specs cover: what to build, why, success criteria, out-of-scope items, constraints?
- Are specs structured (background, requirements, acceptance criteria, test cases)?
- Are edge cases and failure modes explicitly documented in specs?
- Are API contracts documented before implementation? (OpenAPI, GraphQL schema, etc.)
- Is there a clear line between "spec" (intent) and "implementation" (code)?
- Do specs include measurable success criteria (not just "should work")?
- Are specs version-controlled alongside code?

**Scores:**
- 1: No specs; agents work from Slack messages or verbal descriptions
- 2: Informal specs exist but lack structure and success criteria
- 3: Written specs with clear requirements and basic acceptance criteria
- 4: Structured PRDs with measurable ACs, edge cases, API contracts
- 5: Full spec-driven development: specs committed to repo, linked to tests, auto-verified

---

### Dimension 11: CI/CD & Deployment Pipeline
*Can the agent's work get to production safely and automatically?*

A complete agent-ready pipeline means an agent can open a PR, watch it go green, and
know that it's safe to merge — without needing a human to babysit the pipeline.

**Check:**
- Is there a CI pipeline? Does it run on every PR?
- Does CI run: tests + type-check + lint + build?
- Are CI checks fast enough to be useful? (< 10 min ideally)
- Are deployment environments (staging, prod) clearly defined and documented?
- Is there a staging environment that mirrors production?
- Is deployment automated on merge to main?
- Are rollbacks documented and tested?
- Are environment-specific configs managed cleanly (not hardcoded)?
- Is there a clear "this PR is safe to merge" signal? (all checks green = safe)
- Are deployment logs accessible to the agent?

**Scores:**
- 1: No CI; deployment is manual and undocumented
- 2: Basic CI exists but doesn't run all gates; deployment is manual
- 3: CI runs all gates; deployment is documented
- 4: Full CI + automated staging deployment; green = shippable
- 5: Full pipeline with canary/feature flags, automated rollback, deployment observability

---

## Phase 3: Maturity Level

Based on the dimension scores, assign an overall maturity level:

| Level | Name | Score Range | What Agents Can Do |
|-------|------|-------------|-------------------|
| 1 | Functional | Avg < 2.0 | Basic exploration; require heavy supervision on every change |
| 2 | Documented | Avg 2.0–2.9 | Can navigate and make small changes; need human review on everything |
| 3 | Standardized | Avg 3.0–3.9 | **Productive.** Can handle well-scoped tasks autonomously with light review |
| 4 | Optimized | Avg 4.0–4.4 | Highly effective; can handle complex multi-file changes with minimal oversight |
| 5 | Autonomous | Avg 4.5+ | Can self-assign, implement, verify, and ship with strategic oversight only |

**Note**: Level 3 is the practical target for most teams. It's where agents become genuinely
useful rather than a liability. Level 5 is aspirational and rare.

**Also flag critical blockers**: If any single dimension scores 1, it can block the whole
system regardless of other scores. Flag these explicitly.

---

## Output Format

Produce a report in this structure:

```
# Agent Readiness Report: [Project Name]

## Overall: Level [N] — [Name] ([avg score]/5.0)

[1-2 sentence summary of the overall state and the most important finding.]

---

## Dimension Scores

| # | Dimension | Score | Status |
|---|-----------|-------|--------|
| 1 | Code Comprehensibility | X/5 | [PASS/WARN/FAIL] |
| 2 | Context & Documentation | X/5 | ... |
| 3 | Verifiability & Testing | X/5 | ... |
| 4 | Dev Environment | X/5 | ... |
| 5 | Style & Validation | X/5 | ... |
| 6 | Build System | X/5 | ... |
| 7 | Observability & Debuggability | X/5 | ... |
| 8 | Security & Governance | X/5 | ... |
| 9 | Task Discovery & Scoping | X/5 | ... |
| 10 | Spec & Planning Quality | X/5 | ... |
| 11 | CI/CD & Deployment | X/5 | ... |

PASS = 4-5, WARN = 3, FAIL = 1-2

---

## What's Working
[3-5 bullets on genuine strengths. Be specific — cite actual files/configs.]

---

## Critical Gaps (Prioritized)

### P0 — Blockers (fix before using agents at all)
[Only include if any dimension scores 1. These will cause agents to produce harmful output.]
- ...

### P1 — High Impact (fix this sprint)
[Dimensions scoring 2 in high-leverage areas. Quick wins.]
- ...

### P2 — Medium Impact (fix this quarter)
[Dimensions scoring 3 that could move to 4.]
- ...

### P3 — Polish (nice to have)
[Dimensions at 4 that could become 5.]
- ...

---

## Recommended Action Plan

Ordered list of the most impactful changes, with specific files/commands to create or run:

1. **[Action]** — [Why this has the most leverage] — [Specific files to create/edit]
2. ...

---

## SDLC Coverage

Quick summary of which parts of the development lifecycle are agent-ready:

| Phase | Ready? | Notes |
|-------|--------|-------|
| Spec / Planning | [Y/N/Partial] | ... |
| Development | [Y/N/Partial] | ... |
| Testing / QA | [Y/N/Partial] | ... |
| Code Review | [Y/N/Partial] | ... |
| Deployment | [Y/N/Partial] | ... |
| Production / Ops | [Y/N/Partial] | ... |
```

---

## Key Principles (Reference)

These principles underpin the scoring — they're useful to quote in the report:

1. **Verifiability > capability**: An agent with a test suite is worth more than a smarter
   agent without one. Agents can't tell the difference between "correct" and "plausible."

2. **Explicit > implicit**: Every convention that lives in someone's head is a liability.
   Make it a linter rule, a type, a test, or a documented constraint.

3. **Fast feedback loops are mandatory**: Agent iteration speed is bounded by feedback speed.
   If type-check + tests take 20 minutes, the agent loops slowly and burns tokens.

4. **Reproducibility enables parallelism**: Multiple agent instances working in parallel
   require isolated, reproducible environments. Stateful local setups break this.

5. **Scope clarity prevents scope creep**: Vague tasks produce wandering agents. Every
   task an agent receives should have measurable, binary acceptance criteria.

6. **Fail loudly, not silently**: Agents can handle explicit errors. They cannot handle
   silent failures, missing output, or ambiguous success signals.

7. **Context files are not auto-generated**: AGENTS.md/CLAUDE.md hand-crafted by the
   team outperforms LLM-generated versions. Every line deserves consideration.

8. **Security must be structural**: Branch protection, secret scanning, and review
   requirements aren't optional extras — they're the guard rails that make agent
   mistakes recoverable.

9. **Tests are living documentation**: A well-written test suite shows an agent exactly
   what code is supposed to do better than any prose documentation.

10. **The bottleneck is infrastructure, not the model**: Before blaming the AI, ask whether
    a new engineer with no context could navigate and contribute to this codebase safely.
