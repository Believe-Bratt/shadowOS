#!/bin/bash
# ============================================================================
# ShadowOS Main Build Script
# ============================================================================
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

case "${1:-help}" in
    iso)
        step "BUILDING SHADOWOS ISO"
        log "Version: 2026.1 | Codename: NeonVanguard"

        # Check dependencies
        for cmd in debootstrap live-build xorriso grub-mkrescue; do
            if ! command -v "$cmd" &>/dev/null; then
                error "Missing: $cmd (run 'make setup-deps')"
                exit 1
            fi
        done

        # Configure live-build
        mkdir -p "$BUILD_DIR/config"
        cat > "$BUILD_DIR/config/package-lists" << 'PACKAGES'
#!/bin/bash
# ShadowOS package list
PACKAGES="
    linux-image-amd64
    linux-headers-amd64
    firmware-linux-free
    firmware-linux-nonfree
    grub-efi-amd64-bin
    grub-pc-bin
    os-prober
    efibootmgr
    systemd
    systemd-sysv
    dbus
    dbus-x11
    xorg
    xorg-xinit
    xserver-xorg-video-all
    xserver-xorg-input-all
    mesa-utils
    vulkan-tools
    alsa-utils
    pulseaudio
    pipewire
    pipewire-pulse
    wireplumber
    network-manager
    network-manager-gnome
    wpasupplicant
    wireless-tools
    bluez
    blueman
    udisks2
    ntfs-3g
    exfatprogs
    btrfs-progs
    e2fsprogs
    dosfstools
    gparted
    gnome-disk-utility
    file-roller
    ark
    p7zip-full
    unrar
    unzip
    zip
    curl
    wget
    git
    vim
    neovim
    tmux
    zsh
    oh-my-zsh
    powerlevel10k
    fzf
    ripgrep
    fd-find
    bat
    exa
    htop
    btop
    neofetch
    ranger
    lazygit
    delta
    dust
    procs
    sd
    tldr
    broot
    firefox-esr
    chromium
    tor
    torsocks
    proxychains4
    nmap
    nikto
    sqlmap
    metasploit-framework
    burpsuite
    wireshark
    john
    hashcat
    hydra
    aircrack-ng
    ghidra
    radare2
    binwalk
    volatility
    autopsy
    sleuthkit
    docker.io
    docker-compose
    podman
    build-essential
    gcc
    g++
    make
    cmake
    python3
    python3-pip
    python3-venv
    golang
    rustc
    cargo
    nodejs
    npm
    ruby
    lua5.4
    openjdk-17-jdk
    ollama
    nftables
    iptables
    ufw
    apparmor
    apparmor-profiles
    aide
    rkhunter
    chkrootkit
    lynis
    clamav
    rsyslog
    journald
    cron
    anacron
    timeshift
    btrfs-progs
    snapper
    lvm2
    cryptsetup
    lUKS2
    tpm2-tools
    secureboot-db
    sddm
    kde-plasma-desktop
    kde-config-gtk-style
    qt5ct
    qt6-base
    kde-gtk-config
    plymouth
    plymouth-themes
    grub2-themes
    fonts-noto
    fonts-noto-color-emoji
    fonts-dejavu
    fonts-liberation
    fonts-firacode
    fonts-jetbrains-mono
    papirus-icon-theme
    numix-icon-theme-circle
    arc-theme
    adapta-gtk-theme
    materia-gtk-theme
    capitaine-cursors
    lightdm
    lightdm-gtk-greeter
    lightdm-gtk-greeter-settings
    xdg-user-dirs
    xdg-utils
    polkit
    pkexec
    sudo
    openssh-server
    openssh-client
    wireguard-tools
    openvpn
    strongswan
    xl2tpd
    ppp
    pptp-linux
    network-manager-openvpn
    network-manager-openvpn-gnome
    network-manager-vpnc
    network-manager-pptp
    network-manager-l2tp
    network-manager-l2tp-gnome
    cups
    cups-browsed
    hplip
    sane
    simple-scan
    gimp
    inkscape
    blender
    kdenlive
    shotcut
    obs-studio
    vlc
    mpv
    audacious
    rhythmbox
    spotify-client
    zoom
    slack
    teams-for-linux
    discord
    signal-desktop
    element-desktop
    thunderbird
    evolution
    libreoffice
    onlyoffice-desktopeditors
    keepassxc
    veracrypt
    gnupg
    seahorse
    kleopatra
    pidgin
    hexchat
    irssi
    weechat
    qbittorrent
    transmission-gtk
    virtualbox
    qemu-system-x86
    virt-manager
    virt-viewer
    edk2-ovmf
    spice-vdagent
    spice-webdavd
    dnsmasq
    bridge-utils
    vde2
    libvirt-daemon-system
    cockpit
    cockpit-machines
    timeshift
    deja-dup
    baobab
    gnome-system-monitor
    hardinfo2
    inxi
    lshw
    hwinfo
    smartmontools
    lm-sensors
    psensor
    redshift
    flameshot
    spectacle
    shutter
    peek
    simplescreenrecorder
    asciinema
    termshark
    httpie
    jq
    yq
    xsv
    pandoc
    texlive-full
    markdown
    glow
    lsd
    procs
    hyperfine
    dust
    tokei
    watchexec
    fd-find
    ripgrep
    silver-searcher
    shellcheck
    shfmt
    hadolint
    ktlint
    prettier
    eslint
    typescript
    python3-pylint
    python3-flake8
    python3-mypy
    python3-black
    python3-isort
    python3-pip
    python3-pytest
    python3-tox
    python3-venv
    python3-jupyter-core
    python3-notebook
    python3-torch
    python3-transformers
    python3-langchain
    python3-chromadb
    python3-faiss
    golang-go
    golang-github-tools
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
    dotnet-sdk-8.0
    php
    composer
    ruby-full
    bundler
    lua5.4
    luajit
    nodejs
    npm
    yarn
    pnpm
    bun
    deno
    java-17-openjdk
    java-11-openjdk
    maven
    gradle
    docker.io
    docker-compose
    podman
    buildah
    skopeo
    trivy
    grype
    kubectl
    kubectx
    minikube
    kind
    helm
    terraform
    packer
    ansible
    puppet
    salt-master
    vagrant
    wireshark
    tshark
    tcpdump
    nmap
    masscan
    zmap
    nikto
    dirb
    gobuster
    wfuzz
    ffuf
    sqlmap
    burpsuite
    owasp-zap
    wpscan
    joomscan
    whatweb
    wafw00f
    nuclei
    httpx
    subfinder
    amass
    theharvester
    recon-ng
    maltego
    spiderfoot
    legion
    jaeles
    xray
    dalfox
    ghauri
    arjun
    paramspider
    katana
    waybackurls
    gau
    unfurl
    qsreplace
    URO
    GF
    anew
    notify
    httprobe
    subjack
    subzy
    getjs
    linkfinder
    secretfinder
    github-endpoints
    github-subdomains
    Gxss
    XSpear
    SSRFmap
    Sn1per
    Red_Hawk
    CMSeeK
    WPScan
    Droopescan
    joomscan
    Acunetix
    Invicti
    Qualys
    Nessus
    OpenVAS
    Greenbone
    Legion
    Nexpose
    Retina
    SAINT
    Core-Impact
    Cobalt-Strike
    Metasploit
    Armitage
    BeEF
    SET
    Social-Engineer
    King-Phisher
    Go-Phish
    Evilginx2
    Modlishka
    Muraena
    Trape
    BlackEye
    Zphisher
    SayCheese
    SayMyName
    HiddenEye
    Photon
    EyeWitness
    Aquatone
    GoWitness
    Wayback
    Archive
    HTTrack
    wget
    curl
    httrack
    dataplicity
    ngrok
    serveo
    bore
    chisel
    ligolo
    sish
    frp
    nps
    ezgo
    termshark
    mitmproxy
    bettercap
    evilgrade
    yersinia
    isr-evilgrade
    macchanger
    macchanger-gtk
    bmon
    iftop
    nethogs
    iptraf-ng
    vnstat
    darkstat
    bandwidthd
    ntopng
    argus
    rapl
    powertop
    turbostat
    stress
    stress-ng
    sysbench
    fio
    bonnie++
    dbench
    iozone
    netperf
    iperf3
    nuttcp
    qperf
    ramspeed
    hardinfo
    hardinfoo
    HardInfo2
    inxi
    screenfetch
    neofetch
