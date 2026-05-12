#!/bin/bash
# ============================================================================
# ShadowOS ISO Builder (Debian Live-Build Based)
# STAGE 1: Minimal Base ISO
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_DIR="$PROJECT_DIR/output"
CACHE_DIR="$PROJECT_DIR/cache"

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

log() { echo -e "$1"; }
step() { log "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { log "  ${GREEN}✓${NC} $1"; }
error() { log "  ${RED}✗${NC} $1"; }
warn() { log "  ${YELLOW}!${NC} $1"; }

mkdir -p "$BUILD_DIR" "$OUTPUT_DIR" "$CACHE_DIR"

# ─── Check Dependencies ─────────────────────────────────────────────────
step "CHECKING BUILD DEPENDENCIES"

MISSING=()
for cmd in live-build debootstrap syslinux xorriso grub-mkrescue; do
    if ! command -v "$cmd" &>/dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    error "Missing dependencies: ${MISSING[*]}"
    log "Install with: sudo apt install ${MISSING[*]}"
    exit 1
fi
success "All build dependencies found"

# Clean any previous build artifacts
step "CLEANING PREVIOUS BUILD"
if [ -d "$BUILD_DIR/live-build" ]; then
    lb clean
fi

# ─── Configure Live-Build ───────────────────────────────────────────────
step "CONFIGURING LIVE-BUILD"

BUILD_CONFIG="$BUILD_DIR/live-build"
rm -rf "$BUILD_CONFIG"
mkdir -p "$BUILD_CONFIG/config/includes.chroot/opt/ShadowOS"
mkdir -p "$BUILD_CONFIG/config/includes.chroot/etc/skel"
mkdir -p "$BUILD_CONFIG/config/includes.chroot/root"
mkdir -p "$BUILD_CONFIG/config/includes.binary/isolinux"
mkdir -p "$BUILD_CONFIG/config/includes.binary/EFI/BOOT"
mkdir -p "$BUILD_CONFIG/config/hooks/normal"
mkdir -p "$BUILD_CONFIG/config/hooks/chroot"
mkdir -p "$BUILD_CONFIG/config/auto"
mkdir -p "$BUILD_CONFIG/config/package-lists"
mkdir -p "$BUILD_CONFIG/config/includes.binary/grub"
mkdir -p "$BUILD_CONFIG/config/includes.binary/isolinux"
mkdir -p "$BUILD_CONFIG/config/includes.binary/EFI/BOOT"

# Auto configuration scripts
cat > "$BUILD_CONFIG/config/auto/config" << 'AUTOCONF'
#!/bin/bash
set -e

echo "lb config $*"
lb config noauto \
    --distribution kali-rolling \
    --archive-areas "main contrib non-free" \
    --debian-installer live \
    --debian-installer-gui true \
    --linux-flavours "amd64" \
    --mode debian \
    --apt-recommends false \
    --apt-indices false \
    --memtest none \
    --iso-application "ShadowOS" \
    --iso-publisher "ShadowOS Team" \
    --iso-volume "ShadowOS 2026.1 believe" \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components quiet splash" \
    --mirror-bootstrap http://http.kali.org/kali \
    --mirror-chroot http://http.kali.org/kali \
    --mirror-chroot-security http://http.kali.org/kali \
    --mirror-binary http://http.kali.org/kali \
    --mirror-binary-security http://http.kali.org/kali \
    --debootstrap-script kali-rolling \
    --keyring-packages "kali-archive-keyring" \
    "${@}"
AUTOCONF
chmod +x "$BUILD_CONFIG/config/auto/config"

cat > "$BUILD_CONFIG/config/auto/build" << 'AUTOBUILD'
#!/bin/bash
set -e
lb build 2>&1 | tee build.log
AUTOBUILD
chmod +x "$BUILD_CONFIG/config/auto/build"

# ─── Package Lists ──────────────────────────────────────────────────────
# Use minimal package list for STAGE 1 (base ISO)
# Post-install tools will be installed after system installation
cat > "$BUILD_CONFIG/config/package-lists/shadowos.list.chroot" << 'PACKAGES'
# ShadowOS Minimal Base ISO Packages
# Core system - stable, small footprint
# This is the STAGE 1 minimal ISO

# Base system
linux-image-amd64
linux-headers-amd64
firmware-linux-free
firmware-linux-nonfree
coreutils

# System essentials
systemd
systemd-sysv
systemd-timesyncd
dbus
dbus-x11
policykit-1
console-setup
keyboard-configuration
locales
ca-certificates
apt-transport-https
gnupg
dirmngr

# Display server
xorg
xorg-xinit
xserver-xorg-video-all
xserver-xorg-input-all
mesa-utils

# Desktop Environment (KDE - minimal)
kde-plasma-desktop
kde-config-gtk-style
sddm
plymouth
plymouth-themes

# Terminal essentials
zsh
tmux
screen
alacritty
kitty

# Basic shell tools
vim
neovim
htop
btop
inxi
neofetch
curl
wget
git

# Network essentials
network-manager
network-manager-gnome
wpasupplicant
wireless-tools
net-tools
iproute2
openssh-server
openssh-client

# Security base
nftables
iptables
ufw
firejail
apparmor
apparmor-profiles
lynis

# Development base
build-essential
python3
python3-pip
python3-venv

# File management
thunar
file-roller
p7zip-full
unzip
zip
rsync

# System utilities
xdg-utils
xdg-user-dirs
cups
cups-browsed
evince
jq

# Post-install marker
shadowos-postinstall
PACKAGES

success "Package lists created"

# ─── Copy Post-Install Script to ISO ─────────────────────────────────────
step "COPYING POST-INSTALL SCRIPT"
if [ -f "$PROJECT_DIR/scripts/post-install-tools.sh" ]; then
    cp "$PROJECT_DIR/scripts/post-install-tools.sh" "$BUILD_CONFIG/config/includes.chroot/opt/ShadowOS/post-install-tools.sh"
    chmod +x "$BUILD_CONFIG/config/includes.chroot/opt/ShadowOS/post-install-tools.sh"
    success "Post-install script included"
else
    warn "Post-install script not found at $PROJECT_DIR/scripts/post-install-tools.sh"
fi

# ─── Chroot Hooks ───────────────────────────────────────────────────────
cat > "$BUILD_CONFIG/config/hooks/chroot/0100-shadowos.chroot" << 'CHROOT_HOOK'
#!/bin/bash
set -e

echo "[ShadowOS] Configuring chroot environment..."

# Create ShadowOS directories
mkdir -p /opt/ShadowOS/{scripts,configs,themes,ai}
mkdir -p /etc/shadowos

# Set default shell to zsh
chsh -s /usr/bin/zsh root

# Enable services
systemctl enable ssh 2>/dev/null || true
systemctl enable nftables 2>/dev/null || true
systemctl enable apparmor 2>/dev/null || true
systemctl enable sddm 2>/dev/null || true

# Create post-install helper
cat > /usr/local/bin/shadowos-postinstall << 'POSTINSTALL'
#!/bin/bash
# Run post-install tools after system installation
if [ -f /opt/ShadowOS/post-install-tools.sh ]; then
    sudo /opt/ShadowOS/post-install-tools.sh
else
    echo "Post-install script not found"
fi
POSTINSTALL
chmod +x /usr/local/bin/shadowos-postinstall

echo "[ShadowOS] Chroot configuration complete"
CHROOT_HOOK
chmod +x "$BUILD_CONFIG/config/hooks/chroot/0100-shadowos.chroot"

# ─── Binary Hooks (ISO-specific) ────────────────────────────────────────
cat > "$BUILD_CONFIG/config/hooks/normal/0100-iso-setup.binary" << 'BINARY_HOOK'
#!/bin/bash
echo "[ShadowOS] Setting up ISO-specific configurations..."
BINARY_HOOK
chmod +x "$BUILD_CONFIG/config/hooks/normal/0100-iso-setup.binary"

# ─── GRUB Configuration ─────────────────────────────────────────────────
cat > "$BUILD_CONFIG/config/includes.binary/grub/grub.cfg" << 'GRUB'
set timeout=10
set default=0

menuentry "ShadowOS Live" {
    linux /live/vmlinuz boot=live components quiet splash
    initrd /live/initrd.img
}

menuentry "ShadowOS Live (Safe Graphics)" {
    linux /live/vmlinuz boot=live components nomodeset
    initrd /live/initrd.img
}

menuentry "ShadowOS Installer (Text)" {
    linux /live/vmlinuz boot=live components quiet
    initrd /live/initrd.img
}

menuentry "ShadowOS Persistence" {
    linux /live/vmlinuz boot=live components persistent
    initrd /live/initrd.img
}

menuentry "Memory Test (Memtest86+)" {
    linux16 /memtest86+/memtest.bin
}

menuentry "Reboot" {
    reboot
}
GRUB

# ─── Build ISO ──────────────────────────────────────────────────────────
step "BUILDING ISO"

cd "$BUILD_CONFIG"

log "Running live-build (this may take a while)..."
lb build 2>&1 | tee "$BUILD_DIR/build.log"

# Find and copy the ISO
ISO_FILE=$(find . -maxdepth 1 -name "*.iso" -type f | head -1)

if [ -n "$ISO_FILE" ]; then
    cp "$ISO_FILE" "$OUTPUT_DIR/ShadowOS-2026.1-believe-amd64.iso"
    success "ISO created: $OUTPUT_DIR/ShadowOS-2026.1-believe-amd64.iso"
    ls -lh "$OUTPUT_DIR/ShadowOS-2026.1-believe-amd64.iso"
else
    error "ISO build failed. Check $BUILD_DIR/build.log"
    exit 1
fi

cd "$PROJECT_DIR"
success "ISO build complete"

# ─── Post-Build Instructions ────────────────────────────────────────────
step "POST-BUILD INSTRUCTIONS"
log "
${CYAN}STAGE 1 COMPLETE - Minimal Base ISO Created${NC}

To install additional tools after system installation:

  1. Boot the installed system
  2. Run: sudo /opt/ShadowOS/post-install-tools.sh
  3. Or run: sudo shadowos-postinstall

Available tool categories:
  - AI/ML (ollama, jupyter, torch, transformers)
  - Pentest (metasploit, burpsuite, nmap, etc.)
  - Graphics (gimp, blender, inkscape)
  - Office (libreoffice)
  - Docker
  - Terminal tools
  - Multimedia

This staged approach ensures:
  - Faster ISO build
  - Smaller ISO size
  - Better dependency resolution
  - More stable base system
"