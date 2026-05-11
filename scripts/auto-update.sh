#!/bin/bash
# ============================================================================
# ShadowOS Automatic Update Script
# Runs daily via systemd timer
# ============================================================================
set -euo pipefail

LOG="/var/log/shadowos-updates.log"
exec >> "$LOG" 2>&1

echo "[$(date)] Starting ShadowOS auto-update..."

# Update package lists
apt-get update -qq

# Count upgradable packages
UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo 0)

if [ "$UPDATES" -gt 0 ]; then
    echo "[$(date)] Found $UPDATES packages to update"
    
    # Perform upgrade
    apt-get upgrade -y -qq
    apt-get autoremove -y -qq
    apt-get autoclean -qq
    
    # Update AI models if Ollama is running
    if pgrep -x ollama > /dev/null; then
        echo "[$(date)] Checking for model updates..."
        ollama list 2>/dev/null | tail -n +2 | while read model; do
            model_name=$(echo "$model" | awk '{print $1}')
            ollama pull "$model_name" 2>/dev/null || true
        done
    fi
    
    # Update Neovim plugins
    if [ -d /usr/share/nvim/site/pack ]; then
        nvim --headless -c "PlugUpdate" -c "qa!" 2>/dev/null || true
    fi
    
    echo "[$(date)] Update complete"
else
    echo "[$(date)] System already up to date"
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "[$(date)] WARNING: Disk usage at ${DISK_USAGE}%"
fi

echo "[$(date)] Auto-update finished"
echo ""