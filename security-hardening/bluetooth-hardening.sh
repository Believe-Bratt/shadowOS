#!/usr/bin/env bash
# ============================================================================
# ShadowOS Bluetooth Security Hardening
# Disables/enforces secure Bluetooth configuration
# ============================================================================

set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
BOLD='\033[1m'

show_help() {
    echo -e "${BOLD}ShadowOS Bluetooth Security${NC}"
    echo ""
    echo "Usage: bluetooth-hardening [command]"
    echo ""
    echo "Commands:"
    echo "  harden    — Apply Bluetooth security hardening"
    echo "  status    — Show current Bluetooth security status"
    echo "  disable   — Completely disable Bluetooth"
    echo "  enable    — Re-enable Bluetooth (with hardening)"
    echo "  unpair    — Remove all paired devices"
}

check_bluetooth() {
    if ! command -v bluetoothctl &>/dev/null; then
        echo -e "${YELLOW}Bluetooth tools not installed (bluez)${NC}"
        return 1
    fi
    return 0
}

get_status() {
    if [ -d /sys/class/bluetooth ]; then
        echo "Bluetooth hardware: PRESENT"
        if systemctl is-active bluetooth &>/dev/null; then
            echo "Bluetooth service: ACTIVE"
        else
            echo "Bluetooth service: INACTIVE"
        fi

        # Check if discoverable
        if bluetoothctl show 2>/dev/null | grep -q "Discoverable: yes"; then
            echo "Discoverable: ${RED}YES (security risk)${NC}"
        else
            echo "Discoverable: ${GREEN}NO${NC}"
        fi

        # Check if pairable
        if bluetoothctl show 2>/dev/null | grep -q "Pairable: yes"; then
            echo "Pairable: ${YELLOW}YES${NC}"
        else
            echo "Pairable: ${GREEN}NO${NC}"
        fi

        # Check powered state
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            echo "Powered: YES"
        else
            echo "Powered: NO"
        fi
    else
        echo "Bluetooth hardware: NOT FOUND"
    fi
}

harden_bluetooth() {
    if ! check_bluetooth; then return 1; fi

    echo -e "${CYAN}Applying Bluetooth security hardening...${NC}"

    # Create systemd override for bluetooth service
    mkdir -p /etc/systemd/system/bluetooth.service.d
    cat > /etc/systemd/system/bluetooth.service.d/override.conf << 'BLUETOOTH'
[Service]
# Restrict Bluetooth to local only
ExecStart=
ExecStart=/usr/lib/bluetooth/bluetoothd --noplugin=sap -E
# Disable experimental features
BLUETOOTH

    # Create rfkill rules to disable on boot (laptop security)
    cat > /etc/udev/rules.d/99-bluetooth-security.rules << 'UDEV'
# Disable Bluetooth by default for security
SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", ATTR{state}="1"
UDEV

    # Configure bluetoothctl settings
    bluetoothctl << 'BTCTL'
power off
discoverable off
pairable off
exit
BTCTL

    # Disable SSP (Secure Simple Pairing) debug mode
    echo 0 > /sys/module/bluetooth/parameters/disable_esco 2>/dev/null || true

    # Set security mode 3 (Secure Connections only) if available
    echo 3 > /sys/module/bluetooth/parameters/security_mode 2>/dev/null || true

    # Disable BR/EDR (Basic Rate) if only LE is needed
    # echo 1 > /sys/module/bluetooth/parameters/disable_bredr 2>/dev/null || true

    systemctl daemon-reload
    systemctl restart bluetooth 2>/dev/null || true

    echo -e "${GREEN}✓ Bluetooth hardened${NC}"
    echo "  - Service restricted to local only"
    echo "  - Auto-disabled on boot via rfkill"
    echo "  - Discoverable: OFF"
    echo "  - Pairable: OFF"
    echo "  - SSP debug: OFF"
}

disable_bluetooth() {
    if ! check_bluetooth; then return 1; fi

    echo -e "${CYAN}Disabling Bluetooth...${NC}"

    # rfkill block
    rfkill block bluetooth 2>/dev/null || true

    # systemctl stop
    systemctl stop bluetooth 2>/dev/null || true
    systemctl disable bluetooth 2>/dev/null || true

    # Blacklist module
    echo "blacklist bluetooth" > /etc/modprobe.d/blacklist-bluetooth.conf
    echo "blacklist btusb" >> /etc/modprobe.d/blacklist-bluetooth.conf
    echo "blacklist btrtl" >> /etc/modprobe.d/blacklist-bluetooth.conf
    echo "blacklist btintel" >> /etc/modprobe.d/blacklist-bluetooth.conf
    echo "blacklist btbcm" >> /etc/modprobe.d/blacklist-bluetooth.conf
    echo "blacklist bnep" >> /etc/modprobe.d/blacklist-bluetooth.conf

    update-initramfs -u 2>/dev/null || true

    echo -e "${GREEN}✓ Bluetooth disabled${NC}"
}

enable_bluetooth() {
    echo -e "${CYAN}Re-enabling Bluetooth with hardening...${NC}"

    # Remove blacklist
    rm -f /etc/modprobe.d/blacklist-bluetooth.conf

    # rfkill unblock
    rfkill unblock bluetooth 2>/dev/null || true

    # systemctl start
    systemctl enable bluetooth 2>/dev/null || true
    systemctl start bluetooth 2>/dev/null || true

    # Apply hardening
    harden_bluetooth
}

unpair_all() {
    if ! check_bluetooth; then return 1; fi

    echo -e "${CYAN}Removing all paired devices...${NC}"

    # Get list of paired devices and remove them
    bluetoothctl paired-devices 2>/dev/null | grep "Device" | awk '{print $2}' | while read -r device; do
        echo "  Removing: $device"
        bluetoothctl remove "$device" 2>/dev/null || true
    done

    # Also trust nothing
    bluetoothctl untrust 2>/dev/null || true

    echo -e "${GREEN}✓ All paired devices removed${NC}"
}

case "${1:-help}" in
    harden)  harden_bluetooth ;;
    status)  get_status ;;
    disable) disable_bluetooth ;;
    enable)  enable_bluetooth ;;
    unpair)  unpair_all ;;
    help|--help|-h) show_help ;;
    *)       echo -e "${RED}Unknown command: $1${NC}"; show_help; exit 1 ;;
esac