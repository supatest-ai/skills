# Update Skills

Manually update these Claude skills to get the latest changes from the repository. Also checks for and suggests installing recommended public skills.

## When to use this skill

Use this skill when you need to:
- Pull the latest skills updates immediately
- Check if there are new skills available
- Update skills outside of the automatic update schedule
- See which recommended public skills you're missing
- Troubleshoot skill updates

## Instructions

When the user invokes this skill:

### Part 1: Update This Skills Repo

1. **Find the Skills Directory**
   - This skill lives somewhere inside `~/.claude/skills/`
   - Detect the install path by checking common locations or looking for a directory containing this `update-skills/SKILL.md` file
   - If not found, inform the user they need to install first

2. **Show Current Status**
   - Run `git status` in the skills directory to show current state
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
   ```

   Or if already up to date:
   ```
   ✅ Skills Already Up to Date

   Current version: [commit hash]
   Last update: [time]
   ```

6. **Handle Errors**
   If update fails:
   - Check for merge conflicts
   - Check network connectivity
   - Offer to stash local changes if needed

### Part 2: Check Recommended Public Skills

7. **Read README for Recommended Skills**
   - Read the `README.md` in the skills directory
   - Look for the "🌟 Recommended Public Skills" section (or similar)
   - Parse the table to extract repository names, URLs, descriptions, and install commands

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
   ```

10. **Recommend Missing Skills**
    If there are missing recommended skills, show install commands and let the user decide:
    ```
    💡 Recommended Public Skills You Could Install:

    1. community - Awesome Claude Skills
       Install: cd ~/.claude/skills && git clone https://github.com/travisvn/awesome-claude-skills.git community
    ```

    **Do NOT automatically install** — just show the commands.

11. **Suggest Updating Installed Public Skills**
    If user has other public skills installed, show how to update them:
    ```
    📦 To update installed public skills:
    cd ~/.claude/skills/<name> && git pull
    ```

    **Do NOT automatically update** — just show the commands.

## Example Output

```
User: "/update-skills"

You:
# Updating Skills...

## ✅ Skills Updated

Previous: abc1234
Current: def5678

Changes pulled:
- Add test-feature skill
- Update work-summary format

Skills modified:
- work-summary

New skills:
- test-feature

---

## 🌟 Recommended Public Skills

✅ Installed:
- anthropic (Official Anthropic skills)

💡 Not Installed (Recommended):

1. community - Awesome Claude Skills
   Install: cd ~/.claude/skills && git clone https://github.com/travisvn/awesome-claude-skills.git community

---

📦 Update Installed Public Skills:
- anthropic: cd ~/.claude/skills/anthropic && git pull
```

## Tips

- **Detect path dynamically**: Don't assume a fixed install directory name
- **Read README carefully**: Parse the markdown table to extract URLs and names
- **Just recommend, don't install**: Show install commands, let user copy/paste
- **Non-destructive**: Never automatically install or force-pull anything
- **Show commands clearly**: Make it easy for user to copy/paste

## Notes

- Public skills don't auto-update — must be updated manually
- Safe to run anytime — won't break anything
- Can be run multiple times without issues
- The README is the source of truth for recommended skills
- **Never automatically install** — only show recommendations and commands
