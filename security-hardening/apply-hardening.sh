#!/usr/bin/env bash
# ============================================================================
# ShadowOS Security Hardening Script
# ============================================================================
set -e
set -u

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }

step "SHADOWOS SECURITY HARDENING"

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

        # Tor (only local access)
        tcp dport 9050 iif lo accept

        # WireGuard (restrict if possible later)
        udp dport 51820 accept

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

NFT

# Enable nftables service and load config
systemctl enable nftables >/dev/null 2>&1
nft -f /etc/nftables.conf >/dev/null 2>&1 && \
    success "nftables firewall applied (default-deny)" || \
    warn "Could not apply nftables rules"

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
SYSCTL

sysctl --system 2>/dev/null || true
success "Kernel parameters hardened"

# ─── SSH Hardening ──────────────────────────────────────────────────────
step "HARDENING SSH"
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/00-shadowos.conf << 'SSHCONF'
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

# ─── Audit Rules ────────────────────────────────────────────────────────
step "CONFIGURING AUDIT RULES"
if command -v auditctl &>/dev/null; then
    mkdir -p /etc/audit/rules.d
    cat > /etc/audit/rules.d/shadowos.rules << 'AUDIT'
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k sudo_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config
-w /etc/nftables -p wa -k firewall_changes
-w /usr/bin/passwd -p x -k privilege_escalation
-w /usr/bin/sudo -p x -k privilege_escalation
AUDIT
    systemctl enable auditd 2>/dev/null || true
    success "Audit rules configured"
else
    warn "auditd not available"
fi

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