#!/bin/bash
# ============================================================================
# ShadowOS ISO Builder (Debian Live-Build Based)
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_DIR="$PROJECT_DIR/output"
CACHE_DIR="$PROJECT_DIR/cache"

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

log() { echo -e "$1"; }
step() { log "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { log "  ${GREEN}✓${NC} $1"; }
error() { log "  ${RED}✗${NC} $1"; }

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

# Auto configuration scripts
cat > "$BUILD_CONFIG/config/auto/config" << 'AUTOCONF'
#!/bin/bash
set -e

lb config noauto \
    --distribution kali-rolling \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debian-installer live \
    --debian-installer-gui true \
    --linux-flavours "amd64" \
    --mode debian \
    --archive-areas "main contrib non-free" \
    --apt-recommends false \
    --apt-indices false \
    --memtest none \
    --iso-application "ShadowOS" \
    --iso-publisher "ShadowOS Team" \
    --iso-volume "ShadowOS 2026.1 NeonVanguard" \
    --binary-images iso-hybrid \
    --bootappend-live "boot=live components quiet splash" \
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
cat > "$BUILD_CONFIG/config/package-lists/shadowos.list.chroot" << 'PACKAGES'
# ShadowOS Core Packages
# Base system
linux-image-amd64
linux-headers-amd64
firmware-linux-free
firmware-linux-nonfree
firmware-misc-nonfree

# System
systemd
systemd-sysv
systemd-timesyncd
dbus
dbus-x11
policykit-1
console-setup
keyboard-configuration
locales
nano
vim
neovim
htop
btop
inxi
neofetch
lsb-release
ca-certificates
apt-transport-https
gnupg
dirmngr
software-properties-common

# Display
xorg
xorg-xinit
xserver-xorg-video-all
xserver-xorg-input-all
mesa-utils
vulkan-tools
libvulkan1

# Desktop Environments
kde-plasma-desktop
kde-config-gtk-style
sddm
plymouth
plymouth-themes

# Terminal
alacritty
kitty
zsh
tmux
screen

# Shell & Tools
oh-my-zsh
powerlevel10k
zsh-autosuggestions
zsh-syntax-highlighting
fzf
ripgrep
fd-find
bat
exa
eza
dust
procs
sd
tldr
broot
lazygit
delta
ranger
ncdu

# Network
network-manager
network-manager-gnome
wpasupplicant
wireless-tools
ethtool
net-tools
iproute2
curl
wget
rsync
openssh-server
openssh-client
tor
torsocks
proxychains4
nmap
netcat-openbsd
tcpdump
wireshark-common
tshark
dnsutils
whois
traceroute
mtr
iputils-ping

# Security
nftables
iptables
ufw
firejail
apparmor
apparmor-profiles
apparmor-utils
lynis
rkhunter
chkrootkit
aide
clamav
clamav-daemon
libpam-tmpdir
libpam-cap

# Encryption
cryptsetup
lvm2
mdadm
veracrypt
gnupg
seahorse
kleopatra

# Development
build-essential
cmake
make
gcc
g++
autoconf
automake
libtool
pkg-config
git
curl
wget
python3
python3-pip
python3-venv
python3-dev
nodejs
npm
yarn
golang-go
rustc
cargo
ruby
lua5.4
php
docker.io
docker-compense
podman
buildah

# AI/ML
ollama
python3-torch
python3-transformers
python3-numpy
python3-pandas
python3-scipy
python3-sklearn
jupyter-notebook
jupyterlab

# Graphics
imagemagick
gimp
inkscape
blender

# Multimedia
vlc
mpv
ffmpeg
pavucontrol
pulseaudio
pipewire
wireplumber

# Office
libreoffice-writer
libreoffice-calc
libreoffice-impress

# File Management
thunar
file-roller
p7zip-full
unzip
zip
rsync
rclone

# Utilities
xdg-utils
xdg-user-dirs
cups
cups-browsed
sane
simple-scan
evince
zathura
atool
jq
yq
hexedit
xxd
tmuxinator

# Pentest Tools (core selection)
nmap
masscan
nikto
sqlmap
metasploit-framework
wireshark
john
hashcat
hydra
aircrack-ng
recon-ng
theharvester
maltego
setoolkit
beef-xss
mitmproxy
burpsuite
dirb
gobuster
wfuzz
ffuf
subfinder
amass
ghidra
radare2
binwalk
volatility
autopsy
sleuthkit
mimikatz
impacket
powershell

# Cloud
kubectl
helm
terraform
PACKAGES

success "Package lists created"

# ─── Chroot Hooks ───────────────────────────────────────────────────────
cat > "$BUILD_CONFIG/config/hooks/chroot/0100-shadowos.chroot" << 'CHROOT_HOOK'
#!/bin/bash
set -e

echo "[ShadowOS] Configuring chroot environment..."

# Create ShadowOS directories
mkdir -p /opt/ShadowOS/{scripts,configs,themes,ai}
mkdir -p /etc/shadowos

# Copy configurations
if [ -d /tmp/shadowos-config ]; then
    cp -r /tmp/shadowos-config/* /etc/shadowos/ 2>/dev/null || true
fi

# Set default shell to zsh
chsh -s /usr/bin/zsh root

# Enable services
systemctl enable ssh 2>/dev/null || true
systemctl enable nftables 2>/dev/null || true
systemctl enable apparmor 2>/dev/null || true
systemctl enable tor 2>/dev/null || true
systemctl enable ollama 2>/dev/null || true
systemctl enable sddm 2>/dev/null || true

# Create AI helper symlinks
ln -sf /opt/ShadowOS/scripts/ai /usr/local/bin/ai 2>/dev/null || true
ln -sf /opt/ShadowOS/scripts/ai-scan /usr/local/bin/ai-scan 2>/dev/null || true
ln -sf /opt/ShadowOS/scripts/ai-review /usr/local/bin/ai-review 2>/dev/null || true

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
    cp "$ISO_FILE" "$OUTPUT_DIR/ShadowOS-2026.1-NeonVanguard-amd64.iso"
    success "ISO created: $OUTPUT_DIR/ShadowOS-2026.1-NeonVanguard-amd64.iso"
    ls -lh "$OUTPUT_DIR/ShadowOS-2026.1-NeonVanguard-amd64.iso"
else
    error "ISO build failed. Check $BUILD_DIR/build.log"
    exit 1
fi

cd "$PROJECT_DIR"
success "ISO build complete"