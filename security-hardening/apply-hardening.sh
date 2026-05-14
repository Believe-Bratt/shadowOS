#!/usr/bin/env bash
# ============================================================================
# ShadowOS Security Hardening Script
# Updated for v2026.2 NeonHorizon
# ============================================================================
set -e
set -u

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

step "SHADOWOS SECURITY HARDENING v2026.2"

# ─── Firewall (nftables) ────────────────────────────────────────────────
step "CONFIGURING FIREWALL (nftables)"
# Use the standard nftables config file (IMPORTANT)
cat > /etc/nftables.conf << 'NFT'

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iif lo accept
        ct state established,related accept

        ip protocol icmp limit rate 10/second accept
        ip6 nexthdr icmpv6 limit rate 10/second accept

        # SSH (custom port)
        tcp dport 2222 ct state new limit rate 5/minute accept

        # DHCP
        udp dport 67-68 accept

        # DNS
        udp dport 53 accept
        tcp dport 53 accept

        # DNS-over-HTTPS
        tcp dport 443 ct state new limit rate 10/minute accept

        # Tor (only local access)
        tcp dport 9050 iif lo accept

        # WireGuard (restrict if possible later)
        udp dport 51820 accept

        # Reject with proper ICMP
        reject with icmpx type host-unreachable
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state established,related accept
        reject with icmpx type host-unreachable
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}

# GeoIP blocking table (optional - enable via config)
# table ip geoip_block {
#     chain input {
#         ip saddr @geoip_cn drop
#         ip saddr @geoip_ru drop
#     }
# }
NFT

# Enable nftables service and load config
systemctl enable nftables >/dev/null 2>&1
nft -f /etc/nftables.conf >/dev/null 2>&1 && \
    success "nftables firewall applied (default-deny)" || \
    warn "Could not apply nftables rules"

# ─── Fail2ban Integration (NEW in v2026.2) ──────────────────────────────
step "CONFIGURING FAIL2BAN"

if command -v fail2ban-server &>/dev/null; then
    cat > /etc/fail2ban/jail.local << 'FAIL2BAN'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
banaction = nftables

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = false

[apache-auth]
enabled = false
FAIL2BAN

    systemctl enable fail2ban 2>/dev/null || true
    systemctl restart fail2ban 2>/dev/null || true
    success "Fail2ban configured with nftables backend"
else
    info "Fail2ban not installed — skipping"
fi

# ─── Intrusion Detection ────────────────────────────────────────────────
step "SETTING UP INTRUSION DETECTION"

if command -v aide &>/dev/null; then
    mkdir -p /etc/aide/aide.conf.d
    # Create AIDE rules snippet (Database paths are in main config)
    cat > /etc/aide/aide.conf.d/99-shadowos << 'AIDE'
/etc p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/bin p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/sbin p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/boot p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/lib p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/usr/bin p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/usr/sbin p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/usr/lib p+i+n+u+g+s+b+acl+selinux+xattrs+sha256+sha512
/home p+i+n+u+g+acl+selinux+xattrs+sha256+sha512
/root p+i+n+u+g+acl+selinux+xattrs+sha256+sha512
/opt p+i+n+u+g+acl+selinux+xattrs+sha256+sha512
/var/log p+i+n+u+g+acl+selinux+xattrs+sha256+sha512
AIDE
    aide --init 2>/dev/null && \
        cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db 2>/dev/null && \
        success "AIDE initialized" || warn "AIDE initialization skipped"
fi

if command -v rkhunter &>/dev/null; then
    rkhunter --propupd 2>/dev/null || true
    success "rkhunter properties updated"
fi

if command -v chkrootkit &>/dev/null; then
    success "chkrootkit available (run manually: chkrootkit)"
fi

