# Work Summary Generator

Generate a summary of work done based on git commit history.

## Arguments

`<author> <start_datetime> <end_datetime> <repo1> [repo2] [repo3]...`

### Examples
- `/work-summary Prasad "2026-01-08 06:00" "2026-01-09 02:00" supatest aiden`
- `/work-summary "Prasad Pilla" "2026-01-07 09:00" "2026-01-07 18:00" .`

## When to use this skill

Use this skill when you need to:
- Generate work summaries for standup or status reports
- Create summaries for timesheets or billing
- Review what was accomplished in a time period
- Prepare for retrospectives or reviews
- Track work across multiple repositories

## Instructions

### 1. Parse Arguments

If no arguments provided, ask the user for:
1. **Author name** - Git author to filter by
2. **Start date/time** - Format: `YYYY-MM-DD HH:MM` (in local timezone)
3. **End date/time** - Format: `YYYY-MM-DD HH:MM` (in local timezone)
4. **Repository paths** - Space-separated, relative to current directory or absolute paths

Example prompts:
```
Please provide:
- Author name: (e.g., "Prasad" or "Prasad Pilla")
- Start time: (e.g., "2026-01-08 09:00")
- End time: (e.g., "2026-01-08 18:00")
- Repositories: (e.g., "supatest aiden" or "." for current)
```

### 2. Collect Git Data

For each repository:

**Get commits:**
```bash
cd <repo> && git log --author="<author>" --since="<start>" --until="<end>" --pretty=format:"%h|%s"
```

**Get stats:**
```bash
cd <repo> && git log --author="<author>" --since="<start>" --until="<end>" --shortstat --pretty=format:"%h"
```

**Notes:**
- Assume IST timezone (+0530) unless otherwise specified
- Handle relative paths (convert to absolute if needed)
- If repo doesn't exist, warn and skip it

### 3. Group and Categorize Commits

**Group related commits** into logical tasks:
- Same feature across multiple commits
- Related bug fixes
- Single refactoring effort
- Use commit message prefixes to help (feat, fix, refactor, chore, docs, test)

**Categorize by size:**

**Large Tasks:**
- New packages or major modules
- Significant new functionality with multiple components
- Major architectural changes
- Complex features spanning many files
- Examples: "Add authentication system", "Implement payment processing"

**Medium Tasks:**
- Feature additions to existing modules
- Substantial refactoring efforts
- Multi-file changes with moderate complexity
- API endpoint additions
- Examples: "Add user profile editing", "Refactor API error handling"

**Small Tasks:**
- Bug fixes
- UI tweaks and styling
- Single-file changes
- Cleanup and formatting
- Documentation updates
- Minor refactors
- Examples: "Fix typo", "Update button color", "Add JSDoc"

### 4. Calculate Totals

- Total commit count across all repos
- Total lines added (sum from git stats)
- Total lines deleted (sum from git stats)
- Total distinct tasks

### 5. Generate Output

Use this format:

```markdown
## Work Summary: <start> - <end>

### Large (<count>)
1. **Task Name** (repo-name) - Brief description of what was accomplished
2. **Another Task** (repo-name) - Description

### Medium (<count>)
1. **Task Name** (repo-name) - Brief description
2. **Another Task** (repo-name) - Description

### Small (<count>)
- Fix login validation error (repo-name)
- Update dashboard styling (repo-name)
- Add API documentation (repo-name)
- Refactor utility functions (repo-name)

---

**Summary:** X commits, ~Yk lines added, ~Zk lines deleted across N distinct tasks
```

**Formatting notes:**
- Use **bold** for task names
- Include repo name in parentheses if multiple repos
- Round line counts to nearest thousand (e.g., ~2k, ~500)
- List small tasks as bullet points (not numbered)
- Keep descriptions concise (one line)

## Examples

### Example 1: With Arguments
```
User: "/work-summary Prasad '2026-02-13 09:00' '2026-02-13 18:00' supatest"

You:
1. cd supatest
2. Run git log commands
3. Analyze commits
4. Output:

## Work Summary: 2026-02-13 09:00 - 2026-02-13 18:00

### Large (1)
1. **Add user authentication system** (supatest) - Implemented JWT-based auth with login, signup, and password reset flows

### Medium (2)
1. **Refactor API error handling** (supatest) - Standardized error responses across all endpoints
2. **Add test coverage reporting** (supatest) - Integrated coverage tools and added dashboard

### Small (5)
- Fix session timeout bug
- Update login page styling
- Add API documentation for auth endpoints
- Remove unused dependencies
- Fix TypeScript type errors

---

**Summary:** 15 commits, ~2k lines added, ~500 lines deleted across 8 distinct tasks
```

### Example 2: Multiple Repos
```
User: "/work-summary 'Prasad Pilla' '2026-02-01 00:00' '2026-02-07 23:59' supatest aiden docs"

You analyze commits across all three repos and group by task:

## Work Summary: 2026-02-01 - 2026-02-07

### Large (2)
1. **Implement CI/CD pipeline** (supatest, aiden) - Set up GitHub Actions for automated testing and deployment
2. **Add real-time collaboration** (aiden) - WebSocket-based live editing with conflict resolution

### Medium (3)
1. **Optimize database queries** (supatest) - Added indexes and rewrote slow queries
2. **Update documentation site** (docs) - Redesigned docs with new examples
3. **Add error tracking** (aiden) - Integrated Sentry for error monitoring

### Small (8)
- Fix dashboard loading spinner (aiden)
- Update README with new features (supatest)
- Add changelog for v2.1 (docs)
- Fix mobile responsive issues (aiden)
- Remove debug logging (supatest)
- Update dependencies (supatest, aiden)
- Fix broken links in docs (docs)
- Add code of conduct (docs)

---

**Summary:** 42 commits, ~5k lines added, ~2k lines deleted across 13 distinct tasks
```

### Example 3: No Arguments - Interactive
```
User: "/work-summary"

You: "Please provide the following information:
- Author name: (e.g., 'Prasad' or 'Prasad Pilla')
- Start date/time: (format: YYYY-MM-DD HH:MM, e.g., '2026-02-13 09:00')
- End date/time: (format: YYYY-MM-DD HH:MM, e.g., '2026-02-13 18:00')
- Repository paths: (space-separated, e.g., 'supatest aiden' or '.' for current directory)"

User: "Prasad, 2026-02-13 09:00, 2026-02-13 18:00, ."

You: [Process current directory as repository and generate summary]
```

## Tips

- **Smart grouping**: Combine commits like "Add feature X", "Fix feature X bug", "Update feature X tests" into one task
- **Use commit messages**: Look for conventional commit prefixes (feat:, fix:, refactor:, etc.)
- **Context matters**: A 10-line change to a critical file might be "Medium", while a 100-line new test file might be "Small"
- **Repo names**: Only show repo names if analyzing multiple repos
- **Time zones**: Default to IST (+0530) but respect user's timezone if specified
- **Clarity**: Make task descriptions clear and business-value focused
- **Accuracy**: Count lines accurately from git stats

## Notes

- This skill works best with clean, descriptive commit messages
- For very large time ranges, consider summarizing by day or week
- If no commits found, clearly state that and verify the author name and date range
- Handle errors gracefully (missing repos, invalid dates, git errors)
