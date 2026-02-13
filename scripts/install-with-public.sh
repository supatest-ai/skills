#!/bin/bash
# Supatest AI Skills Installer with Public Skills
# Installs company skills + recommended public skills

set -e

SKILLS_DIR="${HOME}/.claude/skills"
COMPANY_SKILLS="${SKILLS_DIR}/supatest"
REPO_URL="git@github.com:supatest-ai/skills.git"

# Public skill repositories to install
PUBLIC_SKILLS=(
    "https://github.com/anthropics/skills.git|anthropic|Official Anthropic skills"
    # Add more public repos here:
    # "https://github.com/user/repo.git|name|Description"
)

echo "🚀 Installing Supatest AI Skills + Public Skills..."
echo ""

# Create skills directory
mkdir -p "${SKILLS_DIR}"

# Install company skills
if [ -d "${COMPANY_SKILLS}" ]; then
    echo "📦 Company skills already installed. Updating..."
    cd "${COMPANY_SKILLS}"
    git pull
else
    echo "📦 Cloning company skills..."
    git clone "${REPO_URL}" "${COMPANY_SKILLS}"
fi

echo "✅ Company skills installed at: ${COMPANY_SKILLS}"
echo ""

# Install public skills
if [ ${#PUBLIC_SKILLS[@]} -gt 0 ]; then
    echo "🌐 Installing public skills..."
    echo ""

    for skill_info in "${PUBLIC_SKILLS[@]}"; do
        IFS='|' read -r url name description <<< "$skill_info"
        skill_path="${SKILLS_DIR}/${name}"

        if [ -d "${skill_path}" ]; then
            echo "  ✓ ${name}: Already installed (${description})"
        else
            echo "  📥 Installing ${name}: ${description}"
            if git clone "${url}" "${skill_path}" 2>/dev/null; then
                echo "  ✅ ${name} installed"
            else
                echo "  ⚠️  Failed to install ${name} (skipping)"
            fi
        fi
    done

    echo ""
fi

# Setup auto-update for company skills
cd "${COMPANY_SKILLS}"
echo "🔄 Setting up automatic updates for company skills..."
read -p "Enable automatic updates every 30 minutes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/setup-launchd.sh
else
    echo "⏭️  Skipping auto-update setup"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "📚 Installed skill directories:"
ls -1 "${SKILLS_DIR}" | while read dir; do
    if [ -d "${SKILLS_DIR}/${dir}" ]; then
        echo "  - ${dir}"
    fi
done

echo ""
echo "Usage: Invoke skills with /skill-name or let Claude suggest them automatically"
echo ""
echo "Update company skills:"
echo "  - Auto: Every 30 minutes (if enabled)"
echo "  - Manual: /update-skills"
echo ""
echo "Update public skills:"
echo "  cd ~/.claude/skills/<skill-dir> && git pull"
