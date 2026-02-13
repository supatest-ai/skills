#!/bin/bash
# Setup Claude Code hook to auto-update skills
# This integrates with Claude Code's hook system

CLAUDE_CONFIG="${HOME}/.claude/settings.json"
SKILLS_DIR="${HOME}/.claude/skills/supatest"
UPDATE_SCRIPT="${SKILLS_DIR}/scripts/auto-update.sh"

echo "🪝 Setting up Claude Code hook for auto-update..."

if [ ! -f "${CLAUDE_CONFIG}" ]; then
    echo "❌ Claude settings.json not found"
    exit 1
fi

# Check if hook already exists
if grep -q "supatest" "${CLAUDE_CONFIG}" 2>/dev/null; then
    echo "⚠️  Hook may already be configured"
    echo "   Check ${CLAUDE_CONFIG} to verify"
else
    echo "📝 To set up automatic updates when Claude Code starts:"
    echo ""
    echo "1. Open Claude Code settings (Cmd/Ctrl + ,)"
    echo "2. Search for 'hooks'"
    echo "3. Add this to your user-login hook:"
    echo ""
    echo "   ${UPDATE_SCRIPT}"
    echo ""
    echo "Or manually edit ${CLAUDE_CONFIG}"
fi

echo ""
echo "Alternative: Use launchd (macOS) or systemd (Linux) for scheduled updates"
echo "Run: ./scripts/setup-scheduled.sh"
