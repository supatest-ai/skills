#!/bin/bash
# Auto-update script for Supatest AI Skills
# This can be run manually or via cron

SKILLS_DIR="${HOME}/.claude/skills/supatest"
LOG_FILE="${HOME}/.claude/skills/supatest-update.log"

# Ensure we're in the skills directory
if [ ! -d "${SKILLS_DIR}" ]; then
    echo "$(date): Skills directory not found at ${SKILLS_DIR}" >> "${LOG_FILE}"
    exit 1
fi

cd "${SKILLS_DIR}"

# Fetch latest changes
git fetch origin main --quiet 2>&1

# Check if updates are available
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "$(date): Updating skills..." >> "${LOG_FILE}"

    # Stash any local changes (shouldn't be any, but just in case)
    git stash --quiet 2>&1

    # Pull updates
    if git pull --quiet origin main 2>&1; then
        echo "$(date): Skills updated successfully" >> "${LOG_FILE}"

        # Log what changed
        git log --oneline "$LOCAL..$REMOTE" >> "${LOG_FILE}"
    else
        echo "$(date): Failed to update skills" >> "${LOG_FILE}"
        exit 1
    fi
else
    echo "$(date): Skills already up to date" >> "${LOG_FILE}"
fi
