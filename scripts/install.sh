#!/bin/bash
# Supatest AI Skills Installer
# Installs skills globally and sets up auto-update

set -e

SKILLS_DIR="${HOME}/.claude/skills/supatest"
REPO_URL="git@github.com:supatest-ai/skills.git"
CRON_JOB="0 */6 * * * cd ${SKILLS_DIR} && git pull --quiet > /dev/null 2>&1"

echo "🚀 Installing Supatest AI Skills..."

# Create skills directory if it doesn't exist
mkdir -p "${HOME}/.claude/skills"

# Clone or update repository
if [ -d "${SKILLS_DIR}" ]; then
    echo "📦 Skills already installed. Updating..."
    cd "${SKILLS_DIR}"
    git pull
else
    echo "📦 Cloning skills repository..."
    git clone "${REPO_URL}" "${SKILLS_DIR}"
fi

echo "✅ Skills installed at: ${SKILLS_DIR}"

# Setup auto-update
echo ""
echo "🔄 Setting up auto-update..."
read -p "Do you want to enable automatic updates every 6 hours? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "${SKILLS_DIR}"; then
        echo "⚠️  Auto-update already configured"
    else
        # Add cron job
        (crontab -l 2>/dev/null; echo "${CRON_JOB}") | crontab -
        echo "✅ Auto-update enabled (every 6 hours)"
        echo "   To disable: crontab -e and remove the line containing '${SKILLS_DIR}'"
    fi
else
    echo "⏭️  Skipping auto-update setup"
    echo "   You can manually update anytime with: cd ${SKILLS_DIR} && git pull"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Available skills:"
ls -1 "${SKILLS_DIR}" | grep -v "^\." | grep -v "scripts" | grep -v "README" | grep -v "LICENSE" | while read skill; do
    if [ -d "${SKILLS_DIR}/${skill}" ]; then
        echo "  - ${skill}"
    fi
done
echo ""
echo "Usage: Invoke skills with /skill-name or let Claude suggest them automatically"
echo "Update manually: cd ${SKILLS_DIR} && git pull"
