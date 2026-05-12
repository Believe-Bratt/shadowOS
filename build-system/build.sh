#!/bin/bash
# ============================================================================
# ShadowOS Main Build Script
# STAGED BUILD APPROACH
# ============================================================================

# Save original user home before re-exec as root
ORIG_HOME="$HOME"

# Re-exec as root if not already root (preserves all args and env)
if [ "$(id -u)" -ne 0 ]; then
    exec sudo "$0" "$@"
fi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_DIR="$PROJECT_DIR/output"
CACHE_DIR="$PROJECT_DIR/cache"
LOG_FILE="$BUILD_DIR/build.log"

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

log() { echo -e "$1" | tee -a "$LOG_FILE" 2>/dev/null || echo -e "$1"; }
step() { log "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { log "  ${GREEN}✓${NC} $1"; }
error() { log "  ${RED}✗${NC} $1"; }

mkdir -p "$BUILD_DIR" "$OUTPUT_DIR" "$CACHE_DIR"

# ─── STAGE 1: Minimal Base ISO ───────────────────────────────────────────
build_minimal_iso() {
    step "BUILDING SHADOWOS MINIMAL BASE ISO (STAGE 1)"
    log "Version: 2026.1 | Codename: NeonVanguard"
    log "This creates a minimal ISO with core system only."
    log "Additional tools can be installed post-installation.\n"
    
     # Check dependencies
     for cmd in debootstrap lb xorriso grub-mkrescue tar gzip bzip2 unzip cpio xz; do
         if ! command -v "$cmd" &>/dev/null; then
             error "Missing: $cmd (run 'make setup-deps')"
             exit 1
         fi
     done

    # Ensure kali-archive-keyring is installed (needed for GPG verification)
    if ! dpkg -l kali-archive-keyring &>/dev/null; then
        log "  Installing kali-archive-keyring..."
        apt-get install -y kali-archive-keyring 2>&1 | tee -a "$BUILD_DIR/build.log"
    fi
    
    # Clean previous build — COMPLETELY nuke the build directory so no stale
    # live-build cache (e.g. Ubuntu "precise" bootstrap tarballs) can persist.
    log "  Purging all build artifacts and caches..."
    rm -rf "$BUILD_DIR"
    rm -rf "$CACHE_DIR"
    rm -rf "$OUTPUT_DIR/iso"
    rm -rf "$ORIG_HOME/.cache/live-build" "$ORIG_HOME/.local/share/live-build" 2>/dev/null || true
    rm -rf /tmp/live-build-* 2>/dev/null || true
    rm -rf /var/cache/live-build /var/lib/live-build /var/tmp/live-build 2>/dev/null || true
    rm -rf /root/.cache/live-build 2>/dev/null || true
    success "All build caches purged"

    # Recreate build directory structure from scratch
    mkdir -p "$BUILD_DIR" "$OUTPUT_DIR" "$CACHE_DIR"
    LIVE_DIR="$BUILD_DIR/live"
    mkdir -p "$LIVE_DIR/config/includes.chroot/opt/ShadowOS"
    mkdir -p "$LIVE_DIR/config/includes.binary/isolinux"
    mkdir -p "$LIVE_DIR/config/includes.binary/EFI/BOOT"
    mkdir -p "$LIVE_DIR/config/hooks/chroot"
    mkdir -p "$LIVE_DIR/config/package-lists"
    mkdir -p "$LIVE_DIR/config/includes.binary/grub"
    mkdir -p "$LIVE_DIR/config/auto"

    # Create auto config
    cat > "$LIVE_DIR/config/auto/config" << 'AUTOCONF'
#!/bin/bash
set -e
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
    --bootstrap-cache false \
    --iso-application "ShadowOS" \
    --iso-publisher "ShadowOS Team" \
    --iso-volume "ShadowOS2026" \
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
    chmod +x "$LIVE_DIR/config/auto/config"

    # Minimal package list
    cat > "$LIVE_DIR/config/package-lists/shadowos.list.chroot" << 'PACKAGES'
# ShadowOS Minimal Base ISO Packages
linux-image-amd64
linux-headers-amd64
firmware-linux-free
firmware-linux-nonfree
coreutils
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
xorg
xorg-xinit
xserver-xorg-video-all
xserver-xorg-input-all
mesa-utils
kde-plasma-desktop
kde-config-gtk-style
sddm
plymouth
plymouth-themes
zsh
tmux
screen
alacritty
kitty
vim
neovim
htop
btop
inxi
fastfetch
curl
wget
git
network-manager
network-manager-gnome
wpasupplicant
wireless-tools
net-tools
iproute2
openssh-server
openssh-client
nftables
iptables
ufw
firejail
apparmor
apparmor-profiles
lynis
build-essential
python3
python3-pip
python3-venv
dolphin
file-roller
p7zip-full
unzip
zip
rsync
xdg-utils
xdg-user-dirs
cups
cups-browsed
evince
jq
PACKAGES

    # Copy post-install script to chroot
    cp "$PROJECT_DIR/scripts/post-install-tools.sh" "$LIVE_DIR/config/includes.chroot/opt/ShadowOS/"

    # Create chroot hook
    cat > "$LIVE_DIR/config/hooks/chroot/0100-shadowos.chroot" << 'HOOK'
#!/bin/bash
set -e
chsh -s /usr/bin/zsh root
systemctl enable nftables 2>/dev/null || true
systemctl enable apparmor 2>/dev/null || true
systemctl enable ssh 2>/dev/null || true
systemctl enable sddm 2>/dev/null || true
if [ -f /opt/ShadowOS/post-install-tools.sh ]; then
    chmod +x /opt/ShadowOS/post-install-tools.sh
fi
HOOK
    chmod +x "$LIVE_DIR/config/hooks/chroot/0100-shadowos.chroot"

    # Create GRUB config
    cat > "$LIVE_DIR/config/includes.binary/grub/grub.cfg" << 'GRUB'
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
menuentry "ShadowOS Installer" {
    linux /live/vmlinuz boot=live components quiet splash installer
    initrd /live/initrd.img
}
GRUB

    success "ISO build configured"

    # Run the actual build. The rm -rf "$BUILD_DIR" above already wiped all
    # stale live-build caches (including any Ubuntu "precise" tarballs).
    # We set LB_* environment variables to override system defaults in
    # /etc/live/build.conf, then run lb config + lb build.
    step "RUNNING LIVE-BUILD"
    cd "$LIVE_DIR"

    # Kill all caching at every level
    export LB_CACHE=false
    export LB_BOOTSTRAP_CACHE=false
    export LB_BINARY_CACHE=false

    # Workaround for WSL filesystem issues with live-build extraction
    export TMPDIR=/tmp

    # Override system defaults in /etc/live/build.conf
    export LB_DISTRIBUTION="kali-rolling"
    export LB_PARENT_DISTRIBUTION="kali-rolling"
    export LB_MIRROR_BOOTSTRAP="http://http.kali.org/kali"
    export LB_PARENT_MIRROR_BOOTSTRAP="http://http.kali.org/kali"
    export LB_MIRROR_CHROOT="http://http.kali.org/kali"
    export LB_PARENT_MIRROR_CHROOT="http://http.kali.org/kali"
    export LB_MIRROR_CHROOT_SECURITY="http://http.kali.org/kali"
    export LB_PARENT_MIRROR_CHROOT_SECURITY="http://http.kali.org/kali"
    export LB_MIRROR_BINARY="http://http.kali.org/kali"
    export LB_PARENT_MIRROR_BINARY="http://http.kali.org/kali"
    export LB_MIRROR_BINARY_SECURITY="http://http.kali.org/kali"
    export LB_PARENT_MIRROR_BINARY_SECURITY="http://http.kali.org/kali"
    export LB_DEBIAN_INSTALLER="live"
    export LB_LINUX_FLAVOURS="amd64"
    export LB_ARCHITECTURES="amd64"
    export LB_MODE="debian"
    export LB_APT_RECOMMENDS="false"
    export LB_APT_INDICES="false"
    export LB_MEMTEST="none"
    export LB_BINARY_IMAGES="iso-hybrid"
    export LB_BOOTAPPEND_LIVE="boot=live components quiet splash"

    # Generate live-build configuration
    log "  Configuring live-build..."
    lb config 2>&1 | tee -a "$BUILD_DIR/build.log"

    # Full build (bootstrap + chroot + binary)
    log "  Building ISO (this may take a while)..."
    lb build 2>&1 | tee -a "$BUILD_DIR/build.log"
    
    # Check for output
    if [ -f "$LIVE_DIR/binary.hybrid.iso" ]; then
        mkdir -p "$OUTPUT_DIR/iso"
        cp "$LIVE_DIR/binary.hybrid.iso" "$OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64.iso"
        success "ISO created: $OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64.iso"
        ls -lh "$OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64.iso"
    else
        error "ISO build failed. Check $BUILD_DIR/build.log"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
}

# ─── STAGE 2: Post-Install Tools ─────────────────────────────────────────
build_postinstall() {
    step "POST-INSTALL TOOLS INFO"
    log "
After installing the base system, run:
  sudo /opt/ShadowOS/post-install-tools.sh

Available tool categories:
  - AI/ML (ollama, jupyter, torch, transformers)
  - Pentest (metasploit, burpsuite, nmap, etc.)
  - Graphics (gimp, blender, inkscape)
  - Office (libreoffice)
  - Docker
  - Terminal tools
  - Multimedia
"
}

# ─── Main Menu ───────────────────────────────────────────────────────────
case "${1:-help}" in
    iso)
        build_minimal_iso
        build_postinstall
        ;;
    postinstall)
        build_postinstall
        ;;
    live)
        step "BUILDING LIVE USB IMAGE"
        if [ -f "$OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64.iso" ]; then
            cp "$OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64.iso" "$OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64-live.iso"
            success "Live USB image: $OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64-live.iso"
        else
            error "Build ISO first (make iso)"
            exit 1
        fi
        ;;
    vm)
        step "BUILDING VM IMAGES"
        mkdir -p "$OUTPUT_DIR/vms"
        
        if command -v VBoxManage &>/dev/null; then
            log "Creating VirtualBox image..."
            VBoxManage convertfromraw "$OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64.iso" \
                "$OUTPUT_DIR/vms/ShadowOS-2026.1-x86_64.vdi" --format VDI 2>&1 || true
            success "VirtualBox image created"
        fi
        
        if command -v qemu-img &>/dev/null; then
            log "Creating QEMU image..."
            qemu-img convert -f raw -O qcow2 \
                "$OUTPUT_DIR/iso/ShadowOS-2026.1-x86_64.iso" \
                "$OUTPUT_DIR/vms/ShadowOS-2026.1-x86_64.qcow2" 2>&1 || true
            success "QEMU image created"
        fi
        ;;
    container)
        step "BUILDING CONTAINER IMAGE"
        cat > "$BUILD_DIR/Dockerfile" << 'DOCKERFILE'
