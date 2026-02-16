---
name: test-with-supatest
description: Generate comprehensive E2E tests and a visual verification report for a completed feature using Supatest CLI. Use after implementing a new feature or making code changes that need testing verification.
argument-hint: [feature-description]
disable-model-invocation: true
allowed-tools: Bash(supatest *)
---

# Test with Supatest

Use this skill when you have finished implementing a feature and want to generate comprehensive E2E tests along with a visual verification report.

## When to Use

Invoke this skill AFTER you have:
- Completed implementing a new feature
- Made code changes that need testing verification
- Want a visual report with screenshots, video, and test results for verification

## What This Skill Does

This skill invokes the **Supatest CLI** in `test-feature` mode, which:
1. **Explores** your application to understand the feature
2. **Writes comprehensive E2E tests** (main flows + edge cases)
3. **Runs tests and fixes failures** until all pass
4. **Generates a visual feature report** with:
   - Screenshots of key UI states
   - Happy-path video recording
   - Test results with pass/fail status
   - Architecture diagram
   - Saved to `.supatest/reports/<feature-slug>-<id>/REPORT.md`

## Prerequisites

Before invoking Supatest CLI, ensure:
1. Supatest CLI is installed globally or available in the project
2. `SUPATEST_API_KEY` environment variable is set (for CI/headless mode)
3. The project has a test framework set up (Playwright, Cypress, etc.)
4. The application is running or can be started

## Your Task

When this skill is invoked:

1. **Summarize the feature** you just built in 1-3 sentences
2. **List key functionality** points that should be tested
3. **Mention files changed** if relevant
4. **Reference any plan files** if applicable
5. **Run the Supatest CLI** with the crafted description:

```bash
supatest --headless --mode test-feature "<your-crafted-description>"
```

6. **Wait for completion** - This may take several minutes
7. **Report the results** - Tell the user where the report is located

## How to Craft the Feature Description

The feature description should be **rich and contextual**. Include:

### 1. Feature Name and Location
```
"The date range picker component on the runs page"
```

### 2. Key Functionality
```
"- Default 7-day range
- Presets: Today, Yesterday, Last 7 days, Last 30 days
- Filters data by startedAt timestamp"
```

### 3. Files Changed (if known)
```
"Files modified:
- frontend/src/pages/runs.tsx
- api/src/controllers/runs.controller.ts
- api/src/models/runs.model.ts"
```

### 4. Reference to Plan Files (if applicable)
```
"See plan at docs/features/date-range-picker.md for full spec"
```

## Example Invocations

### Simple Feature
```bash
supatest --headless --mode test-feature "user authentication login form with email and password"
```

### Detailed Feature
```bash
supatest --headless --mode test-feature "Date Range Picker on Runs Page

Features:
- Default 7-day range selection
- Preset options: Today, Yesterday, Last 7 days, Last 30 days
- API filtering with dateFrom/dateTo query parameters
- Stats cards update to reflect filtered date range

Files changed:
- frontend/src/pages/runs.tsx (DateRangePicker component integration)
- api/src/controllers/grouped-runs.controller.ts (date params parsing)
- api/src/models/grouped-runs.model.ts (date filtering in queries)

The date picker should be visible on Test Runs and Grouped Runs tabs, but hidden on Run Configs tab."
```

### With Plan File Reference
```bash
supatest --headless --mode test-feature "Stripe checkout integration. See full spec at docs/stripe-checkout.md. Main flows: guest checkout, saved card payment, 3D Secure handling."
```

## Additional CLI Options

| Option | Example | Description |
|--------|---------|-------------|
| `--cwd` | `--cwd /path/to/project` | Working directory (default: current) |
| `--model` | `--model premium` | Model tier: small, medium, premium |
| `--verbose` | `--verbose` | Enable detailed logging |
| `--supatest-api-key` | `--supatest-api-key sk_test_xxx` | Override API key |
| `-m, --claude-max-iterations` | `-m 50` | Max agent iterations (default: 100) |

### Full Example with Options
```bash
supatest --headless --mode test-feature --model premium --verbose "checkout flow with stripe"
```

## What Happens After Invocation

1. **Agent starts** - Supatest CLI creates a session and begins exploration
2. **Exploration** - Agent uses browser automation to understand the feature
3. **Test writing** - Comprehensive E2E tests are written
4. **Test execution** - Tests run in headless mode
5. **Fix loop** - Any failures are analyzed and fixed (max 5 attempts per test)
6. **Report generation** - After all tests pass:
   - Screenshots are captured
   - Happy-path video is recorded
   - Test results are captured
   - REPORT.md is generated

## Output Location

Reports are saved to:
```
<project-root>/.supatest/reports/<feature-slug>-<random-4chars>/
├── REPORT.md           # Main report (open this!)
├── screenshots/
│   ├── 01-*.png
│   ├── 02-*.png
│   └── ...
├── videos/
│   └── happy-path.webm
└── test-results/
    ├── e2e-tests-output.txt
    └── integration-tests-output.txt
```

## After Supatest Completes

1. **Check the report** - Open `.supatest/reports/<feature>/REPORT.md`
2. **Review screenshots** - Verify the UI looks correct
3. **Watch the video** - See the happy-path flow in action
4. **Review test results** - Ensure all tests passed
5. **Share with stakeholders** - The report is portable and self-contained

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPATEST_API_KEY` | Yes | Your Supatest API key (get from https://code.supatest.ai/api-keys) |
| `SUPATEST_API_URL` | No | Custom API URL (default: https://code-api.supatest.ai) |

## Troubleshooting

### "API key required"
Set the `SUPATEST_API_KEY` environment variable before running.

### "Task is required in headless mode"
Make sure you provide a feature description after `--mode test-feature`.

### "Invalid mode"
Ensure you're using exactly `--mode test-feature` (not just `test-feature`).

### Tests failing repeatedly
The agent will attempt fixes up to 5 times per test. If still failing, check:
- Is the application running and accessible?
- Are there environment issues (missing env vars, etc.)?
- Is the feature actually working in the UI?

## Integration with Development Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│  YOUR WORKFLOW (Claude Code)                                             │
│  ────────────────────────────────                                        │
│  1. Plan the feature                                                      │
│  2. Implement the feature                                                 │
│  3. Commit the changes                                                    │
│  4. [INVOKE THIS SKILL] → Call Supatest CLI                               │
│  5. Review the generated report                                           │
│  6. Share report with team / use as verification artifact                 │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  SUPATEST CLI (test-feature mode)                                        │
│  ─────────────────────────────────                                       │
│  1. Explores app with browser automation                                  │
│  2. Writes E2E tests for the feature                                      │
│  3. Runs tests and fixes failures                                         │
│  4. Captures screenshots and video                                        │
│  5. Generates REPORT.md with all artifacts                                │
│  6. Returns report path                                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

## Quick Reference

```bash
# Basic invocation
supatest --headless --mode test-feature "<feature-description>"

# With options
supatest --headless --mode test-feature --model premium --verbose "<feature>"

# With API key inline
supatest --headless --mode test-feature --supatest-api-key sk_test_xxx "<feature>"

# From different directory
supatest --headless --mode test-feature --cwd /path/to/project "<feature>"
```
