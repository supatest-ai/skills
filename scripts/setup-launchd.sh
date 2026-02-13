#!/bin/bash
# Setup launchd agent for macOS to auto-update skills

SKILLS_DIR="${HOME}/.claude/skills/supatest"
PLIST_FILE="${HOME}/Library/LaunchAgents/com.supatest.skills-updater.plist"

echo "🍎 Setting up launchd agent for automatic updates (macOS)..."

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
    <integer>21600</integer> <!-- 6 hours -->

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>${HOME}/.claude/skills/supatest-update.log</string>

    <key>StandardErrorPath</key>
    <string>${HOME}/.claude/skills/supatest-update-error.log</string>
</dict>
</plist>
EOF

echo "✅ Created plist file: ${PLIST_FILE}"

# Load the agent
launchctl unload "${PLIST_FILE}" 2>/dev/null || true
launchctl load "${PLIST_FILE}"

echo "✅ launchd agent loaded and running"
echo ""
echo "The skills will now update automatically every 6 hours"
echo ""
echo "Useful commands:"
echo "  Check status:  launchctl list | grep supatest"
echo "  View logs:     tail -f ${HOME}/.claude/skills/supatest-update.log"
echo "  Stop updates:  launchctl unload ${PLIST_FILE}"
echo "  Start updates: launchctl load ${PLIST_FILE}"
echo "  Manual update: ${SKILLS_DIR}/scripts/auto-update.sh"