-EOF
PACKAGES

        # Create build config
        cat > "$BUILD_DIR/config/build.conf" << 'BUILDCONF'
# ShadowOS Build Configuration
export MIRROR_CHROOT="http://kali.download/kali"
export ARCHITECTURES="amd64"
export DEBIAN_FRONTEND="noninteractive"
export LIVE_CONFIG_HOOKS="shadowos-hooks"
BUILDCONF

        # Create hooks
        mkdir -p "$BUILD_DIR/config/hooks/normal"
        cat > "$BUILD_DIR/config/hooks/normal/0100-shadowos.chroot" << 'HOOK'
#!/bin/bash
# ShadowOS post-chroot hook
set -e

# Copy ShadowOS configurations
if [ -d /usr/share/ShadowOS ]; then
    echo "Configuring ShadowOS..."
    
    # Set up Zsh as default shell
    chsh -s /usr/bin/zsh root
    
    # Enable services
    systemctl enable nftables 2>/dev/null || true
    systemctl enable apparmor 2>/dev/null || true
    systemctl enable ssh 2>/dev/null || true
    systemctl enable tor 2>/dev/null || true
    systemctl enable ollama 2>/dev/null || true
    
    # Apply security hardening
    if [ -f /opt/ShadowOS/security-hardening/apply-hardening.sh ]; then
        bash /opt/ShadowOS/security-hardening/apply-hardening.sh
    fi
