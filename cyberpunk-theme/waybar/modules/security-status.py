#!/usr/bin/env python3
import subprocess

def get_security_status():
    statuses = []
    color = "#00ff88"  # neon green

    # Check firewall
    try:
        fw = subprocess.run(['systemctl', 'is-active', 'nftables'],
                           capture_output=True, text=True, timeout=1)
        if 'active' in fw.stdout:
            statuses.append("🔒 Firewall")
        else:
            statuses.append("⚠ NoFirewall")
            color = "#ffbf00"  # amber
    except:
        statuses.append("⚠ FirewallErr")
        color = "#ff0055"  # red

    # Check Tor
    try:
        tor = subprocess.run(['systemctl', 'is-active', 'tor'],
                            capture_output=True, text=True, timeout=1)
        if 'active' in tor.stdout:
            statuses.append("🧅 Tor")
        else:
            statuses.append("○ TorOff")
    except:
        pass

    # Check VPN (WireGuard)
    try:
        vpn = subprocess.run(['wg', 'show'], capture_output=True, text=True, timeout=1)
        if vpn.returncode == 0 and 'interface:' in vpn.stdout:
            statuses.append("🔐 VPN")
        else:
            statuses.append("○ VPNOff")
    except:
        statuses.append("○ VPNOff")

    # Check AppArmor
    try:
        aa = subprocess.run(['systemctl', 'is-active', 'apparmor'],
                           capture_output=True, text=True, timeout=1)
        if 'active' in aa.stdout or 'enforced' in aa.stdout:
            statuses.append("🛡️ AppArmor")
        else:
            statuses.append("○ AAOff")
    except:
        pass

    return " ".join(statuses), color

if __name__ == "__main__":
    status, color = get_security_status()
    print(f"{status}|{color}|Security Status\n{status}")
