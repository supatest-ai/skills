---
name: deploy
description: Deploy your application to staging or production using GitHub Actions via GitHub CLI. Auto-detects which services changed since the last deployment and triggers the appropriate workflow.
argument-hint: [staging|prod] [services]
---

# Deploy Skill

Deploy your application to staging or production using GitHub CLI.

## Usage

```
/deploy [staging|prod] [services]
```

**Examples:**
- `/deploy` — auto-detect changed services, deploy to staging
- `/deploy staging` — same as above, explicit
- `/deploy prod` — auto-detect, deploy to production (runs CI checks)
- `/deploy staging web` — deploy only the frontend to staging
- `/deploy staging api` — deploy only the API to staging
- `/deploy staging web,api` — deploy frontend + API to staging
- `/deploy prod all` — deploy everything to production

**Valid services:** depends on your project — e.g. `web`, `api`, `worker`, or `all`

---

## What It Does

### 1. Resolve Target Environment
- Default: `staging`
- Prod deployments always run CI checks (type-check + unit tests)
- Staging deployments skip CI checks by default for speed

### 2. Auto-Detect Changed Services (if no services specified)
Query the last successful deployment commit for the target environment via GitHub Deployments API, then diff against current HEAD to determine which services have changed.

The path-to-service mapping is project-specific — configure it in **Step 4** below.

### 3. Show Deployment Plan
Before triggering, display:
- Environment
- Services to deploy
- Current commit SHA and message
- Last deployed commit SHA (and gap size: "N commits since last deploy")
- Notable changed files

Ask for confirmation before proceeding.

### 4. Trigger via GitHub CLI
```bash
gh workflow run <workflow-file>.yml \
  --field branch=main \
  --field environment=<env> \
  --field services=<services> \
  --field skip_ci_checks=<true|false>
```

### 5. Watch the Run
Use `gh run watch <run-id>` to stream live progress until completion.
Report final status: success or failure with link to logs.

---

## Instructions

When the user invokes `/deploy`:

### Step 1 — Parse Arguments
Extract environment and services from args:
- First arg that is `staging` or `prod` → environment (default: `staging`)
- Remaining args, or comma-separated values → services list
- If no services provided → auto-detect mode

### Step 2 — Get Repo Info
```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

### Step 3 — Get Last Deployed Commit

Query GitHub Deployments API for the last successful deployment on the target environment:

```bash
# staging environment name = "staging"
# prod environment name = "production"
gh api "repos/OWNER/REPO/deployments?environment=ENV&per_page=10" \
  --jq '.[].id' | while read id; do
  status=$(gh api "repos/OWNER/REPO/deployments/$id/statuses" \
    --jq '[.[] | select(.state=="success")] | length')
  if [ "$status" -gt 0 ]; then
    gh api "repos/OWNER/REPO/deployments/$id" --jq '.sha'
    break
  fi
done
```

If no previous deployment found, note "first deployment to this environment" and deploy all services.

### Step 4 — Detect Changed Services (auto-detect mode only)

```bash
git fetch origin main --quiet
git diff --name-only HEAD <last-sha>
```

Map changed files to services based on your project's structure. Example mapping for a monorepo:

| Changed paths | Service |
|---|---|
| `apps/web/**`, `packages/ui/**` | `web` |
| `apps/api/**` | `api` |
| `packages/shared/**` | `web` AND `api` (both consume shared) |
| `apps/worker/**` | `worker` |

**Adapt this mapping to your project's directory layout.** If a shared package changes and multiple services depend on it, add all dependent services.

If no services detected from diff → tell user "No deployable services changed since last deploy" and stop (unless they passed explicit services).

### Step 5 — Build and Show Deployment Plan

Display a clear summary:
```
Deployment Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Environment:  staging
Services:     web, api
Branch:       main

Current:      abc1234  feat: add checkout flow
Last deploy:  def5678  (3 commits ago)

Changed files driving this deploy:
  apps/web/src/pages/checkout.ts
  apps/api/src/routes/orders.ts
  packages/shared/src/schema/orders.ts

⚠️  packages/shared changed → deploying both web and api
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Proceed? (yes/no)
```

Wait for user confirmation. If they say no, stop.

### Step 6 — Trigger the Workflow

```bash
gh workflow run <workflow-file>.yml \
  --field branch=main \
  --field environment=<env> \
  --field services=<comma-separated-services> \
  --field skip_ci_checks=<true if staging, false if prod>
```

Wait 3 seconds, then get the run ID:
```bash
gh run list --workflow=<workflow-file>.yml --limit=1 --json databaseId --jq '.[0].databaseId'
```

### Step 7 — Watch the Run

```bash
gh run watch <run-id>
```

Stream live output until completion. On success, print:
```
✅ Deployed successfully!
   View: https://github.com/OWNER/REPO/actions/runs/<run-id>
```

On failure:
```
❌ Deployment failed.
   Logs: https://github.com/OWNER/REPO/actions/runs/<run-id>
```

---

## Setup

Before using this skill, configure it for your project:

1. **Workflow file name** — replace `<workflow-file>.yml` with your actual GitHub Actions workflow filename
2. **Service names** — update the valid services list to match your project
3. **Path-to-service mapping** — update Step 4's mapping table to reflect your monorepo layout
4. **Environment names** — if your GitHub environment names differ from `staging`/`production`, update the API calls in Step 3

## Important Notes

- **Prod always runs CI checks** — `skip_ci_checks` is forced to `false` for prod. Never skip checks on production.
- **Staging skips CI by default** — Saves time on fast iteration cycles.
- **Some services may require manual deployment** — If any part of your stack falls outside the CI/CD pipeline (e.g. infrastructure changes, database migrations), remind the user to handle those separately.
- **Hard-refresh after frontend deploys** — CDN/hosting caches may serve the old bundle. Remind users to hard-refresh after a frontend deploy.
