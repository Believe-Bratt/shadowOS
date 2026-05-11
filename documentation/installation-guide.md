# ShadowOS Installation Guide

> **Version:** 2026.1 | **Codename:** NeonVanguard

## System Requirements

| Component | Minimum | Recommended | AI Workstation |
|-----------|---------|-------------|----------------|
| CPU | 2 cores | 4+ cores | 8+ cores (Threadripper/Xeon) |
| RAM | 4 GB | 16 GB | 64-128 GB |
| Storage | 20 GB SSD | 500 GB NVMe | 2 TB NVMe |
| GPU | Any | NVIDIA/AMD | Dual RTX 4090 |
| Network | Ethernet/WiFi | Gigabit+ | 10 GbE |

## Installation Methods

### Method 1: Pre-built ISO (Recommended)

```bash
# Download the latest ISO from ShadowOS releases
# Or build your own: make iso (see Makefile)

# Write to USB (Linux)
dd if=ShadowOS-2026.1-amd64.iso of=/dev/sdX bs=4M status=progress
sync

# Write to USB (Windows)
# Use Rufus or Etcher with DD mode

# Boot from USB and select "Start ShadowOS Live"
```

### Method 2: Install on Existing Kali Linux

```bash
# Clone this repository
git clone https://github.com/shadowos/shadowos.git
cd shadowos

# Run the post-install script
sudo bash scripts/post-install.sh

# Reboot
sudo reboot
```

### Method 3: Install on Existing Debian/Ubuntu

```bash
# Add Kali repositories (optional, for pentest tools)
echo "deb http://http.kali.org/kali kali-rolling main non-free non-free-firmware contrib" | sudo tee /etc/apt/sources.list.d/kali.list

# Run ShadowOS setup
sudo bash scripts/post-install.sh
```

### Method 4: Virtual Machine

```bash
# Using the provided VM images
# Available in output/vms/ after build

# Or create manually:
# VirtualBox
VBoxManage createvm --name "ShadowOS" --ostype "Debian_64" --register
VBoxManage modifyvm "ShadowOS" --memory 4096 --cpus 4 --vram 128
VBoxManage storagectl "ShadowOS" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "ShadowOS" --storagectl "SATA" --port 0 --device 0 --type dvddrive --medium ShadowOS.iso
VBoxManage startvm "ShadowOS"

# QEMU/KVM
qemu-system-x86_64 -enable-kvm -m 4096 -cpu host \
    -drive file=ShadowOS.qcow2,format=qcow2 \
    -cdrom ShadowOS.iso \
    -vga virtio
```

### Method 5: Docker/Podman Container

```bash
# Pull the container image
docker pull shadowos:2026.1

# Or build from source
docker build -t shadowos:local .

# Run with full privileges
docker run -it --privileged --rm \
    -v /dev:/dev \
    -v /sys:/sys \
    -v /tmp:/tmp \
    shadowos:local
```

## Post-Installation

### First Boot Checklist

1. **Update the system:**
   ```bash
   sudo apt update && sudo apt full-upgrade -y
   ```

2. **Set up encryption (if not done during install):**
   ```bash
   # Enable full-disk encryption with LUKS2
   sudo cryptsetup luksFormat /dev/sdX
   sudo cryptsetup open /dev/sdX shadowos_encrypted
   ```

3. **Configure your user:**
   ```bash
   # Zsh is set as default shell
   # Powerlevel10k will run its configuration wizard on first launch
   zsh
   ```

4. **Start AI services:**
   ```bash
   # Start Ollama
   ai-start
   
   # Pull models
   ollama pull llama3.1:8b
   ollama pull codellama:7b
   ```

5. **Configure privacy:**
   ```bash
   # Set up full privacy stack
   sudo bash system-services/tor-privacy.sh all
   ```

6. **Apply security hardening:**
   ```bash
   sudo bash security-hardening/apply-hardening.sh
   ```

7. **Configure desktop environment:**
   ```bash
   # For Hyprland
   bash desktop-environments/hyprland/setup.sh
   
   # For KDE Plasma
   bash desktop-environments/kde/setup.sh
   ```

### Verify Installation

```bash
# Check system status
shadowos-status

# Check AI integration
ai "Hello, ShadowOS!"

# Check security
sudo lynis audit system

# Check network privacy
tor-privacy.sh status
```

## Uninstalling / Returning to Stock

```bash
# Remove ShadowOS configurations
sudo bash scripts/uninstall.sh 2>/dev/null || true

# Remove packages
sudo apt remove --purge shadowos-* zsh tmux neovim 2>/dev/null || true

# Restore default shell
chsh -s /bin/bash $USER

# Remove Oh My Zsh
rm -rf ~/.oh-my-zsh
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Black screen on boot | Add `nomodeset` to GRUB boot options |
| No network after install | `sudo systemctl restart NetworkManager` |
| Zsh not default | `chsh -s /usr/bin/zsh $USER` |
| Ollama not responding | `sudo systemctl start ollama` or `ollama serve` |
| Tor not working | `sudo systemctl start tor` |
| GUI not loading | `sudo systemctl start sddm` or `startplasma-wayland` |
| Low disk space | `sudo apt autoremove && sudo journalctl --vacuum-size=100M` |