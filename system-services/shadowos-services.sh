#!/bin/bash
# ============================================================================
# ShadowOS Systemd Service Manager
# Install and manage ShadowOS custom services
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
SERVICE_DIR="/etc/systemd/system"

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

install_service() {
    local name="$1"
    local content="$2"
    
    echo "$content" > "$SERVICE_DIR/$name"
    chmod 644 "$SERVICE_DIR/$name"
    systemctl daemon-reload
    systemctl enable "$name" 2>/dev/null || true
    success "Service installed: $name"
}

# ─── Ollama Service ─────────────────────────────────────────────────────
step "INSTALLING SHADOWOS SERVICES"

install_service "shadowos-ai.service" '
[Unit]
Description=ShadowOS AI Engine (Ollama)
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/ollama serve
Restart=always
RestartSec=10
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_MODELS=/opt/ShadowOS/ai/models"

[Install]
WantedBy=multi-user.target
'

install_service "shadowos-monitor.service" '
[Unit]
Description=ShadowOS System Monitor
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/ShadowOS/system-services/shadowos-monitor.sh live
Restart=always
RestartSec=30
StandardOutput=append:/var/log/shadowos-monitor.log
StandardError=append:/var/log/shadowos-monitor.log

[Install]
WantedBy=multi-user.target
'

install_service "shadowos-privacy.service" '
[Unit]
Description=ShadowOS Privacy Services
After=network.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/opt/ShadowOS/system-services/tor-privacy.sh start
ExecStop=/opt/ShadowOS/system-services/tor-privacy.sh stop

[Install]
WantedBy=multi-user.target
'

install_service "shadowos-security.service" '
[Unit]
Description=ShadowOS Security Monitor
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c "while true; do aide --check 2>/dev/null | logger -t shadowos-aide; sleep 3600; done"
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
'

install_service "shadowos-bluetooth.service" '
[Unit]
Description=ShadowOS Bluetooth Security
After=bluetooth.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/opt/ShadowOS/security-hardening/bluetooth-hardening.sh harden

[Install]
WantedBy=multi-user.target
'

install_service "shadowos-usbguard.service" '
[Unit]
Description=ShadowOS USBGuard — USB Device Authorization
After=systemd-udevd.service

[Service]
Type=simple
ExecStart=/usr/sbin/usbguard-daemon
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
'

install_service "shadowos-update.service" '
[Unit]
Description=ShadowOS Automatic Updates
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/ShadowOS/scripts/auto-update.sh

[Install]
WantedBy=multi-user.target
'

install_service "shadowos-update.timer" '
[Unit]
Description=Run ShadowOS Updates Daily

[Timer]
OnBootSec=5min
OnUnitActiveSec=1d
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target
'

install_service "shadowos-boot-status.service" '
[Unit]
Description=ShadowOS Boot Status Display
After=graphical.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "
    echo ''
    echo '╔══════════════════════════════════════════════════╗'
    echo '║  🌑 SHADOWOS - System Ready                     ║'
    echo '╠══════════════════════════════════════════════════╣'
    echo '║  Run shadowos-status for system overview        ║'
    echo '║  Run ai <prompt> for AI assistance              ║'
    echo '║  Run tor-privacy.sh status for privacy status   ║'
    echo '╚══════════════════════════════════════════════════╝'
"

[Install]
WantedBy=multi-user.target
'

# ─── Enable Services ─────────────────────────────────────────────────────
step "ENABLING SERVICES"

for svc in shadowos-ai shadowos-monitor shadowos-privacy shadowos-security shadowos-bluetooth shadowos-usbguard shadowos-update.timer shadowos-boot-status; do
    systemctl enable "$svc" 2>/dev/null && success "Enabled: $svc" || warn "Could not enable: $svc"
done

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ All ShadowOS services installed${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}Services:${NC}"
echo -e "    • shadowos-ai        — Ollama AI engine"
echo -e "    • shadowos-monitor   — System dashboard"
echo -e "    • shadowos-privacy   — Tor/VPN privacy"
echo -e "    • shadowos-security  — File integrity monitoring"
echo -e "    • shadowos-bluetooth — Bluetooth hardening"
echo -e "    • shadowos-usbguard  — USB device authorization"
echo -e "    • shadowos-update    — Daily auto-updates"
echo -e "    • shadowos-boot-status — Boot welcome message"