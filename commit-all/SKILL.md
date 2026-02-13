# Commit All Changes

Stage all changes and commit with well-structured commit messages following conventional commits format.

## When to use this skill

Use this skill when you need to:
- Stage and commit all changes in one step
- Quickly commit everything without manually staging
- Create well-formatted commit messages for all changes
- Follow conventional commit standards

## Instructions

When the user invokes this skill:

### 1. Check Repository Status

Run `git status` to see all changes:
- Show untracked files
- Show modified files
- Show deleted files
- Warn if there are sensitive files (.env, credentials, etc.)

### 2. Review All Changes

Before staging anything:
- Run `git diff` to see unstaged changes
- Run `git diff --cached` to see any already staged changes
- Identify all files that will be affected
- **Critical**: Check for files that should NOT be committed:
  - `.env` files
  - `credentials.json` or similar
  - API keys or secrets
  - Large binary files
  - Build artifacts (`dist/`, `node_modules/`, etc.)

### 3. Stage All Files

If safe to proceed:
```bash
git add -A
```

Or for more control, list specific files:
```bash
git add file1 file2 file3
```

**Never stage:**
- Files with secrets or credentials
- Files that should be in .gitignore
- Large binaries (warn user first)

### 4. Analyze Changes

Review what's now staged:
- Run `git diff --cached --stat` to see stats
- Identify the type of change (feature, fix, refactor, etc.)
- Group related changes if multiple areas affected
- Look for breaking changes or important migrations

### 5. Determine Commit Type

Choose the appropriate conventional commit type:

**Common types:**
- **feat**: New feature or functionality
- **fix**: Bug fix
- **docs**: Documentation changes only
- **style**: Formatting, whitespace (no code change)
- **refactor**: Code restructuring without changing behavior
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, dependencies, build config
- **perf**: Performance improvements
- **ci**: CI/CD configuration changes
- **build**: Build system or external dependency changes

### 6. Generate Commit Message

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

Multiple file types:
```
chore: update dependencies and fix linting issues

Updates all npm packages to latest versions and fixes
eslint warnings across the codebase.

- Update package.json dependencies
- Fix linting issues in components
- Update Jest configuration
```

Mixed changes:
```
feat: add dark mode and update documentation

Implements dark mode toggle with persistent user preference.
Updates docs to reflect new theming system.

- Add ThemeProvider with light/dark themes
- Implement theme toggle component
- Add theme persistence to localStorage
- Update README with theme usage examples
```

### 7. Execute Commit

Run the commit:
```bash
git commit -m "$(cat <<'EOF'
<commit message here>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

### 8. Verify Success

After committing:
- Run `git log -1` to show the commit
- Run `git status` to confirm clean state
- If commit fails (pre-commit hooks, etc.), help fix the issue and create a NEW commit (don't amend)

## Safety Checks

Before staging with `git add -A`, verify:

1. **No sensitive files:**
   - Check for `.env`, `.env.local`, etc.
   - Check for `*credentials*`, `*secrets*`, `*keys*`
   - Check for `config/production.json` with secrets

2. **No build artifacts:**
   - `node_modules/`, `dist/`, `build/`
   - `.next/`, `.nuxt/`
   - `target/`, `out/`

3. **No large files:**
   - Warn if files > 10MB
   - Suggest using Git LFS for large assets

4. **Check .gitignore:**
   - If files should be ignored, suggest adding to .gitignore first

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

## Examples

### Example 1: Simple Feature
```
User: "/commit-all"

You:
1. git status (shows new components and tests)
2. git diff (reviews changes)
3. git add -A
4. Generate message:

feat: add user profile component

Implements new user profile page with avatar upload
and bio editing functionality.

- Add ProfilePage component
- Add AvatarUpload component
- Add profile API endpoints
- Add profile page tests

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>

5. git commit
6. Confirm success
```

### Example 2: Multiple Changes
```
User: "/commit-all"

You:
1. git status (shows code changes, docs, and config)
2. Check for sensitive files (none found)
3. git add -A
4. Generate message:

chore: update build config and improve documentation

Updates webpack config for better performance and adds
comprehensive API documentation.

- Optimize webpack bundle splitting
- Add compression plugins
- Update API documentation with examples
- Add contribution guidelines

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

### Example 3: Sensitive Files Detected
```
User: "/commit-all"

You:
1. git status
2. Detect .env file

⚠️ Warning: Sensitive files detected

Found files that should not be committed:
- .env (contains API keys)

Options:
1. Add .env to .gitignore (recommended)
2. Stage only safe files manually
3. Cancel commit

What would you like to do?
```

## Tips

- **Review before staging**: Always check what's being committed
- **Use .gitignore**: Keep it updated for your project
- **Be descriptive**: Subject + body for non-trivial changes
- **Group logically**: One logical change per commit (even if multiple files)
- **Check secrets**: Never commit credentials or API keys
- **Consider scope**: Very large commits might need to be split

## Notes

- This skill stages **everything** - use `/commit` for selective commits
- Always reviews files before staging to prevent committing secrets
- If commit fails due to hooks, fix the issue and create a NEW commit (never amend unless explicitly requested)
- Always add "Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>" to commits
