#!/bin/bash
# ============================================================================
# ShadowOS Network Privacy Manager
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'
YELLOW='\033[1;33m'; NC='\033[0m'

TOR_PORT=9050
TOR_DNS_PORT=5353
TRANS_PORT=9040
IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

start_tor() {
    echo -e "${CYAN}Starting Tor privacy services...${NC}"
    systemctl start tor 2>/dev/null || service tor start 2>/dev/null || tor &
    sleep 2
    if pgrep -x tor > /dev/null; then
        echo -e "${GREEN}✓ Tor running on port $TOR_PORT${NC}"
    else
        echo -e "${RED}✗ Failed to start Tor${NC}"
        return 1
    fi
}

stop_tor() {
    echo -e "${CYAN}Stopping Tor...${NC}"
    systemctl stop tor 2>/dev/null || service tor stop 2>/dev/null || pkill tor
    echo -e "${GREEN}✓ Tor stopped${NC}"
}

setup_tor_dns() {
    echo -e "${CYAN}Configuring DNS-over-Tor...${NC}"
    # Configure resolvconf or systemd-resolved for Tor DNS
    if [ -d /etc/tor ]; then
        grep -q "^DNSPort" /etc/tor/torrc || echo "DNSPort $TOR_DNS_PORT" >> /etc/tor/torrc
        grep -q "^AutomapHostsOnResolve" /etc/tor/torrc || echo "AutomapHostsOnResolve 1" >> /etc/tor/torrc
        echo -e "${GREEN}✓ Tor DNS configured on port $TOR_DNS_PORT${NC}"
    fi
}

setup_transparent_proxy() {
    echo -e "${CYAN}Setting up transparent Tor proxy...${NC}"
    # Create iptables rules for transparent proxying
    if command -v iptables &>/dev/null; then
        iptables -t nat -A OUTPUT -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null
        iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $TOR_DNS_PORT 2>/dev/null
        echo -e "${GREEN}✓ Transparent proxy rules applied${NC}"
    fi
}

setup_killswitch() {
    echo -e "${CYAN}Configuring network kill-switch...${NC}"
    # Block all non-Tor traffic when Tor is active
    cat > /tmp/killswitch.sh << 'KILLSWITCH'
#!/bin/bash
# Network kill-switch — blocks traffic outside Tor
TOR_UID=$(id -u debian-tor 2>/dev/null || id -u tor 2>/dev/null || echo "101")
iptables -F OUTPUT 2>/dev/null
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -s 127.0.0.0/8 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 9050 -m owner --uid-owner $TOR_UID -j ACCEPT
iptables -A OUTPUT -p udp --dport 5353 -m owner --uid-owner $TOR_UID -j ACCEPT
iptables -A OUTPUT -j REJECT
KILLSWITCH
    chmod +x /tmp/killswitch.sh
    echo -e "${GREEN}✓ Kill-switch script created at /tmp/killswitch.sh${NC}"
}

setup_mac_randomize() {
    echo -e "${CYAN}Configuring MAC address randomization...${NC}"
    if [ -n "$IFACE" ]; then
        cat > /etc/network/if-pre-up.d/mac-randomize << MACRAND
#!/bin/bash
IFACE="$IFACE"
if [ -f /sys/class/net/\$IFACE/address ]; then
    NEW_MAC=\$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.\$//')
    ip link set dev \$IFACE down
    ip link set dev \$IFACE address \$NEW_MAC
    ip link set dev \$IFACE up
fi
MACRAND
        chmod +x /etc/network/if-pre-up.d/mac-randomize
        echo -e "${GREEN}✓ MAC randomization configured for $IFACE${NC}"
    fi
}

setup_vpn_wireguard() {
    echo -e "${CYAN}Setting up WireGuard VPN template...${NC}"
    mkdir -p /etc/wireguard
    cat > /etc/wireguard/wg0.conf << WGCONF
[Interface]
PrivateKey = # INSERT_PRIVATE_KEY_HERE
Address = 10.0.0.2/32
DNS = 1.1.1.1,1.0.0.1

[Peer]
PublicKey = # INSERT_SERVER_PUBLIC_KEY_HERE
Endpoint = # INSERT_SERVER_ENDPOINT_HERE
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
WGCONF
    chmod 600 /etc/wireguard/wg0.conf
    echo -e "${GREEN}✓ WireGuard config template created${NC}"
    echo -e "${YELLOW}  Edit /etc/wireguard/wg0.conf with your VPN details${NC}"
}

check_dns_leaks() {
    echo -e "${CYAN}Checking for DNS leaks...${NC}"
    local dns_servers=$(curl -s https://dnsleaktest.com/api/v1/dns 2>/dev/null || echo "API unavailable")
    if echo "$dns_servers" | grep -q "error"; then
        echo -e "${YELLOW}Could not verify DNS (network issue or Tor active)${NC}"
    else
        echo -e "${GREEN}DNS check: $dns_servers${NC}"
    fi
}

status() {
    echo -e "${CYAN}═══ ShadowOS Privacy Status ═══${NC}"
    echo ""
    echo -e "  Tor:       $(pgrep -x tor > /dev/null && echo -e "${GREEN}ACTIVE${NC}" || echo -e "${RED}INACTIVE${NC}")"
    echo -e "  DNS:       $(pgrep -x tor > /dev/null && echo -e "${GREEN}Tor DNS (5353)${NC}" || echo -e "${YELLOW}System default${NC}")"
    echo -e "  WireGuard: $(wg show 2>/dev/null | grep -q interface && echo -e "${GREEN}ACTIVE${NC}" || echo -e "${RED}INACTIVE${NC}")"
    echo -e "  Firewall:  $(command -v nft &>/dev/null && nft list ruleset 2>/dev/null | grep -q filter && echo -e "${GREEN}ACTIVE${NC}" || echo -e "${RED}INACTIVE${NC}")"
    echo ""
    local ip=$(curl -s https://ipinfo.io/ip 2>/dev/null || echo "unknown")
    echo -e "  Public IP: ${YELLOW}$ip${NC}"
}

case "${1:-status}" in
    start)   start_tor; setup_tor_dns ;;
    stop)    stop_tor ;;
    restart) stop_tor; sleep 1; start_tor; setup_tor_dns ;;
    dns)     setup_tor_dns ;;
    proxy)   setup_transparent_proxy ;;
    killswitch) setup_killswitch ;;
    mac)     setup_mac_randomize ;;
    vpn)     setup_vpn_wireguard ;;
    leak)    check_dns_leaks ;;
    status)  status ;;
    all)
        start_tor
        setup_tor_dns
        setup_transparent_proxy
        setup_killswitch
        setup_mac_randomize
        setup_vpn_wireguard
        echo ""
        echo -e "${GREEN}══════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ✓ Full privacy stack configured${NC}"
        echo -e "${GREEN}══════════════════════════════════════════════${NC}"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|dns|proxy|killswitch|mac|vpn|leak|status|all}"
        exit 1
        ;;
esac