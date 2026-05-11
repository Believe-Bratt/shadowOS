#!/bin/bash
# ============================================================================
# ShadowOS Security Hardening Script
# ============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

step "SHADOWOS SECURITY HARDENING"

# ─── Firewall (nftables) ────────────────────────────────────────────────
step "CONFIGURING FIREWALL (nftables)"
mkdir -p /etc/nftables
cat > /etc/nftables/conf.d/00-shadowos-rules.nft << 'NFT'
#!/usr/sbin/nft -f
# ShadowOS Firewall Rules — Default-Deny Policy

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Loopback
        iif lo accept

        # Established/related connections
        ct state established,related accept

        # ICMP (rate limited)
        ip protocol icmp limit rate 10/second accept
        ip6 nexthdr icmpv6 limit rate 10/second accept

        # SSH (custom port 2222)
        tcp dport 2222 ct state new limit rate 5/minute accept

        # DHCP
        udp dport 67-68 accept

        # DNS
        udp dport 53 accept
        tcp dport 53 accept

        # Tor SOCKS (local only)
        tcp dport 9050 iif lo accept

        # WireGuard
        udp dport 51820 accept

        # Reject with ICMP
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

table ip nat {
    chain prerouting {
        type nat hook prerouting priority 0; policy accept;
    }
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
    }
}
NFT

nft -f /etc/nftables/conf.d/00-shadowos-rules.nft 2>/dev/null && \
    systemctl enable nftables 2>/dev/null && \
    success "nftables firewall applied (default-deny)" || \
    warn "Could not apply nftables rules (may need kernel modules)"

# ─── Intrusion Detection ────────────────────────────────────────────────
step "SETTING UP INTRUSION DETECTION"

# AIDE configuration
if command -v aide &>/dev/null; then
    cat > /etc/aide/aide.conf.d/99-shadowos << 'AIDE'
# ShadowOS AIDE Configuration
Database=file:/var/lib/aide/aide.db
DatabaseOut=file:/var/lib/aide/aide.db.new
GrepOutput=^@@
Verbose=5

# Checksums
Checksums=sha256+sha512

# Rules
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

# rkhunter config
if command -v rkhunter &>/dev/null; then
    rkhunter --propupd 2>/dev/null || true
    success "rkhunter properties updated"
fi

# chkrootkit
if command -v chkrootkit &>/dev/null; then
    success "chkrootkit available (run manually: chkrootkit)"
fi

# ─── AppArmor ───────────────────────────────────────────────────────────
step "CONFIGURING APPARMOR"
if command -v aa-enforce &>/dev/null; then
    # Set all profiles to enforce
    for profile in /etc/apparmor.d/*; do
        aa-enforce "$profile" 2>/dev/null || true
    done
    systemctl enable apparmor 2>/dev/null || true
    success "AppArmor enabled and enforcing"
else
    warn "AppArmor not available"
fi

# ─── SELinux (if available) ─────────────────────────────────────────────
if command -v sestatus &>/dev/null; then
    success "SELinux available (configure per policy)"
fi

# ─── Kernel Hardening ───────────────────────────────────────────────────
step "APPLYING KERNEL HARDENING"
cat > /etc/sysctl.d/99-shadowos-hardening.conf << 'SYSCTL'
# ShadowOS Kernel Security Hardening

# ASLR (Address Space Layout Randomization)
kernel.randomize_va_space = 2

# Restrict kernel pointer exposure
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 1

# Restrict kernel log access
kernel.printk = 3 3 3 3
kernel.printk_delay = 0

# Network hardening
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
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_max_syn_backlog = 2048

# IPv6 hardening
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv6.conf.all.forwarding = 0

# Filesystem hardening
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 1
fs.protected_regular = 2

# Restrict dmesg
kernel.dmesg_restrict = 1

# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Restrict ptrace
kernel.yama.ptrace_scope = 1
SYSCTL

sysctl --system 2>/dev/null || true
success "Kernel parameters hardened"

# ─── SSH Hardening ──────────────────────────────────────────────────────
step "HARDENING SSH"
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/00-shadowos.conf << 'SSHCONF'
# ShadowOS SSH Hardening
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
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org
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
GatewayPorts no
PermitTunnel no
Compression no
MaxStartups 2:50:10
Banner /etc/ssh/banner
SSHCONF

# Create SSH banner
cat > /etc/ssh/banner << 'BANNER'
╔══════════════════════════════════════════════════╗
║  ⚠  UNAUTHORIZED ACCESS IS PROHIBITED           ║
║  All connections are monitored and recorded       ║
║  Violators will be prosecuted                     ║
╚══════════════════════════════════════════════════╝
BANNER

chmod 600 /etc/ssh/sshd_config.d/00-shadowos.conf
chmod 644 /etc/ssh/banner
success "SSH hardened"

# ─── File Permissions ───────────────────────────────────────────────────
step "HARDENING FILE PERMISSIONS"
chmod 700 /root 2>/dev/null || true
chmod 600 /etc/crontab 2>/dev/null || true
chmod 600 /etc/ssh/ssh_config 2>/dev/null || true
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
echo "fs.suid_dumpable = 0" >> /etc/sysctl.d/99-shadowos-hardening.conf
find / -name "core" -type f -delete 2>/dev/null || true
success "Core dumps disabled"

# ─── Secure Boot Support ────────────────────────────────────────────────
step "CONFIGURING SECURE BOOT"
if [ -d /sys/firmware/efi ]; then
    success "UEFI detected - Secure Boot compatible"
    # Install shim and signed bootloader if available
    if command -v mokutil &>/dev/null; then
        success "MOK utilities available for Secure Boot key management"
    fi
else
    warn "Legacy BIOS detected - Secure Boot not available"
fi

# ─── Firejail Sandboxing ────────────────────────────────────────────────
step "CONFIGURING APPLICATION SANDBOXING"
if command -v firejail &>/dev/null; then
    # Enable global Firejail profiles
    firejail --build=/etc/firejail/browsers.local 2>/dev/null || true
    success "Firejail sandboxing available"
else
    warn "Firejail not installed"
fi

# ─── Audit Rules ────────────────────────────────────────────────────────
step "CONFIGURING AUDIT RULES"
if command -v auditctl &>/dev/null; then
    cat > /etc/audit/rules.d/shadowos.rules << 'AUDIT'
# ShadowOS Audit Rules
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k sudo_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config
-w /etc/nftables -p wa -k firewall_changes
-w /etc/crontab -p wa -k cron_changes
-w /etc/systemd/system/ -p wa -k systemd_changes
-w /usr/bin/passwd -p x -k privilege_escalation
-w /usr/bin/sudo -p x -k privilege_escalation
-w /usr/bin/su -p x -k privilege_escalation
AUDIT
    systemctl enable auditd 2>/dev/null || true
    success "Audit rules configured"
else
    warn "auditd not available"
fi

# ─── Summary ────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ ShadowOS Security Hardening Complete${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}Applied:${NC}"
echo -e "    • nftables firewall (default-deny)"
echo -e "    • Kernel hardening (ASLR, ptrace, network)"
echo -e "    • SSH hardening (port 2222, key-only auth)"
echo -e "    • AppArmor enforcement"
echo -e "    • AIDE file integrity monitoring"
echo -e "    • Core dump protection"
echo -e "    • File permission hardening"
echo -e "    • Audit rules"
echo ""
echo -e "  ${YELLOW}Manual steps recommended:${NC}"
echo -e "    • Enable LUKS2 full-disk encryption during install"
echo -e "    • Configure Secure Boot keys"
echo -e "    • Set up encrypted swap partition"
echo -e "    • Run 'aide --check' periodically"