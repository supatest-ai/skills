# Update Supatest Skills

Manually update the Supatest AI skills to get the latest changes from the repository.

## When to use this skill

Use this skill when you need to:
- Pull the latest skills updates immediately
- Check if there are new skills available
- Update skills outside of the automatic update schedule
- Troubleshoot skill updates

## Instructions

When the user invokes this skill:

1. **Check Current Location**
   - Verify the skills directory exists: `~/.claude/skills/supatest`
   - If not found, inform the user they need to install first

2. **Show Current Status**
   - Run `git status` to show current state
   - Run `git log -1 --oneline` to show the current commit
   - Check for uncommitted local changes

3. **Fetch Latest Updates**
   - Run `git fetch origin main` to check for updates
   - Compare local vs remote: `git rev-list --left-right --count HEAD...origin/main`
   - Tell the user if updates are available

4. **Pull Updates**
   - If updates available, run `git pull origin main`
   - Show what changed: `git log --oneline HEAD@{1}..HEAD`
   - List any new or modified skills

5. **Report Results**
   Create a summary:
   ```
   ✅ Skills Updated Successfully

   Previous version: [commit hash]
   Current version: [commit hash]

   Changes:
   - [List of commits pulled]

   Skills modified/added:
   - [List skills that changed]

   Next auto-update: ~30 minutes
   ```

   Or if already up to date:
   ```
   ✅ Skills Already Up to Date

   Current version: [commit hash]
   Last update: [time]

   All skills are current. Next auto-update in ~30 minutes.
   ```

6. **Handle Errors**
   If update fails:
   - Check for merge conflicts
   - Check network connectivity
   - Suggest running: `~/.claude/skills/supatest/scripts/auto-update.sh`
   - Offer to stash local changes if needed

7. **Additional Options**
   Ask if the user wants to:
   - View the update log: `tail ~/.claude/skills/supatest-update.log`
   - Check auto-update status: `launchctl list | grep supatest`
   - View a specific skill's changes

## Examples

### Example 1: Standard Update
```
User: "/update-skills"

You:
1. cd ~/.claude/skills/supatest
2. git fetch origin main
3. git pull origin main
4. Report changes:

✅ Skills Updated Successfully

Previous: abc1234
Current: def5678

Changes pulled:
- Add performance-audit skill
- Update test-analyzer to handle flaky tests better
- Fix typo in db-migration examples

Skills modified:
- test-analyzer
- db-migration

New skills:
- performance-audit

All skills are now up to date! 🎉
```

### Example 2: Already Up to Date
```
User: "/update-skills"

You:
1. cd ~/.claude/skills/supatest
2. Check for updates

✅ Skills Already Up to Date

Current version: def5678
Last checked: 2 minutes ago

All 5 skills are current:
- work-summary
- test-analyzer
- pr-review
- api-doc
- db-migration

Next auto-update in ~28 minutes.
```

### Example 3: Update with Conflicts
```
User: "/update-skills"

You:
1. Attempt update
2. Detect local changes

⚠️ Local Changes Detected

You have uncommitted changes in:
- test-analyzer/SKILL.md

Options:
1. Stash your changes and update (run: git stash && git pull)
2. Commit your changes first
3. View your changes (run: git diff)

What would you like to do?
```

## Tips

- **Run before using skills**: If something seems wrong, try updating first
- **Check the log**: Review `~/.claude/skills/supatest-update.log` for auto-update history
- **Fast updates**: This is faster than waiting for the next auto-update
- **Show changes**: Always show what changed so user knows what's new
- **Non-destructive**: Never force-pull or discard changes without asking

## Notes

- This complements the automatic updates (every 30 minutes)
- Safe to run anytime - won't break anything
- If auto-updates are disabled, this is the manual alternative
- Can be run multiple times without issues
