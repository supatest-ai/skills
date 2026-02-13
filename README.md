# Supatest AI - Shared Claude Skills

This repository contains organization-wide Claude skills for the Supatest AI team. These skills work across Claude Code, Claude.ai, and Claude Desktop.

## 📦 Installation

### Quick Install (Recommended)

```bash
# Clone and run the installer
git clone git@github.com:supatest-ai/skills.git /tmp/supatest-skills
cd /tmp/supatest-skills
./scripts/install.sh
```

The installer will:
- Install skills to `~/.claude/skills/supatest`
- Optionally set up automatic updates every 30 minutes
- Show you all available skills

### Install with Public Skills

To install company skills + recommended public skills:

```bash
cd /tmp/supatest-skills
./scripts/install-with-public.sh
```

This installs:
- Your company skills (supatest)
- Public skills from `public-skills.json` (e.g., Anthropic official skills)

All skills will be available across all your projects!

### Manual Installation

#### For Global Access (All Projects)

```bash
# Clone into your global skills directory
cd ~/.claude/skills/
git clone git@github.com:supatest-ai/skills.git supatest
```

#### For Project-Specific Use

```bash
# Clone into your project
cd your-project/.claude/skills/
git clone git@github.com:supatest-ai/skills.git supatest
```

## 🎯 Available Skills

### work-summary
Generate comprehensive work summaries from git commits across multiple repositories with task categorization.

**Usage:** `/work-summary <author> "<start_datetime>" "<end_datetime>" <repo1> [repo2]...`

**Example:** `/work-summary Prasad "2026-02-13 09:00" "2026-02-13 18:00" supatest`

### update-skills
Manually update Supatest skills to get the latest changes immediately.

**Usage:** Invoke with `/update-skills` to pull latest skills updates.

### signoz-health-check
Perform comprehensive health checks of the SigNoz observability platform, analyzing services, logs, metrics, traces, and alerts.

**Usage:** Invoke with `/signoz-health-check [timeRange]` to check system health (e.g., `/signoz-health-check 24h`).

### commit
Commit staged files with well-structured commit messages following conventional commits format.

**Usage:** Invoke with `/commit` to commit already staged files.

### commit-all
Stage all changes and commit with well-structured commit messages following conventional commits format.

**Usage:** Invoke with `/commit-all` to stage and commit everything.

## 🔄 Auto-Update

Skills automatically update every 30 minutes in the background. The installer sets this up for you!

If you skipped auto-update during installation, enable it anytime:
```bash
cd ~/.claude/skills/supatest
./scripts/setup-launchd.sh
```

**Management commands:**
```bash
# View update log
tail -f ~/.claude/skills/supatest-update.log

# Check if updater is running
launchctl list | grep supatest

# Disable auto-updates
launchctl unload ~/Library/LaunchAgents/com.supatest.skills-updater.plist

# Re-enable auto-updates
launchctl load ~/Library/LaunchAgents/com.supatest.skills-updater.plist

# Manual update
cd ~/.claude/skills/supatest && git pull
```

## 🌐 Adding Public Skills

You can install public skills from any GitHub repository alongside company skills.

### Method 1: Install to Separate Directory (Easiest)

```bash
cd ~/.claude/skills/
git clone https://github.com/user/their-skills.git their-skills
```

Skills from all directories in `~/.claude/skills/` are available!

### Method 2: Add to Company Config

Edit `public-skills.json` and add the repository:

```json
{
  "public_skills": [
    {
      "name": "anthropic",
      "url": "https://github.com/anthropics/skills.git",
      "description": "Official Anthropic skills",
      "enabled": true
    },
    {
      "name": "your-skills",
      "url": "https://github.com/user/skills.git",
      "description": "Description here",
      "enabled": true
    }
  ]
}
```

Then run `./scripts/install-with-public.sh` to install for everyone.

### Popular Public Skill Repositories

- [Anthropic Official Skills](https://github.com/anthropics/skills)
- [Awesome Claude Skills](https://github.com/travisvn/awesome-claude-skills)
- [ComposioHQ Skills](https://github.com/ComposioHQ/awesome-claude-skills)

### Updating Public Skills

Public skills don't auto-update. Update manually:

```bash
cd ~/.claude/skills/anthropic
git pull
```

## 📝 Contributing

1. Create a new branch for your skill
2. Add your skill in its own directory with a `SKILL.md` file
3. Update this README with skill documentation
4. Submit a PR for team review

## 📚 Skill Structure

Each skill should have:
- `SKILL.md` - The skill definition
- `README.md` - Documentation and examples (optional)
- `examples/` - Example usage (optional)

## 🔗 Resources

- [Claude Skills Documentation](https://code.claude.com/docs/en/skills)
- [Anthropic Skills Repository](https://github.com/anthropics/skills)
- [Skills Best Practices](https://zackproser.com/blog/claude-skills-internal-training)
