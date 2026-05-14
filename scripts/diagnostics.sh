#!/usr/bin/env bash
# ============================================================================
# ShadowOS System Diagnostics & Health Check
# Comprehensive system health assessment tool
# ============================================================================

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
BOLD='\033[1m'

LOG_FILE="/var/log/shadowos-diagnostics.log"
REPORT_FILE="/tmp/shadowos-diagnostics-$(date +%Y%m%d-%H%M%S).txt"

pass=0; warn=0; fail=0

log() { echo -e "$1" | tee -a "$REPORT_FILE"; }
step() { log "\n${CYAN}═══ $1 ═══${NC}\n"; }
ok()   { log "  ${GREEN}✓${NC} $1"; ((pass++)); }
warn() { log "  ${YELLOW}⚠${NC} $1"; ((warn++)); }
fail() { log "  ${RED}✗${NC} $1"; ((fail++)); }
info() { log "  ${BLUE}ℹ${NC} $1"; }

show_help() {
    echo -e "${BOLD}ShadowOS System Diagnostics${NC}"
    echo ""
    echo "Usage: shadowos-diagnostics [options]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --quick     Quick health check (essential only)"
    echo "  --full      Full system diagnostics (default)"
    echo "  --security  Security-focused diagnostics"
    echo "  --network   Network diagnostics"
    echo "  --ai        AI engine diagnostics"
    echo "  --report    Generate report file"
    echo "  --json      Output as JSON"
}

# ─── System Information ────────────────────────────────────────────────────
check_system_info() {
    step "SYSTEM INFORMATION"
    log "  Hostname: $(hostname)"
    log "  Kernel: $(uname -r)"
    log "  OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '"')"
    log "  Uptime: $(uptime -p 2>/dev/null || uptime)"
    log "  Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"

    # CPU Info
    local cpu_model=$(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs)
    local cpu_cores=$(nproc 2>/dev/null)
    log "  CPU: $cpu_model ($cpu_cores cores)"

    # Memory
    local mem_info=$(free -h | awk '/^Mem:/{print $3"/"$2" ("$3/$2*100"%)"}')
    log "  Memory: $mem_info"

    # Disk
    local disk_info=$(df -h / | awk 'NR==2{print $3"/"$2" ("$5" used)"}')
    log "  Disk: $disk_info"

    # GPU
    local gpu=$(lspci 2>/dev/null | grep -i vga | cut -d: -f3- | xargs || echo "Unknown")
    log "  GPU: $gpu"

    # Check if running in VM
    if systemd-detect-virt &>/dev/null; then
        log "  Virtualization: $(systemd-detect-virt)"
    fi

    # ShadowOS version
    if [ -f /etc/shadowos/version ]; then
        log "  ShadowOS Version: $(cat /etc/shadowos/version) ($(cat /etc/shadowos/codename 2>/dev/null || echo 'unknown'))"
    fi
}

