#!/bin/bash
# ============================================================================
# ShadowOS Network Monitor & Analyzer
# Real-time network traffic monitoring with cyberpunk display
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'
YELLOW='\033[1;33m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

INTERFACE="${1:-$(ip route | grep default | awk '{print $5}' | head -1)}"
REFRESH=2

get_connections() {
    ss -tnp 2>/dev/null | tail -n +2 | head -20
}

get_traffic() {
    if [ -f "/sys/class/net/$INTERFACE/statistics/rx_bytes" ]; then
        local rx=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)
        local tx=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
        echo "$rx $tx"
    else
        echo "0 0"
    fi
}

get_bandwidth() {
    local stats=$(get_traffic)
    local rx=$(echo "$stats" | awk '{print $1}')
    local tx=$(echo "$stats" | awk '{print $2}')
    echo "$rx $tx"
}

draw_bar() {
    local value=$1
    local max=$2
    local width=30
    local filled=$((value * width / max 2>/dev/null || echo 0))
    [ "$filled" -gt "$width" ] && filled=$width
    printf "${GREEN}["
    printf "%0.s█" $(seq 1 $filled 2>/dev/null || echo 1)
    printf "%0.s░" $(seq 1 $((width - filled)) 2>/dev/null || echo 1)
    printf "${NC}]"
}

format_bytes() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc 2>/dev/null || echo "0") GB"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc 2>/dev/null || echo "0") MB"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc 2>/dev/null || echo "0") KB"
    else
        echo "${bytes} B"
    fi
}

render() {
    local prev_stats=$(cat /tmp/shadowos_net_prev 2>/dev/null || echo "0 0")
    local prev_rx=$(echo "$prev_stats" | awk '{print $1}')
    local prev_tx=$(echo "$prev_stats" | awk '{print $2}')
    
    local stats=$(get_traffic)
    local rx=$(echo "$stats" | awk '{print $1}')
    local tx=$(echo "$stats" | awk '{print $2}')
    
    local rx_rate=$((rx - prev_rx))
    local tx_rate=$((tx - prev_tx))
    
    echo "$stats" > /tmp/shadowos_net_prev
    
    clear
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║  🌐 ShadowOS Network Monitor                     ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BOLD}Interface:${NC} $INTERFACE"
    echo ""
    
    # Bandwidth
    echo -e "  ${BOLD}┌─ BANDWIDTH ───────────────────────────────────┐${NC}"
    echo -e "  │  ${GREEN}↓ RX:${NC} $(format_bytes $rx_rate)/s"
    echo -e "  │  ${MAGENTA}↑ TX:${NC} $(format_bytes $tx_rate)/s"
    echo -ne "  │  "
    draw_bar $((rx_rate / 1024 + 1)) 10000
    echo ""
    echo -e "  └──────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Tor status
    echo -e "  ${BOLD}┌─ PRIVACY STATUS ─────────────────────────────┐${NC}"
    if pgrep -x tor > /dev/null; then
        echo -e "  │  ${GREEN}Tor:${NC} ACTIVE (SOCKS: 127.0.0.1:9050)"
    else
        echo -e "  │  ${RED}Tor:${NC} INACTIVE"
    fi
    if sudo wg show 2>/dev/null | grep -q interface; then
        echo -e "  │  ${GREEN}VPN:${NC} ACTIVE (WireGuard)"
    else
        echo -e "  │  ${YELLOW}VPN:${NC} INACTIVE"
    fi
    echo -e "  │  ${CYAN}DNS:${NC} $(grep nameserver /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')"
    echo -e "  └──────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Active connections
    echo -e "  ${BOLD}┌─ ACTIVE CONNECTIONS ─────────────────────────┐${NC}"
    get_connections | while read line; do
        echo -e "  │  $line"
    done
    echo -e "  └──────────────────────────────────────────────┘${NC}"
    echo ""
    
    # DNS requests (if available)
    if [ -f /var/log/syslog ]; then
        echo -e "  ${BOLD}┌─ RECENT DNS QUERIES ─────────────────────────┐${NC}"
        grep -i "dns" /var/log/syslog 2>/dev/null | tail -5 | while read line; do
            echo -e "  │  ${CYAN}$line${NC}"
        done
        echo -e "  └──────────────────────────────────────────────┘${NC}"
    fi
    
    echo ""
    echo -e "  ${YELLOW}Press Ctrl+C to exit | Refresh: ${REFRESH}s${NC}"
}

# Main loop
trap cleanup EXIT INT TERM
cleanup() { echo -e "\n${GREEN}Network monitor stopped${NC}"; rm -f /tmp/shadowos_net_prev; }

while true; do
    render
    sleep "$REFRESH"
done