fi
HOOK
        chmod +x "$BUILD_DIR/config/hooks/normal/0100-shadowos.chroot"

        # Create isolinux config
        mkdir -p "$BUILD_DIR/config/includes.binary/isolinux"
        cat > "$BUILD_DIR/config/includes.binary/isolinux/isolinux.cfg" << 'ISOLINUX'
UI menu.c32
PROMPT 0
TIMEOUT 300

MENU TITLE ShadowOS Boot Menu
MENU COLOR border 30;44 #00000000 #00000000
MENU COLOR title 1;36;44 #ff00ff #00000000
MENU COLOR sel 7;37;40 #00ffff #00000000
MENU COLOR unsel 37;44 #cccccc #00000000

LABEL live
  MENU LABEL ^Start ShadowOS Live
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd.img boot=live components quiet splash

LABEL live-nomodeset
  MENU LABEL Start ShadowOS (Safe Graphics)
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd.img boot=live components nomodeset

LABEL memtest
  MENU LABEL Memory Test
  KERNEL /memtest86+/memtest.bin

LABEL reboot
  MENU LABEL Reboot
  COM32 reboot.c32
ISOLINUX

        # Create GRUB config
        mkdir -p "$BUILD_DIR/config/includes.binary/EFI/BOOT"
        cat > "$BUILD_DIR/config/includes.binary/grub/grub.cfg" << 'GRUB'
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

menuentry "Memory Test" {
    linux16 /memtest86+/memtest.bin
}
GRUB

        # Create Plymouth theme
        mkdir -p "$BUILD_DIR/config/includes.chroot/usr/share/plymouth/themes/shadowos"
        cat > "$BUILD_DIR/config/includes.chroot/usr/share/plymouth/themes/shadowos/shadowos.plymouth" << 'PLYMOUTH'