FROM kalilinux/kali-rolling
LABEL maintainer="ShadowOS Team <team@shadowos.local>"
LABEL description="ShadowOS Container - Cyberpunk Security OS"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh tmux git curl wget htop neovim vim fzf ripgrep \
    nmap nikto sqlmap metasploit-framework \
    tor torsocks nftables firejail \
    python3-pip && rm -rf /var/lib/apt/lists/*
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting
COPY config.sh /etc/shadowos/
COPY security-hardening/ /opt/ShadowOS/security-hardening/
COPY terminal-setup/ /etc/skel/.config/
EXPOSE 9050 9051 51820
CMD ["/bin/zsh"]
DOCKERFILE

        if command -v docker &>/dev/null; then
            docker build -t shadowos:2026.1 -f "$BUILD_DIR/Dockerfile" . 2>&1 | tee "$BUILD_DIR/container.log"
            success "Docker image: shadowos:2026.1"
        elif command -v podman &>/dev/null; then
            podman build -t shadowos:2026.1 -f "$BUILD_DIR/Dockerfile" . 2>&1 | tee "$BUILD_DIR/container.log"
            success "Podman image: shadowos:2026.1"
        else
            error "Neither Docker nor Podman available"
            exit 1
        fi
        ;;
    clean)
        step "CLEANING BUILD ARTIFACTS"
        rm -rf "$BUILD_DIR" "$OUTPUT_DIR" "$CACHE_DIR"
        success "Clean complete"
        ;;
    test)
        step "RUNNING TESTS"
        bash tests/run-tests.sh 2>&1 | tee "$BUILD_DIR/test.log"
        ;;
    docs)
        step "BUILDING DOCUMENTATION"
        bash documentation/build-docs.sh 2>&1 | tee "$BUILD_DIR/docs.log"
        ;;
    help|*)
        log "
ShadowOS Build Script - Staged Build Approach

Usage: $0 <command>

Commands:
  iso         Build minimal base ISO (STAGE 1)
  postinstall Show post-install instructions
  live        Create live USB image from ISO
  vm          Create VM images (VirtualBox, QEMU)
  container   Build container image
  clean       Remove build artifacts
  test        Run tests
  docs        Build documentation
  help        Show this help

STAGED BUILD APPROACH:
  STAGE 1: Minimal Base ISO
    - KDE desktop
    - Terminal (zsh, tmux)
    - Networking
    - Security base (nftables, apparmor, firejail)
    - Development tools (python3, build-essential)

  STAGE 2: Post-Install Tools (run after installation)
    - AI/ML (ollama, jupyter, torch)
    - Pentest (metasploit, burpsuite, nmap)
    - Graphics (gimp, blender, inkscape)
    - Office (libreoffice)
    - Docker
    - Terminal tools
    - Multimedia

This approach ensures:
  - Faster ISO build
  - Smaller ISO size
  - Better dependency resolution
  - More stable base system
"
        ;;
esac
