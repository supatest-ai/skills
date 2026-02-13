# Commit Staged Files

Commit staged files with well-structured commit messages following conventional commits format.

## When to use this skill

Use this skill when you need to:
- Commit files that are already staged (`git add`)
- Create well-formatted commit messages
- Follow conventional commit standards
- Ensure commit message quality

## Instructions

When the user invokes this skill:

### 1. Check Staged Files

Run `git status` and `git diff --cached --stat` to see what's staged:
- If nothing is staged, inform the user and suggest using `/commit-all` or staging files first
- Show the user what will be committed

### 2. Analyze Changes

Review the staged changes:
- Run `git diff --cached` to understand what changed
- Identify the type of change (feature, fix, refactor, etc.)
- Group related changes if multiple files
- Look for breaking changes or important migrations

### 3. Determine Commit Type

Choose the appropriate conventional commit type:

**Common types:**
- **feat**: New feature or functionality
- **fix**: Bug fix
- **docs**: Documentation changes only
- **style**: Formatting, whitespace, missing semicolons (no code change)
- **refactor**: Code restructuring without changing behavior
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, dependencies, build config
- **perf**: Performance improvements
- **ci**: CI/CD configuration changes
- **build**: Build system or external dependency changes
- **revert**: Reverting a previous commit

### 4. Generate Commit Message

Create a commit message with:

**Subject line (max 72 characters):**
```
<type>: <short description>
```

**Body (optional but recommended for significant changes):**
- Explain **what** changed and **why**
- Use present tense ("add" not "added")
- Wrap at 72 characters
- Reference issues/PRs if applicable (#123)
- Note breaking changes with "BREAKING CHANGE:" prefix

**Examples:**

Simple commit:
```
feat: add user authentication with JWT
```

With body:
```
feat: add user authentication with JWT

Implements JWT-based authentication system with login, signup,
and password reset flows. Users can now securely authenticate
and maintain sessions.

- Add auth middleware for protected routes
- Implement token refresh mechanism
- Add password hashing with bcrypt

Closes #123
```

Breaking change:
```
feat: migrate to new API endpoint structure

BREAKING CHANGE: API endpoints now use /api/v2 prefix instead of /v1.
Clients must update their base URLs.

Migrates all endpoints to new versioned structure for better
API evolution support.
```

### 5. Execute Commit

Run the commit:
```bash
git commit -m "$(cat <<'EOF'
<commit message here>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

### 6. Verify Success

After committing:
- Run `git log -1` to show the commit
- Run `git status` to confirm clean state
- If commit fails (pre-commit hooks, etc.), help fix the issue and create a NEW commit (don't amend)

## Commit Message Guidelines

**Subject line:**
- Use imperative mood ("add feature" not "added feature")
- Don't capitalize first letter after type
- No period at the end
- Keep under 72 characters
- Be specific but concise

**Body:**
- Separate from subject with blank line
- Explain what and why, not how
- Wrap at 72 characters
- Use bullet points for multiple changes
- Reference issues with #123
- Note breaking changes prominently

**Examples of good vs bad:**

✅ Good:
```
feat: add email verification for new users

Implements email verification flow to ensure valid email addresses.
Users receive a verification link after signup and must verify
before accessing full features.

- Add verification token generation
- Implement email sending service
- Add verification UI flow

Closes #456
```

❌ Bad:
```
Added some stuff

Updated files
```

## Tips

- **Be descriptive but concise**: Subject should be clear, body adds context
- **Group related changes**: One logical change per commit
- **Use conventional commits**: Makes changelog generation easier
- **Reference issues**: Link to tickets/issues for context
- **Explain why**: The code shows what, commit message explains why
- **Check for secrets**: Don't commit API keys, passwords, or credentials

## Notes

- This skill only commits **already staged** files
- Use `/commit-all` if you want to stage and commit everything
- If commit fails due to hooks, fix the issue and create a NEW commit (never amend unless explicitly requested)
- Always add "Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>" to commits
