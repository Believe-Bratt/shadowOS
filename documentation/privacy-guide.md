# ShadowOS Privacy & Anonymity Guide

> **"Privacy is not something that I'm merely entitled to, it's an absolute prerequisite."** — Marlon Brando

## Overview

ShadowOS includes a comprehensive privacy stack designed to protect your identity, communications, and browsing habits. No system can guarantee complete anonymity, but ShadowOS provides industry-leading tools to maximize your privacy.

## Privacy Layers

### Layer 1: Network-Level Privacy

#### Tor Network
```bash
# Start Tor
sudo systemctl start tor

# Configure applications to use Tor
export http_proxy="socks5://127.0.0.1:9050"
export https_proxy="socks5://127.0.0.1:9050"

# Use torsocks for any command
torsocks curl https://check.torproject.org/api/ip

# Or use proxychains
proxychains4 firefox
```

#### DNS-over-HTTPS
```bash
# Configure systemd-resolved for DoH
sudo mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/doh.conf << 'EOF'
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 9.9.9.9#dns.quad9.net
DNSOverTLS=yes
DNSSEC=yes
EOF
sudo systemctl restart systemd-resolved
```

#### VPN with WireGuard
```bash
# Generate keys
wg genkey | tee privatekey | wg pubkey > publickey

# Configure tunnel
sudo wg set wg0 \
    private-key /path/to/privatekey \
    endpoint YOUR_SERVER:51820 \
    allowed-routes 0.0.0.0/0,::/0 \
    persistent-keepalive 25

# Activate
sudo wg-quick up wg0
```

### Layer 2: System-Level Privacy

#### MAC Address Randomization
```bash
# Randomize MAC on boot
sudo macchanger -r $(ip route | grep default | awk '{print $5}')

# Or use NetworkManager's built-in randomization
nmcli connection modify "YourConnection" \
    802-3-ethernet.cloned-mac-address random
```

#### Firewall Protection
```bash
# Check firewall status
sudo nft list ruleset

# ShadowOS default-deny policy is active
# Only essential ports are open
```

#### Encrypted Storage
```bash
# Create encrypted volume
sudo cryptsetup luksFormat /dev/sdX
sudo cryptsetup open /dev/sdX secure_data
sudo mkfs.btrfs /dev/mapper/secure_data
sudo mount /dev/mapper/secure_data /mnt/secure

# Or use Veracrypt for cross-platform encryption
veracrypt --create /path/to/volume
```

### Layer 3: Application-Level Privacy

#### Browser Isolation
```bash
# Launch Firefox through Tor
torsocks firefox

# Or use Tor Browser directly
torbrowser-launcher

# Container isolation with Firejail
firejail --net=tor firefox
```

#### Secure Communication
```bash
# GPG key generation
gpg --full-generate-key

# Encrypt a file
gpg -c sensitive_file.txt

# Encrypt for a recipient
gpg -e -r recipient@email.com document.pdf
```

#### Secure Deletion
```bash
# Secure file deletion (overwrites data)
srm sensitive_file.txt

# Secure directory deletion
srm -r sensitive_directory/

# Wipe free space
sudo sfill -l /
```

### Layer 4: Operational Security

#### Kill Switch
```bash
# Enable network kill-switch (blocks traffic outside Tor)
sudo bash /opt/ShadowOS/system-services/tor-privacy.sh killswitch

# Or manually with iptables
sudo iptables -F OUTPUT
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 9050 -j ACCEPT
sudo iptables -A OUTPUT -j REJECT
```

#### DNS Leak Prevention
```bash
# Test for DNS leaks
curl https://dnsleaktest.com/api/v1/dns

# Or visit https://dnsleaktest.com in browser
# Ensure only your configured DNS servers appear
```

#### Traffic Analysis Protection
```bash
# Use Tor bridges in censored environments
echo "UseBridges 1" >> /etc/tor/torrc
echo "Bridge obfs4 <bridge_address>:<port> <fingerprint> cert=<cert> iat-mode=0" >> /etc/tor/torrc

# Configure pluggable transports
apt install obfs4proxy
```

## Privacy Monitoring Dashboard

Run the privacy status check:
```bash
tor-privacy.sh status
```

Expected output:
```
═══ ShadowOS Privacy Status ═══

  Tor:       ACTIVE
  DNS:       Tor DNS (5353)
  WireGuard: ACTIVE/INACTIVE
  Firewall:  ACTIVE

  Public IP: [Your Tor Exit Node IP]
```

## Best Practices

1. **Always use Tor for sensitive browsing**
2. **Enable VPN on untrusted networks**
3. **Use encrypted DNS (DoH/DoT)**
4. **Randomize MAC address on public WiFi**
5. **Secure-delete sensitive files**
6. **Regularly update your system**
7. **Use GPG for sensitive communications**
8. **Enable full-disk encryption during install**
9. **Use separate browser profiles for different activities**
10. **Audit your network connections regularly**

## Limitations

> **Important:** No operating system can guarantee complete anonymity. ShadowOS provides tools to maximize privacy, but:
> 
> - User behavior can still identify you
> - Browser fingerprinting techniques exist
> - Traffic pattern analysis is possible
> - Zero-day vulnerabilities may exist
> - Physical access compromises all software protections
> 
> Use ShadowOS responsibly and in compliance with local laws.