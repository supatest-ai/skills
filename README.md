# Supatest AI - Shared Claude Skills

This repository contains organization-wide Claude skills for the Supatest AI team. These skills work across Claude Code, Claude.ai, and Claude Desktop.

## 📦 Installation

### For Global Access (All Projects)

```bash
# Clone into your global skills directory
cd ~/.claude/skills/
git clone git@github.com:supatest-ai/skills.git supatest

# Or create a symlink
ln -s /path/to/this/repo ~/.claude/skills/supatest
```

### For Project-Specific Use

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

## 🔄 Updating Skills

```bash
cd ~/.claude/skills/supatest
git pull origin main
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
