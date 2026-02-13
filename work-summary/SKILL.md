# Work Summary Generator

Generate comprehensive work summaries from git commits, perfect for PRs, release notes, and stakeholder updates.

## When to use this skill

Use this skill when you need to:
- Create pull request descriptions from recent commits
- Generate release notes for a sprint or milestone
- Summarize work done in a specific time period
- Create status updates for stakeholders
- Document changes for code reviews

## Instructions

When the user invokes this skill:

1. **Gather Git Information**
   - Run `git log --oneline --decorate -n 20` to see recent commits
   - If a branch name is provided, compare against it: `git log main..current-branch --oneline`
   - If a time range is provided, use: `git log --since="2 weeks ago" --oneline`
   - Get detailed commit info: `git log --stat -n 10` for file changes

2. **Analyze Commits**
   - Group commits by type (features, fixes, refactoring, docs, tests, chores)
   - Identify related commits that belong together
   - Look for patterns in file changes
   - Note any breaking changes or important migrations

3. **Get Diff Context**
   - For significant changes, review diffs: `git diff main...HEAD` (or specified range)
   - Focus on the "why" not just the "what"
   - Identify API changes, schema modifications, or config updates

4. **Generate Summary**
   Create a structured summary with:

   **Overview**
   - High-level description of what was accomplished
   - Business value or problem solved

   **Changes**
   Organize by category:
   - ✨ **Features**: New functionality added
   - 🐛 **Bug Fixes**: Issues resolved
   - ♻️ **Refactoring**: Code improvements
   - 📝 **Documentation**: Docs updates
   - ✅ **Tests**: Test coverage changes
   - 🔧 **Chores**: Build, config, dependencies

   **Technical Details**
   - Key files modified
   - Database/schema changes
   - API changes or new endpoints
   - Dependencies added/updated

   **Testing**
   - What was tested
   - Test coverage changes
   - Manual testing performed

   **Breaking Changes** (if any)
   - What breaks
   - Migration path

   **Next Steps** (if applicable)
   - Follow-up work needed
   - Known issues or limitations

5. **Formatting Options**
   Ask the user if they want:
   - **PR Description**: GitHub-flavored markdown, detailed
   - **Release Notes**: User-facing, concise
   - **Stakeholder Update**: Business-focused, high-level
   - **Technical Summary**: Developer-focused, detailed

   Default to PR Description format if not specified.

6. **Additional Context**
   - If commits reference issue numbers, mention them
   - Link related PRs if mentioned in commits
   - Highlight any commits marked with [BREAKING] or similar tags

## Examples

### Example 1: PR Description
```
User: "Generate a work summary for my current branch"

You: Run git commands to analyze commits and respond with:

## Summary
Implemented user authentication with JWT tokens and added password reset functionality.

## Changes

✨ **Features**
- Add JWT-based authentication system (#123)
- Implement password reset flow with email verification (#125)
- Add "Remember me" functionality

🐛 **Bug Fixes**
- Fix session timeout not clearing cookies (#124)

♻️ **Refactoring**
- Extract auth middleware to separate module
- Consolidate password validation logic

## Technical Details
- Added `jsonwebtoken` and `bcrypt` dependencies
- New database table: `password_reset_tokens`
- New API endpoints:
  - POST /auth/login
  - POST /auth/reset-password
  - POST /auth/verify-reset-token

## Testing
- Added unit tests for auth middleware (95% coverage)
- Added integration tests for password reset flow
- Manually tested with various email providers

## Breaking Changes
None
```

### Example 2: Release Notes
```
User: "Create release notes for the last 2 weeks in user-facing language"

You: Run git log --since="2 weeks ago" and respond with:

# Release v2.3.0

## What's New
- **Faster Test Execution**: Tests now run 40% faster with parallel execution
- **Smart Test Selection**: Automatically runs only tests affected by your changes
- **Enhanced Error Messages**: More helpful error messages with fix suggestions

## Improvements
- Better error handling for network timeouts
- Improved dashboard loading performance
- More detailed test failure reports

## Bug Fixes
- Fixed issue where cancelled runs would show as "running"
- Resolved memory leak in test runner
- Fixed incorrect test count in summary view
```

## Tips

- **Be concise but thorough**: Include enough detail for understanding without overwhelming
- **Use clear categorization**: Group related changes together
- **Highlight impact**: Explain the "why" and "value" of changes
- **Include relevant commands**: Show git commands used if helpful for reproduction
- **Link to issues/PRs**: Reference ticket numbers when mentioned in commits
- **Note deployment needs**: Mention if DB migrations, config changes, or deployment steps are needed
- **Consider the audience**: Adjust technical depth based on who will read it

## Notes

- This skill works best with clear, descriptive commit messages
- For very large changesets, focus on the most significant changes
- Always offer to dig deeper into specific areas if the user wants more detail
- If commit messages are unclear, make best efforts but note where assumptions were made