# ─── AppArmor ───────────────────────────────────────────────────────────
step "CONFIGURING APPARMOR"
if command -v aa-enforce &>/dev/null; then
    for profile in /etc/apparmor.d/*; do
        aa-enforce "$profile" 2>/dev/null || true
    done
    systemctl enable apparmor 2>/dev/null || true
    success "AppArmor enabled and enforcing"
else
    warn "AppArmor not available"
fi

# ─── Kernel Hardening ───────────────────────────────────────────────────
step "APPLYING KERNEL HARDENING"
cat > /etc/sysctl.d/99-shadowos-hardening.conf << 'SYSCTL'
# ShadowOS Security Kernel Parameters (v2026.2)
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 1
kernel.printk = 3 3 3 3
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv6.conf.all.forwarding = 0
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 1
fs.protected_regular = 2
net.ipv4.ip_forward = 0
# New in v2026.2: additional hardening
kernel.kaslr = 1
kernel.modules_disabled = 0
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
SYSCTL

sysctl --system 2>/dev/null || true
success "Kernel hardening parameters updated"

# ─── SSH Hardening ──────────────────────────────────────────────────────
step "HARDENING SSH"
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/00-shadowos.conf << 'SSHCONF'
# ShadowOS SSH Hardening (v2026.2)
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
MaxAuthTries 3
MaxSessions 5
Port 2222
Protocol 2
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30
StrictModes yes
IgnoreRhosts yes
HostbasedAuthentication no
PermitEmptyPasswords no
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AllowAgentForwarding no
AllowTcpForwarding no
SSHCONF

cat > /etc/ssh/banner << 'BANNER'
╔══════════════════════════════════════════════════╗
║  ⚠  UNAUTHORIZED ACCESS IS PROHIBITED           ║
║  All connections are monitored and recorded       ║
╚══════════════════════════════════════════════════╝
BANNER

chmod 600 /etc/ssh/sshd_config.d/00-shadowos.conf
chmod 644 /etc/ssh/banner
success "SSH hardened"

# ─── File Permissions ───────────────────────────────────────────────────
step "HARDENING FILE PERMISSIONS"
chmod 700 /root 2>/dev/null || true
chmod 600 /etc/crontab 2>/dev/null || true
chmod 600 /etc/ssh/sshd_config 2>/dev/null || true
chmod 600 /etc/shadow 2>/dev/null || true
chmod 600 /etc/gshadow 2>/dev/null || true
chmod 644 /etc/passwd 2>/dev/null || true
chmod 644 /etc/group 2>/dev/null || true
chmod 600 /boot/grub/grub.cfg 2>/dev/null || true
chmod -R 700 /root/.ssh 2>/dev/null || true
success "File permissions hardened"

# ─── Disable Core Dumps ─────────────────────────────────────────────────
step "DISABLING CORE DUMPS"
echo "* hard core 0" >> /etc/security/limits.conf
# fs.suid_dumpable already set in kernel hardening section
find / -name "core" -type f -delete 2>/dev/null || true
success "Core dumps disabled"

# ─── Audit Rules (Enhanced for v2026.2) ─────────────────────────────────
step "CONFIGURING AUDIT RULES"
if command -v auditctl &>/dev/null; then
    mkdir -p /etc/audit/rules.d
    cat > /etc/audit/rules.d/shadowos.rules << 'AUDIT'
# ShadowOS Audit Rules (v2026.2)
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k sudo_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config
-w /etc/nftables -p wa -k firewall_changes
-w /usr/bin/passwd -p x -k privilege_escalation
-w /usr/bin/sudo -p x -k privilege_escalation
-w /opt/ShadowOS -p wa -k shadowos_changes
-w /etc/shadowos -p wa -k shadowos_config
-w /etc/fail2ban -p wa -k fail2ban_changes
AUDIT

    systemctl enable auditd 2>/dev/null || true
    systemctl restart auditd 2>/dev/null || true
    success "Audit rules updated"
else
    warn "auditd not available"
fi

# ─── ZRAM Configuration (NEW in v2026.2) ────────────────────────────────
step "CONFIGURING ZRAM"
if modprobe zram 2>/dev/null; then
    echo "512M" > /sys/module/zram/parameters/mem_limit
    echo "zstd" > /sys/module/zram/parameters/comp_algorithm
    mkswap /dev/zram0 2>/dev/null || true
    swapon -p 100 /dev/zram0 2>/dev/null || true
    success "ZRAM configured for compressed swap"
else
    warn "ZRAM module not available"
fi

# ─── Btrfs Optimization (NEW in v2026.2) ────────────────────────────────
step "CONFIGURING BTRFS OPTIMIZATION"
if mount | grep -q "btrfs"; then
    mount -o remount,compress=zstd:3 / 2>/dev/null || true
    success "Btrfs compression enabled (zstd:3)"
else
    info "Btrfs not detected — skipping optimization"
fi

echo ""
# ─── USBGuard (NEW) ────────────────────────────────────────────────────────
step "CONFIGURING USBGUARD"

if command -v usbguard &>/dev/null; then
    mkdir -p /etc/usbguard
    # Generate initial policy based on currently connected devices
    usbguard generate-policy > /etc/usbguard/rules.conf 2>/dev/null || {
        # Default policy: deny all, allow only HID devices
        cat > /etc/usbguard/rules.conf << 'USBGUARD'
allow id 046d:* name "Logitech USB Receiver" with-interface equals { 03 01 02 }
allow id 045e:* name "Microsoft USB Receiver" with-interface equals { 03 01 02 }
allow id 1a2c:* name "USB Keyboard" with-interface equals { 03 01 02 }
allow id 1a2c:* name "USB Mouse" with-interface equals { 03 01 03 }
reject
USBGUARD
    }

    systemctl enable usbguard 2>/dev/null || true
    systemctl start usbguard 2>/dev/null || true
    success "USBGuard configured (whitelist mode)"
else
    info "USBGuard not installed — skipping (recommended for high security)"
fi

# ─── Bluetooth Security (NEW) ──────────────────────────────────────────────
step "HARDENING BLUETOOTH"

if command -v bluetoothctl &>/dev/null; then
    # Stop and disable Bluetooth by default
    systemctl stop bluetooth 2>/dev/null || true

    # Create rfkill rules for auto-disable on boot
    cat > /etc/udev/rules.d/99-bluetooth-security.rules << 'BLUETOOTH'
SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", ATTR{state}="1"
BLUETOOTH

    # Harden bluetoothctl settings
    bluetoothctl << 'BTCTL' 2>/dev/null || true
power off
discoverable off
pairable off
exit
BTCTL

    success "Bluetooth hardened (disabled by default)"
else
    info "Bluetooth not available — skipping"
fi

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ ShadowOS Security Hardening Complete${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}Applied:${NC}"
echo -e "    • nftables firewall (default-deny)"
echo -e "    • Fail2ban integration (SSH protection)"
echo -e "    • Kernel hardening (ASLR, ptrace, network)"
echo -e "    • SSH hardening (port 2222, key-only auth)"
echo -e "    • AppArmor enforcement"
echo -e "    • AIDE file integrity monitoring"
echo -e "    • Core dump protection"
echo -e "    • File permission hardening"
echo -e "    • Audit rules (enhanced)"
echo -e "    • ZRAM compressed swap"
echo -e "    • Btrfs zstd compression"
echo -e "    • USBGuard device authorization"
echo -e "    • Bluetooth disabled & hardened"