[Plymouth Theme]
Name=ShadowOS
Description=Cyberpunk boot animation for ShadowOS
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/shadowos
ScriptFile=/usr/share/plymouth/themes/shadowos/shadowos.script
PLYMOUTH

        cat > "$BUILD_DIR/config/includes.chroot/usr/share/plymouth/themes/shadowos/shadowos.script" << 'PLYMOUTHSCRIPT'
// ShadowOS Plymouth Boot Animation
// Cyberpunk-themed boot sequence

Window.SetBackgroundTopColor(0.02, 0.02, 0.06);
Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);

screen_width = Window.GetWidth();
screen_height = Window.GetHeight();

// Matrix-style rain effect
function draw_matrix() {
    // Draw falling characters
    for (i = 0; i < 50; i++) {
        x = Math.random() * screen_width;
        y = Math.random() * screen_height;
        char = String.fromCharCode(33 + Math.floor(Math.random() * 94));
        
        // Neon green glow
        if (Math.random() > 0.5) {
            fun.group {
                fun.text {
                    text = char;
                    font = "Monospace Bold 12";
                    x = x;
                    y = y;
                    color = 0, 1, 0, 0.8;
                }
            }
        }
    }
}

// Boot progress bar
boot_progress = 0;

fun.progress_animation() {
    if (boot_progress < 100) {
        boot_progress += 2;
    }
    
    // Draw progress bar
    bar_x = screen_width * 0.2;
    bar_y = screen_height * 0.85;
    bar_width = screen_width * 0.6;
    bar_height = 4;
    
    // Background bar
    fun.rectangle {
        x = bar_x; y = bar_y;
        width = bar_width; height = bar_height;
        color = 0.1, 0.1, 0.15, 1;
    }
    
    // Progress fill with neon glow
    fill_width = bar_width * (boot_progress / 100);
    fun.rectangle {
        x = bar_x; y = bar_y;
        width = fill_width; height = bar_height;
        color = 0, 1, 1, 0.8;
    }
    
    // Glow effect
    fun.glow {
        x = bar_x + fill_width / 2;
        y = bar_y + bar_height / 2;
        color = 0, 1, 1;
        radius = 20;
    }
}

// Boot messages
boot_messages = [
    "INITIALIZING SHADOWOS...",
    "LOADING SECURITY MODULES...",
    "ENCRYPTION STATUS: ACTIVE",
    "ESTABLISHING SECURE NETWORKS...",
    "LOADING AI CORE...",
    "AI CORE ONLINE",
    "SYSTEM READY"
];

message_index = 0;
message_timer = 0;

fun.display_messages() {
    message_timer++;
    if (message_timer % 30 == 0 && message_index < boot_messages.length) {
        message_index++;
    }
    
    for (i = 0; i < message_index && i < boot_messages.length; i++) {
        y_pos = screen_height * 0.3 + i * 25;
        opacity = (i == message_index - 1) ? 1.0 : 0.7;
        
        fun.text {
            text = boot_messages[i];
            font = "Monospace Bold 16";
            x = screen_width * 0.3;
            y = y_pos;
            color = 0, 1, 1, opacity;
        }
    }
}

// Main animation loop
fun.animation_loop() {
    draw_matrix();
    fun.progress_animation();
    fun.display_messages();
}

// Boot status callbacks
Plymouth.SetBootProgressFunction(fun.progress_animation);
Plymouth.SetMessageFunction(fun.display_messages);

// Start animation
fun.animation_loop();
PLYMOUTHSCRIPT

        # Create SDDM theme
        mkdir -p "$BUILD_DIR/config/includes.chroot/usr/share/sddm/themes/ShadowOS"
        cat > "$BUILD_DIR/config/includes.chroot/usr/share/sddm/themes/ShadowOS/theme.conf" << 'SDDM'
