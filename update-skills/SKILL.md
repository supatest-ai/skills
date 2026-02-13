# Update Supatest Skills

Manually update the Supatest AI skills to get the latest changes from the repository. Also checks for and suggests installing recommended public skills.

## When to use this skill

Use this skill when you need to:
- Pull the latest skills updates immediately
- Check if there are new skills available
- Update skills outside of the automatic update schedule
- See which recommended public skills you're missing
- Install recommended public skills
- Troubleshoot skill updates

## Instructions

When the user invokes this skill:

### Part 1: Update Company Skills

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
   ✅ Company Skills Updated Successfully

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
   ✅ Company Skills Already Up to Date

   Current version: [commit hash]
   Last update: [time]

   All company skills are current. Next auto-update in ~30 minutes.
   ```

6. **Handle Errors**
   If update fails:
   - Check for merge conflicts
   - Check network connectivity
   - Suggest running: `~/.claude/skills/supatest/scripts/auto-update.sh`
   - Offer to stash local changes if needed

### Part 2: Check Recommended Public Skills

7. **Read README for Recommended Skills**
   - Read `~/.claude/skills/supatest/README.md`
   - Look for the "🌟 Recommended Public Skills" section
   - Parse the table to extract:
     - Repository names (from the markdown links)
     - Repository URLs (from the markdown links)
     - Descriptions
     - Install commands

8. **Check What's Installed**
   - List all directories in `~/.claude/skills/`
   - Compare with recommended skills from README
   - Identify which recommended skills are:
     - ✅ Already installed
     - ❌ Not installed yet

9. **Report Recommended Skills Status**
   Show a summary:
   ```
   ## 🌟 Recommended Public Skills

   ✅ Installed:
   - anthropic (Official Anthropic skills)

   ❌ Not Installed:
   - community (Awesome Claude Skills)
   - composio (ComposioHQ Skills)
   ```

10. **Recommend Missing Skills**
    If there are missing recommended skills, show:
    ```
    💡 Recommended Public Skills You Could Install:

    1. community - Awesome Claude Skills
       Install: cd ~/.claude/skills && git clone https://github.com/travisvn/awesome-claude-skills.git community

    2. composio - ComposioHQ Skills
       Install: cd ~/.claude/skills && git clone https://github.com/ComposioHQ/awesome-claude-skills.git composio

    You can copy and paste the install commands above to install them.
    ```

    **Do NOT automatically install** - just show the recommendations and commands.
    Let the user decide if they want to install any.

11. **Suggest Updating Installed Public Skills**
    If user has public skills already installed, show:
    ```
    📦 Installed Public Skills:
    - anthropic (Official Anthropic skills)
    - community (Awesome Claude Skills)

    To update: cd ~/.claude/skills/<name> && git pull
    ```

    **Do NOT automatically update** - just show what's installed and how to update.

## Example Output

```
User: "/update-skills"

You:
# Updating Supatest Skills...

## ✅ Company Skills Updated

Previous: abc1234
Current: def5678

Changes pulled:
- Add commit and commit-all skills
- Update work-summary format

Skills modified:
- work-summary

New skills:
- commit
- commit-all

---

## 🌟 Recommended Public Skills

✅ Installed:
- anthropic (Official Anthropic skills)

💡 Not Installed (Recommended):

1. community - Awesome Claude Skills
   Install: cd ~/.claude/skills && git clone https://github.com/travisvn/awesome-claude-skills.git community

2. composio - ComposioHQ Skills
   Install: cd ~/.claude/skills && git clone https://github.com/ComposioHQ/awesome-claude-skills.git composio

Copy and paste the install commands above if you'd like to add them!

---

📦 Update Installed Public Skills:
- anthropic: cd ~/.claude/skills/anthropic && git pull
```

## Tips

- **Read README carefully**: Parse the markdown table to extract URLs and names
- **Look for table format**: | [Name](URL) | Description | Install Command |
- **Just recommend, don't install**: Show install commands, let user copy/paste
- **Non-destructive**: Never automatically install or force-pull anything
- **Show commands clearly**: Make it easy for user to copy/paste
- **Extract from install command**: The README table has install commands with the directory name
- **Don't ask permission**: Just show recommendations and commands

## Notes

- This complements the automatic updates (every 30 minutes) for company skills
- Public skills don't auto-update - must be updated manually
- Safe to run anytime - won't break anything
- Can be run multiple times without issues
- The README is the source of truth for recommended skills
- Parse the markdown table to get the correct repository URLs and install commands
- **Never automatically install** - only show recommendations and commands
- Let the user decide and copy/paste commands themselves