# ─── Security Checks ──────────────────────────────────────────────────────
check_security() {
    step "SECURITY STATUS"

    # Firewall
    if systemctl is-active nftables &>/dev/null; then
        ok "nftables firewall: ACTIVE"
    elif systemctl is-active ufw &>/dev/null; then
        ok "UFW firewall: ACTIVE"
    elif iptables -L -n 2>/dev/null | grep -q "Chain INPUT"; then
        warn "iptables rules present but no service active"
    else
        fail "No firewall detected"
    fi

    # SSH
    if [ -f /etc/ssh/sshd_config.d/00-shadowos.conf ] || [ -f /etc/ssh/sshd_config.d/shadowos.conf ]; then
        ok "SSH hardening config: PRESENT"
    else
        warn "SSH hardening config: MISSING"
    fi

    # SSH port
    local ssh_port=$(grep -r "Port" /etc/ssh/sshd_config.d/*.conf /etc/ssh/sshd_config 2>/dev/null | grep -v "^#" | tail -1 | awk '{print $2}')
    if [ "$ssh_port" = "2222" ]; then
        ok "SSH port: $ssh_port (non-standard)"
    elif [ -n "$ssh_port" ]; then
        warn "SSH port: $ssh_port (consider changing to 2222)"
    else
        fail "SSH port not configured"
    fi

    # Root login
    if grep -q "PermitRootLogin no" /etc/ssh/sshd_config* 2>/dev/null; then
        ok "Root login: DISABLED"
    else
        warn "Root login: not explicitly disabled"
    fi

    # Password auth
    if grep -q "PasswordAuthentication no" /etc/ssh/sshd_config* 2>/dev/null; then
        ok "Password auth: DISABLED"
    else
        warn "Password auth: may be enabled"
    fi

    # AppArmor
    if systemctl is-active apparmor &>/dev/null; then
        ok "AppArmor: ACTIVE"
    else
        warn "AppArmor: not active"
    fi

    # Fail2ban
    if systemctl is-active fail2ban &>/dev/null; then
        ok "Fail2ban: ACTIVE"
    else
        info "Fail2ban: not installed (recommended)"
    fi

    # Audit daemon
    if systemctl is-active auditd &>/dev/null; then
        ok "auditd: ACTIVE"
    else
        info "auditd: not active (recommended for compliance)"
    fi

    # Tor
    if systemctl is-active tor &>/dev/null; then
        ok "Tor: ACTIVE"
    else
        info "Tor: inactive"
    fi

    # Kernel hardening
    if [ "$(cat /proc/sys/kernel/randomize_va_space 2>/dev/null)" = "2" ]; then
        ok "ASLR: enabled (full)"
    else
        warn "ASLR: not fully enabled"
    fi

    if [ "$(cat /proc/sys/kernel/kptr_restrict 2>/dev/null)" = "2" ]; then
        ok "Kernel pointer restriction: enabled"
    else
        warn "Kernel pointer restriction: not enabled"
    fi

    # Check for known CVEs (basic)
    if command -v vulscan &>/dev/null; then
        ok "Vulscan: installed"
    else
        info "Vulscan: not installed (optional vulnerability scanner)"
    fi
}

# ─── Network Diagnostics ──────────────────────────────────────────────────
check_network() {
    step "NETWORK STATUS"

    # Interfaces
    log "  Interfaces:"
    ip -o link show 2>/dev/null | awk -F': ' '{print "    "$2": "$9}' | tee -a "$REPORT_FILE"

    # IP addresses
    log "  IP Addresses:"
    ip -o addr show 2>/dev/null | awk '{print "    "$2": "$4}' | tee -a "$REPORT_FILE"

    # Default gateway
    local gw=$(ip route show default 2>/dev/null | awk '{print $3}')
    log "  Gateway: $gw"

    # DNS
    local dns=$(resolvectl status 2>/dev/null | grep 'DNS Servers' | head -1 || cat /etc/resolv.conf 2>/dev/null | grep nameserver | head -2)
    log "  DNS: $dns"

    # DNS leak check
    local public_ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "unreachable")
    log "  Public IP: $public_ip"

    # Tor check
    local tor_ip=$(curl -s --max-time 10 --socks5-hostname localhost:9050 ifconfig.me 2>/dev/null || echo "N/A")
    if [ "$tor_ip" != "N/A" ] && [ "$tor_ip" != "$public_ip" ]; then
        ok "Tor routing: ACTIVE ($tor_ip)"
    fi

    # Open ports
    if command -v ss &>/dev/null; then
        log "  Listening ports:"
        ss -tlnp 2>/dev/null | awk 'NR>1{print "    "$4" ("$7")"}' | tee -a "$REPORT_FILE"
    fi

    # Connectivity test
    if curl -s --max-time 5 https://www.google.com &>/dev/null; then
        ok "Internet connectivity: WORKING"
    else
        fail "Internet connectivity: FAILED"
    fi

    # DNS over HTTPS
    if grep -q "dns_over_https" /etc/shadowos/config.sh 2>/dev/null; then
        ok "DNS-over-HTTPS: configured"
    fi
}

# ─── AI Engine Diagnostics ────────────────────────────────────────────────
check_ai() {
    step "AI ENGINE STATUS"

    if command -v ollama &>/dev/null; then
        ok "Ollama: installed ($(ollama --version 2>/dev/null || echo 'unknown'))"
    else
        fail "Ollama: not installed"
        return
    fi

    if curl -s http://localhost:11434/api/tags &>/dev/null; then
        ok "Ollama API: running"

        # Model count and sizes
        local model_count=$(curl -s http://localhost:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(len(data.get('models', [])))
" 2>/dev/null || echo "0")

        local total_size=$(curl -s http://localhost:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
total = sum(m.get('size', 0) for m in data.get('models', []))
print(f'{total / 1024 / 1024:.1f} MB')
" 2>/dev/null || echo "0 MB")

        log "  Models installed: $model_count ($total_size)"

        # List models
        log "  Model list:"
        curl -s http://localhost:11434/api/tags | python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('models', []):
    size_mb = m.get('size', 0) / 1024 / 1024
    print(f'    - {m[\"name\"]} ({size_mb:.1f} MB)')
" 2>/dev/null | tee -a "$REPORT_FILE"

        # Test inference
        local start=$(date +%s%N)
        curl -s http://localhost:11434/api/generate \
            -H "Content-Type: application/json" \
            -d '{"model":"llama3.2:8b","prompt":"Hello","stream":false}' \
            > /dev/null 2>&1
        local elapsed=$(( ( $(date +%s%N) - start) / 1000000 ))
        log "  Inference test: ${elapsed}ms response time"
    else
        fail "Ollama API: not responding"
    fi
}

# ─── Hardware Diagnostics ─────────────────────────────────────────────────
check_hardware() {
    step "HARDWARE STATUS"

    # Temperature
    if command -v sensors &>/dev/null; then
        log "  CPU Temperature:"
        sensors 2>/dev/null | grep -E "Core|Package|Tdie" | head -4 | tee -a "$REPORT_FILE"
    elif [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        local temp=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
        log "  CPU Temperature: ${temp}°C"
    fi

    # GPU temperature
    if command -v nvidia-smi &>/dev/null; then
        log "  GPU:"
        nvidia-smi --query-gpu=name,temperature.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null | tee -a "$REPORT_FILE"
    elif lspci 2>/dev/null | grep -qi "vga\|3d\|display"; then
        local gpu_info=$(lspci 2>/dev/null | grep -i vga | cut -d: -f3- | xargs)
        log "  GPU: $gpu_info"
    fi

    # Memory test
    local mem_available=$(free -m | awk '/^Mem:/{print $7}')
    if [ "$mem_available" -lt 1024 ]; then
        warn "Low memory: ${mem_available}MB available"
    else
        ok "Memory: ${mem_available}MB available"
    fi

    # Disk health (SMART)
    if command -v smartctl &>/dev/null; then
        local disk=$(lsblk -d -o NAME | grep -v NAME | head -1)
        local health=$(smartctl -H /dev/$disk 2>/dev/null | grep "SMART overall-health" || echo "Unknown")
        log "  Disk Health: $health"
    fi

    # Battery
    if [ -d /sys/class/power_supply/BAT0 ]; then
        local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        local capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        local temp=$(cat /sys/class/power_supply/BAT0/temp 2>/dev/null)
        temp=$((temp / 10))
        log "  Battery: ${capacity}% - $status (${temp}°C)"
    fi
}

# ─── Service Status ───────────────────────────────────────────────────────
check_services() {
    step "SHADOWOS SERVICES"

    local services=(
        "shadowos-ai:AI Engine"
        "shadowos-monitor:System Monitor"
        "shadowos-privacy:Privacy Services"
        "shadowos-security:Security Monitor"
        "shadowos-update:Auto Updates"
        "nftables:Firewall"
        "ssh:SSH Server"
        "tor:Tor"
    )

    for svc_info in "${services[@]}"; do
        local svc="${svc_info%%:*}"
        local desc="${svc_info#*:}"
        if systemctl is-active "$svc" &>/dev/null; then
            ok "$desc: RUNNING"
        elif systemctl is-enabled "$svc" &>/dev/null; then
            warn "$desc: enabled but not running"
        else
            info "$desc: not active"
        fi
    done
}

# ─── Performance Metrics ──────────────────────────────────────────────────
check_performance() {
    step "PERFORMANCE"

    # Load average
    local load=$(cat /proc/loadavg | awk '{printf "%.2f", $1}')
    local cores=$(nproc)
    local load_pct=$(echo "scale=1; $load * 100 / $cores" | bc 2>/dev/null || echo "N/A")
    log "  Load Average: $load ($load_pct% of $cores cores)"

    # Memory usage
    local mem_usage=$(free | awk '/^Mem:/{printf "%.1f", $3/$2 * 100}')
    log "  Memory Usage: ${mem_usage}%"

    # Swap usage
    local swap_usage=$(free | awk '/^Swap:/{if($2>0) printf "%.1f", $3/$2 * 100; else print "N/A (no swap)"}')
    log "  Swap Usage: ${swap_usage}%"

    # Disk I/O (requires iostat)
    if command -v iostat &>/dev/null; then
        local disk_io=$(iostat -d 1 2 2>/dev/null | tail -3 | awk '{print "    "$1": "$3" r/s, "$4" w/s"}' | head -2)
        log "  Disk I/O:"
        echo "$disk_io" | tee -a "$REPORT_FILE"
    fi

    # Top processes
    log "  Top 5 CPU processes:"
    ps aux --sort=-%cpu | head -6 | awk 'NR>1{printf "    %-20s %s%%\n", $11, $3}' | tee -a "$REPORT_FILE"

    # ZRAM status
    if [ -d /sys/block/zram0 ]; then
        local zram_used=$(cat /sys/block/zram0/mm_stat 2>/dev/null | awk '{print $2/1024/1024" MB"}')
        local zram_size=$(cat /sys/block/zram0/disksize 2>/dev/null | awk '{print $1/1024/1024" MB"}')
        log "  ZRAM: ${zram_used} used / ${zram_size} total"
    fi
}

# ─── Quick Check Mode ─────────────────────────────────────────────────────
check_quick() {
    step "QUICK HEALTH CHECK"
    check_system_info
    check_security
    check_services
    check_performance
}

# ─── Security-Focused Check ───────────────────────────────────────────────
check_security_focused() {
    step "SECURITY DEEP DIVE"
    check_security
    check_network

    # Additional security checks
    step "ADDITIONAL SECURITY CHECKS"

    # World-writable files
    local world_writable=$(find / -xdev -type f -perm -0002 ! -path "/proc/*" 2>/dev/null | wc -l)
    if [ "$world_writable" -eq 0 ]; then
        ok "No world-writable files found"
    else
        warn "$world_writable world-writable files found"
    fi

    # SUID binaries
    local suid_count=$(find / -xdev -perm -4000 ! -path "/proc/*" 2>/dev/null | wc -l)
    log "  SUID binaries: $suid_count"

    # Open network connections
    if command -v ss &>/dev/null; then
        local connections=$(ss -tuln 2>/dev/null | tail -n +2 | wc -l)
        log "  Listening connections: $connections"
    fi

    # Check for known malware indicators
    local tmp_exec=$(find /tmp /var/tmp -type f -executable 2>/dev/null | wc -l)
    if [ "$tmp_exec" -eq 0 ]; then
        ok "No executables in temp directories"
    else
        warn "$tmp_exec executables found in temp directories"
    fi

    # Log analysis
    if [ -f /var/log/auth.log ]; then
        local failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
        log "  Failed login attempts (auth.log): $failed_logins"
    fi
}

# ─── JSON Output ──────────────────────────────────────────────────────────
check_json() {
    local hostname=$(hostname)
    local kernel=$(uname -r)
    local cpu_cores=$(nproc)
    local mem_total=$(free -m | awk '/^Mem:/{print $2}')
    local mem_used=$(free -m | awk '/^Mem:/{print $3}')
    local disk_usage=$(df / | awk 'NR==2{print $5}' | tr -d '%')
    local load=$(cat /proc/loadavg | awk '{print $1}')
    local firewall="inactive"
    systemctl is-active nftables &>/dev/null && firewall="active"
    local ssh_hardening="no"
    grep -q "PermitRootLogin no" /etc/ssh/sshd_config* 2>/dev/null && ssh_hardening="yes"
    local ollama="inactive"
    curl -s http://localhost:11434/api/tags &>/dev/null && ollama="active"

    cat << JSONEOF
{
  "timestamp": "$(date -Iseconds)",
  "hostname": "$hostname",
  "kernel": "$kernel",
  "cpu_cores": $cpu_cores,
  "memory": {
    "total_mb": $mem_total,
    "used_mb": $mem_used,
    "usage_percent": $((mem_used * 100 / mem_total))
  },
  "disk": {
    "usage_percent": $disk_usage
  },
  "load_average": "$load",
  "security": {
    "firewall": "$firewall",
    "ssh_hardening": "$ssh_hardening"
  },
  "ai_engine": {
    "ollama": "$ollama"
  },
  "shadowos_version": "$(cat /etc/shadowos/version 2>/dev/null || echo 'unknown')"
}
JSONEOF
}

# ─── Main ──────────────────────────────────────────────────────────────────
case "${1:---full}" in
    --quick)
        check_quick
        ;;
    --full)
        check_system_info
        check_security
        check_network
        check_ai
        check_hardware
        check_services
        check_performance
        ;;
    --security)
        check_security_focused
        ;;
    --network)
        check_network
        ;;
    --ai)
        check_ai
        ;;
    --json)
        check_json
        ;;
    --report)
        check_system_info > "$REPORT_FILE"
        check_security >> "$REPORT_FILE"
        check_network >> "$REPORT_FILE"
        check_ai >> "$REPORT_FILE"
        check_hardware >> "$REPORT_FILE"
        check_services >> "$REPORT_FILE"
        check_performance >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        echo "══════════════════════════════════════════════" >> "$REPORT_FILE"
        echo "SUMMARY: $pass passed, $warn warnings, $fail failed" >> "$REPORT_FILE"
        echo "Report saved to: $REPORT_FILE"
        echo "Report saved to: $REPORT_FILE"
        ;;
    --json)
        check_json
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac

# Summary
echo ""
echo -e "${BOLD}══════════════════════════════════════════════${NC}"
echo -e "${BOLD}  DIAGNOSTICS SUMMARY${NC}"
echo -e "${BOLD}══════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed:${NC} $pass"
echo -e "  ${YELLOW}Warnings:${NC} $warn"
echo -e "  ${RED}Failed:${NC} $fail"
echo -e "${BOLD}══════════════════════════════════════════════${NC}"