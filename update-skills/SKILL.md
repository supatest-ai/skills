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

10. **Offer to Install Missing Skills**
    If there are missing recommended skills, ask:
    ```
    Would you like to install any of the missing recommended skills?

    1. community - Awesome Claude Skills
    2. composio - ComposioHQ Skills
    3. All of them
    4. None, skip
    ```

11. **Install Selected Skills**
    For each skill the user wants to install:
    - Extract the git clone command from the README table
    - Run the command: `cd ~/.claude/skills && git clone <url> <name>`
    - Confirm success or report errors
    - Show what skills are now available from that repository

12. **Update Installed Public Skills (Optional)**
    If user has public skills already installed, ask:
    ```
    Would you like to update your installed public skills?
    - anthropic
    - community
    ```

    If yes, for each:
    - `cd ~/.claude/skills/<name> && git pull`
    - Report what updated or if already up to date

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
- anthropic (Official Anthropic skills) - Up to date

❌ Not Installed:
- community (Awesome Claude Skills)
- composio (ComposioHQ Skills)

Would you like to install any missing skills?
1. community - Curated collection of community skills
2. composio - Another curated skill collection
3. All
4. Skip

User: "1"

You:
Installing community skills...

cd ~/.claude/skills && git clone https://github.com/travisvn/awesome-claude-skills.git community

✅ Community skills installed!

All recommended skills are now installed. You can use any skill from:
- supatest (company skills)
- anthropic (official skills)
- community (community skills)
```

## Tips

- **Read README carefully**: Parse the markdown table to extract URLs and names
- **Look for table format**: | [Name](URL) | Description | Install Command |
- **Check before cloning**: Don't clone if directory already exists
- **Show what's available**: After installing, list what skills are now available
- **Non-destructive**: Never force-pull or discard changes without asking
- **Update public skills**: Offer to update already-installed public skills too
- **Extract from install command**: The README table has install commands with the directory name

## Notes

- This complements the automatic updates (every 30 minutes) for company skills
- Public skills don't auto-update - must be updated manually
- Safe to run anytime - won't break anything
- Can be run multiple times without issues
- The README is the source of truth for recommended skills
- Parse the markdown table to get the correct repository URLs and install commands