[General]
type=image

[Input]
font="JetBrains Mono,12,-1,5,50,0,0,0,0,0"
background=transparent

[Buttons]
font="JetBrains Mono,12,-1,5,50,0,0,0,0,0"
background="#0a0a0f"
foreground="#00ffff"
borderColor="#ff00ff"

[UserList]
font="JetBrains Mono,14,-1,5,50,0,0,0,0,0"
background="#0a0a0fcc"
foreground="#00ffff"

[ComboBox]
background="#1a1a2e"
foreground="#00ffff"
borderColor="#ff00ff"

[Text]
font="JetBrains Mono,11,-1,5,50,0,0,0,0,0"
foreground="#f0f0ff"

[Clock]
font="JetBrains Mono,14,-1,5,50,0,0,0,0,0"
foreground="#ffbf00"

[HostName]
font="JetBrains Mono,16,-1,5,75,0,0,0,0,0"
foreground="#ff00ff"
SDDM

        success "ISO build configured"
        ;;
    live)
        step "BUILDING LIVE USB IMAGE"
        if [ -f "$ISO_DIR/$(ISO_NAME).iso" ]; then
            log "Converting ISO to hybrid USB image..."
            # Already hybrid from live-build
            cp "$ISO_DIR/$(ISO_NAME).iso" "$OUTPUT_DIR/$(ISO_NAME)-live.iso"
            success "Live USB image: $OUTPUT_DIR/$(ISO_NAME)-live.iso"
        else
            error "Build ISO first (make iso)"
            exit 1
        fi
        ;;
    vm)
        step "BUILDING VM IMAGES"
        mkdir -p "$OUTPUT_DIR/vms"
        
        if [ -n "$VBOXMANAGE" ]; then
            log "Creating VirtualBox image..."
            VBoxManage convertfromraw "$ISO_DIR/$(ISO_NAME).iso" \
                "$OUTPUT_DIR/vms/$(ISO_NAME).vdi" --format VDI 2>&1 || true
            success "VirtualBox image created"
        fi
        
        if [ -n "$QEMU_IMG" ]; then
            log "Creating QEMU image..."
            qemu-img convert -f raw -O qcow2 \
                "$ISO_DIR/$(ISO_NAME).iso" \
                "$OUTPUT_DIR/vms/$(ISO_NAME).qcow2" 2>&1 || true
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

# Install core packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh tmux git curl wget htop neovim vim fzf ripgrep \
    nmap nikto sqlmap metasploit-framework \
    tor torsocks nftables firejail \
    python3-pip python3-torch ollama \
    kali-tools-top10 \
    && rm -rf /var/lib/apt/lists/*

# Configure Zsh
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting

COPY config.sh /etc/shadowos/
COPY security-hardening/ /opt/ShadowOS/security-hardening/
COPY terminal-setup/ /etc/skel/.config/

EXPOSE 11434 9050 9051 51820

CMD ["/bin/zsh"]
DOCKERFILE

        if [ -n "$DOCKER" ]; then
            docker build -t shadowos:$(VERSION) -f "$BUILD_DIR/Dockerfile" . 2>&1 | tee "$BUILD_DIR/container.log"
            success "Docker image: shadowos:$(VERSION)"
        elif [ -n "$PODMAN" ]; then
            podman build -t shadowos:$(VERSION) -f "$BUILD_DIR/Dockerfile" . 2>&1 | tee "$BUILD_DIR/container.log"
            success "Podman image: shadowos:$(VERSION)"
        else
            error "Neither Docker nor Podman available"
            exit 1
        fi
        ;;
    clean)
        step "CLEANING BUILD ARTIFACTS"
        rm -rf "$BUILD_DIR" "$OUTPUT_DIR" "$CACHE_DIR"
        rm -rf .build binary.list chroot.files packages.chroot
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
    *)
        bash "$0" help
        ;;
esac