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
Generate comprehensive work summaries from git commits, including PR-ready descriptions and release notes.

**Usage:** Invoke with `/work-summary` or let Claude auto-suggest when discussing commits/PRs.

### test-analyzer
Analyze failing tests from Supatest runs and provide detailed debugging context.

**Usage:** Invoke with `/test-analyzer` when investigating test failures.

### pr-review
Perform thorough code reviews following Supatest's standards and best practices.

**Usage:** Invoke with `/pr-review` when reviewing pull requests.

### api-doc
Generate comprehensive API documentation from code, including OpenAPI specs.

**Usage:** Invoke with `/api-doc` when documenting APIs.

### db-migration
Generate safe, reversible database migrations with proper validation and rollback strategies.

**Usage:** Invoke with `/db-migration` when creating schema changes.

### update-skills
Manually update Supatest skills to get the latest changes immediately.

**Usage:** Invoke with `/update-skills` to pull latest skills updates.

### signoz-health-check
Perform comprehensive health checks of the SigNoz observability platform, analyzing services, logs, metrics, traces, and alerts.

**Usage:** Invoke with `/signoz-health-check [timeRange]` to check system health (e.g., `/signoz-health-check 24h`).

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
