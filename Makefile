# ============================================================================
# ShadowOS Build System
# ============================================================================
# Usage:
#   make iso          — Build ShadowOS ISO image
#   make vm           — Build VM images (VirtualBox, QEMU)
#   make container    — Build Docker/Podman container
#   make live         — Build live USB image
#   make clean        — Clean build artifacts
#   make test         — Run test suite
#   make docs         — Build documentation
#   make all          — Build everything
# ============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

# ─── Configuration ──────────────────────────────────────────────────────
PROJECT_NAME    := ShadowOS
VERSION         := 2026.1
CODENAME        := BelieveTeckk
BUILD_DIR       := build
OUTPUT_DIR      := output
CACHE_DIR       := cache
WORK_DIR        := $(shell pwd)

# ISO settings
ISO_NAME        := $(PROJECT_NAME)-$(VERSION)-$(shell uname -m)
ISO_DIR         := $(OUTPUT_DIR)/iso
LIVE_DIR        := $(BUILD_DIR)/live
ROOTFS_DIR      := $(LIVE_DIR)/rootfs

# Colors
RED     := \033[0;31m
GREEN   := \033[0;32m
CYAN    := \033[0;36m
YELLOW  := \033[1;33m
BOLD    := \033[1m
NC      := \033[0m

# Detect package manager
ifeq ($(shell command -v apt 2>/dev/null),)
  ifeq ($(shell command -v pacman 2>/dev/null),)
    $(error No supported package manager found)
  else
    PKG_MANAGER := pacman
  endif
else
  PKG_MANAGER := apt
endif

# Detect build tools
LIVE_BUILD     := $(shell command -v lb 2>/dev/null || echo "")
MKISOFS        := $(shell command -v mkisofs 2>/dev/null || command -v genisoimage 2>/dev/null || echo "")
QEMU_IMG       := $(shell command -v qemu-img 2>/dev/null || echo "")
VBOXMANAGE     := $(shell command -v VBoxManage 2>/dev/null || echo "")
DOCKER         := $(shell command -v docker 2>/dev/null || echo "")
PODMAN         := $(shell command -v podman 2>/dev/null || echo "")

.PHONY: all iso vm container live clean test docs help setup-deps

# ─── Default Target ─────────────────────────────────────────────────────
help:
	@echo ""
	@echo -e "$(BOLD)$(CYAN)╔══════════════════════════════════════════════════╗$(NC)"
	@echo -e "$(BOLD)$(CYAN)║  $(BOLD)ShadowOS Build System v$(VERSION)$(CYAN)              ║$(NC)"
	@echo -e "$(BOLD)$(CYAN)╚══════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo -e "  $(GREEN)Targets:$(NC)"
	@echo -e "    $(BOLD)make iso$(NC)       — Build ShadowOS ISO image"
	@echo -e "    $(BOLD)make live$(NC)      — Build live USB image"
	@echo -e "    $(BOLD)make vm$(NC)        — Build VM images (VirtualBox + QEMU)"
	@echo -e "    $(BOLD)make container$(NC) — Build Docker/Podman container"
	@echo -e "    $(BOLD)make clean$(NC)     — Clean build artifacts"
	@echo -e "    $(BOLD)make test$(NC)      — Run test suite"
	@echo -e "    $(BOLD)make docs$(NC)      — Build documentation"
	@echo -e "    $(BOLD)make all$(NC)       — Build everything"
	@echo -e "    $(BOLD)make setup-deps$(NC) — Install build dependencies"
	@echo ""
	@echo -e "  $(YELLOW)Detected:$(NC)"
	@echo -e "    Package manager: $(PKG_MANAGER)"
	@echo -e "    Live-build:      $(if $(LIVE_BUILD),found,not found)"
	@echo -e "    mkisofs:         $(if $(MKISOFS),found,not found)"
	@echo -e "    QEMU:            $(if $(QEMU_IMG),found,not found)"
	@echo -e "    VirtualBox:      $(if $(VBOXMANAGE),found,not found)"
	@echo -e "    Docker:          $(if $(DOCKER),found,not found)"
	@echo ""

# ─── Setup Dependencies ─────────────────────────────────────────────────
setup-deps:
	@echo -e "$(CYAN)Installing build dependencies...$(NC)"
ifeq ($(PKG_MANAGER),apt)
	sudo apt update
	sudo apt install -y live-build debootstrap syslinux isolinux \
		xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools \
		qemu-utils virtualbox genisoimage curl wget git \
		squashfs-tools extlinux \
		linux-headers-$(uname -r) 2>/dev/null || \
		sudo apt install -y linux-headers-amd64 2>/dev/null || true
	sudo modprobe vboxhost 2>/dev/null || true
	sudo /sbin/vboxconfig 2>/dev/null || true
else ifeq ($(PKG_MANAGER),pacman)
	sudo pacman -S --noconfirm --needed \
		live-build debootstrap syslinux \
		grub dosfstools mtools xorriso \
		qemu-full virtualbox git \
		squashfs-tools \
		linux-headers 2>/dev/null || true
	sudo modprobe vboxhost 2>/dev/null || true
	sudo /sbin/vboxconfig 2>/dev/null || true
endif
	@echo -e "$(GREEN)✓ Build dependencies installed$(NC)"

# ─── ISO Build ──────────────────────────────────────────────────────────
iso: $(ISO_DIR)/$(ISO_NAME).iso

$(ISO_DIR)/$(ISO_NAME).iso: setup-deps
	@echo -e "$(CYAN)Building ShadowOS ISO...$(NC)"
	@mkdir -p $(ISO_DIR) $(LIVE_DIR)
	@bash build-system/build.sh iso 2>&1 | tee $(BUILD_DIR)/build.log
	@if [ -f $(LIVE_DIR)/binary.hybrid.iso ]; then \
		cp $(LIVE_DIR)/binary.hybrid.iso $@; \
		echo -e "$(GREEN)✓ ISO created: $@$(NC)"; \
		ls -lh $@; \
	else \
		echo -e "$(RED)✗ ISO build failed. Check $(BUILD_DIR)/build.log$(NC)"; \
		exit 1; \
	fi

# ─── Live USB Image ─────────────────────────────────────────────────────
live: iso
	@echo -e "$(CYAN)Creating live USB image...$(NC)"
	@bash build-system/build.sh live
	@echo -e "$(GREEN)✓ Live USB image ready in $(OUTPUT_DIR)/$(NC)"

# ─── VM Images ──────────────────────────────────────────────────────────
vm: iso
	@echo -e "$(CYAN)Building VM images...$(NC)"
	@bash build-system/build.sh vm
	@echo -e "$(GREEN)✓ VM images ready in $(OUTPUT_DIR)/vms/$(NC)"

# ─── Container Image ────────────────────────────────────────────────────
container:
	@echo -e "$(CYAN)Building container image...$(NC)"
	@bash build-system/build.sh container
	@echo -e "$(GREEN)✓ Container image built$(NC)"

# ─── Clean ──────────────────────────────────────────────────────────────
clean:
	@echo -e "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(OUTPUT_DIR)
	@rm -rf $(CACHE_DIR)
	@rm -rf .build
	@rm -rf binary.list chroot.files packages.chroot
	@rm -rf chroot binary tmp
	@rm -rf build-system/cache/*
	@rm -rf ~/.cache/live-build
	@rm -rf ~/.local/share/live-build
	@sudo rm -rf /var/cache/live-build 2>/dev/null || true
	@sudo rm -rf /var/lib/live-build 2>/dev/null || true
	@sudo rm -rf /var/tmp/live-build 2>/dev/null || true
	@echo -e "$(GREEN)✓ Clean complete$(NC)"

# ─── Test Suite ─────────────────────────────────────────────────────────
test:
	@echo -e "$(CYAN)Running ShadowOS test suite...$(NC)"
	@bash tests/run-tests.sh 2>&1 | tee $(BUILD_DIR)/test.log
	@echo -e "$(GREEN)✓ Tests complete$(NC)"

# ─── Documentation ──────────────────────────────────────────────────────
docs:
	@echo -e "$(CYAN)Building documentation...$(NC)"
	@bash documentation/build-docs.sh 2>&1 | tee $(BUILD_DIR)/docs.log
	@echo -e "$(GREEN)✓ Documentation built in documentation/output/$(NC)"

# ─── UI Themes ────────────────────────────────────────────────────────────
ui-themes:
	@echo -e "$(CYAN)Installing ShadowOS Cyberpunk UI Themes...$(NC)"
	@bash cyberpunk-theme/install-theme.sh
	@echo -e "$(GREEN)✓ UI themes installed$(NC)"

ui-themes-system: ui-themes
	@echo -e "$(CYAN)Applying system-wide theme settings...$(NC)"
	@sudo ln -sf /usr/share/themes/ShadowOS-Dark /usr/share/themes/Default
	@sudo ln -sf /usr/share/icons/ShadowOS /usr/share/icons/default
	@echo -e "$(GREEN)✓ System defaults updated$(NC)"

# ─── Full Build ─────────────────────────────────────────────────────────
all: iso vm container
	@echo -e "$(GREEN)"
	@echo -e "$(BOLD)══════════════════════════════════════════════════$(NC)"
	@echo -e "$(BOLD)  ✓ ShadowOS $(VERSION) ($(CODENAME)) Build Complete$(NC)"
	@echo -e "$(BOLD)══════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo -e "  Outputs:"
	@echo -e "    ISO:     $(ISO_DIR)/$(ISO_NAME).iso"
	@echo -e "    VMs:     $(OUTPUT_DIR)/vms/"
	@echo -e "    Container: $(OUTPUT_DIR)/container/"
	@echo ""