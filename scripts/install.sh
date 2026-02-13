#!/bin/bash
# Supatest AI Skills Installer for macOS
# Installs skills globally and sets up auto-update via launchd

set -e

SKILLS_DIR="${HOME}/.claude/skills/supatest"
REPO_URL="git@github.com:supatest-ai/skills.git"
PLIST_FILE="${HOME}/Library/LaunchAgents/com.supatest.skills-updater.plist"

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

# Setup auto-update with launchd
echo ""
echo "🔄 Setting up automatic updates..."
read -p "Enable automatic updates every 30 minutes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "${HOME}/Library/LaunchAgents"

    # Create plist file
    cat > "${PLIST_FILE}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.supatest.skills-updater</string>

    <key>ProgramArguments</key>
    <array>
        <string>${SKILLS_DIR}/scripts/auto-update.sh</string>
    </array>

    <key>StartInterval</key>
    <integer>1800</integer>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>${HOME}/.claude/skills/supatest-update.log</string>

    <key>StandardErrorPath</key>
    <string>${HOME}/.claude/skills/supatest-update-error.log</string>
</dict>
</plist>
EOF

    # Load the agent
    launchctl unload "${PLIST_FILE}" 2>/dev/null || true
    launchctl load "${PLIST_FILE}"

    echo "✅ Auto-update enabled (every 30 minutes via launchd)"
    echo "   Logs: tail -f ${HOME}/.claude/skills/supatest-update.log"
    echo "   Stop: launchctl unload ${PLIST_FILE}"
else
    echo "⏭️  Skipping auto-update setup"
    echo "   You can set it up later with: ${SKILLS_DIR}/scripts/setup-launchd.sh"
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
echo "Manual update: cd ${SKILLS_DIR} && git pull"
