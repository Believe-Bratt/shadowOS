#!/usr/bin/env bash
# ============================================================================
# ShadowOS Power Management Profiles
# Optimizes power consumption for laptop and desktop use
# ============================================================================

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
BOLD='\033[1m'

show_help() {
    echo -e "${BOLD}ShadowOS Power Management${NC}"
    echo ""
    echo "Usage: power-profile <command>"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  performance  — Maximum performance (desktop/gaming)"
    echo "  balanced     — Balanced power and performance (default)"
    echo "  powersave    — Maximum power saving (laptop/battery)"
    echo "  turbo        — Intel/AMD turbo boost control"
    echo "  status       — Show current power profile status"
    echo "  gpu <mode>   — Set GPU power mode (auto/low/high)"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Run as root${NC}"; exit 1
    fi
}

set_performance() {
    check_root
    echo -e "${CYAN}Setting: Performance Mode${NC}"

    # CPU Governor
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null

    # Disable USB autosuspend
    echo -1 > /sys/module/usbcore/parameters/autosuspend 2>/dev/null

    # Disable WiFi power save
    iwconfig wlan0 power off 2>/dev/null || true

    # Disable Bluetooth power save
    echo 0 > /sys/class/rfkill/rfkill0/soft 2>/dev/null || true

    # Set SATA to max performance
    echo 0 > /sys/class/scsi_host/host*/link_power_management_policy 2>/dev/null || true

    # Disable NMI watchdog
    echo 0 > /proc/sys/kernel/nmi_watchdog 2>/dev/null || true

    # CPU turbo boost
    echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || \
    echo 0 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true

    # Disable laptop mode
    echo 0 > /proc/sys/vm/laptop_mode 2>/dev/null || true

    success "Performance mode enabled"
}

set_balanced() {
    check_root
    echo -e "${CYAN}Setting: Balanced Mode${NC}"

    # CPU Governor
    echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null

    # Enable USB autosuspend with 2s timeout
    echo 2 > /sys/module/usbcore/parameters/autosuspend 2>/dev/null

    # Enable WiFi power save
    iwconfig wlan0 power on 2>/dev/null || true

    # SATA medium power
    echo min_power > /sys/class/scsi_host/host*/link_power_management_policy 2>/dev/null || true

    # Enable NMI watchdog
    echo 1 > /proc/sys/kernel/nmi_watchdog 2>/dev/null || true

    # Enable turbo boost
    echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || \
    echo 1 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true

    # Laptop mode
    echo 5 > /proc/sys/vm/laptop_mode 2>/dev/null || true

    success "Balanced mode enabled"
}

set_powersave() {
    check_root
    echo -e "${CYAN}Setting: Power Save Mode${NC}"

    # CPU Governor
    echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null

    # Aggressive USB autosuspend
    echo 1 > /sys/module/usbcore/parameters/autosuspend 2>/dev/null

    # WiFi aggressive power save
    iwconfig wlan0 power on 2>/dev/null || true

    # Disable Bluetooth
    echo 1 > /sys/class/rfkill/rfkill0/soft 2>/dev/null || true

    # SATA max power saving
    echo min_power > /sys/class/scsi_host/host*/link_power_management_policy 2>/dev/null || true

    # Disable NMI watchdog
    echo 0 > /proc/sys/kernel/nmi_watchdog 2>/dev/null || true

    # Disable turbo
    echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || \
    echo 0 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true

    # Aggressive laptop mode
    echo 5 > /proc/sys/vm/laptop_mode 2>/dev/null || true

    # Reduce swappiness
    sysctl vm.swappiness=10 2>/dev/null || true

    # Enable PCIe ASPM
    echo auto > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true

    success "Power save mode enabled"
}

set_turbo() {
    check_root
    echo -e "${CYAN}Setting: Turbo Mode (all cores max frequency)${NC}"

    # Set all CPUs to performance governor
    echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null

    # Disable turbo limit
    echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || \
    echo 0 > /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || true

    # Set minimum frequency to maximum
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/; do
        max_freq=$(cat "$cpu/scaling_max_freq" 2>/dev/null)
        [ -n "$max_freq" ] && echo "$max_freq" > "$cpu/scaling_min_freq" 2>/dev/null
    done

    success "Turbo mode enabled"
}

show_status() {
    echo -e "${BOLD}Power Profile Status:${NC}"
    echo ""

    # CPU Governor
    GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")
    echo -e "  CPU Governor: ${GREEN}$GOVERNOR${NC}"

    # Turbo status
    if [ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        TURBO=$(cat /sys/devices/system/cpu/intel_pstate/no_turbo)
        [ "$TURBO" = "0" ] && echo -e "  Turbo Boost: ${GREEN}enabled${NC}" || echo -e "  Turbo Boost: ${YELLOW}disabled${NC}"
    fi

    # Current CPU frequency
    CUR_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null || echo "N/A")
    MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null || echo "N/A")
    echo -e "  CPU Frequency: ${GREEN}${CUR_FREQ} kHz${NC} / ${MAX_FREQ} kHz max"

    # Battery status (if available)
    if [ -d /sys/class/power_supply/BAT0 ]; then
        STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        echo -e "  Battery: ${GREEN}${CAPACITY}%${NC} ($STATUS)"
    fi

    # SATA link power
    SATA=$(cat /sys/class/scsi_host/host0/link_power_management_policy 2>/dev/null || echo "N/A")
    echo -e "  SATA Power: ${GREEN}$SATA${NC}"

    # USB autosuspend
    USB_AUTO=$(cat /sys/module/usbcore/parameters/autosuspend 2>/dev/null || echo "N/A")
    echo -e "  USB Autosuspend: ${GREEN}${USB_AUTO}s${NC}"
}

set_gpu_mode() {
    local mode="$1"
    check_root

    case "$mode" in
        auto)
            echo auto > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || true
            echo "auto" > /sys/class/drm/card0/device/power_dpm_state 2>/dev/null || true
            success "GPU set to auto mode"
            ;;
        low)
            echo low > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || true
            echo "battery" > /sys/class/drm/card0/device/power_dpm_state 2>/dev/null || true
            success "GPU set to low power mode"
            ;;
        high)
            echo high > /sys/class/drm/card0/device/power_dpm_force_performance_level 2>/dev/null || true
            echo "performance" > /sys/class/drm/card0/device/power_dpm_state 2>/dev/null || true
            success "GPU set to high performance mode"
            ;;
        *)
            echo -e "${RED}Usage: power-profile gpu <auto|low|high>${NC}"
            exit 1
            ;;
    esac
}

case "${1:-help}" in
    performance) set_performance ;;
    balanced)    set_balanced ;;
    powersave)   set_powersave ;;
    turbo)       set_turbo ;;
    status)      show_status ;;
    gpu)         set_gpu_mode "$2" ;;
    help|--help|-h) show_help ;;
    *)           echo -e "${RED}Unknown command: $1${NC}"; show_help; exit 1 ;;
esac