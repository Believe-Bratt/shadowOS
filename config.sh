# ShadowOS Configuration
# Global configuration for the ShadowOS build system
# Updated for v2026.2 "NeonHorizon"

PROJECT_NAME="ShadowOS"
PROJECT_VERSION="2026.2"
PROJECT_CODENAME="NeonHorizon"
PROJECT_DESCRIPTION="Cyberpunk-themed penetration testing OS with AI integration"

# ─── Base System ────────────────────────────────────────────────────────────
BASE_DISTRIBUTION="kali"
BASE_VERSION="rolling-2025"
KERNEL_VERSION="6.9.x"
KERNEL_FLAVOUR="hardened"
ARCHITECTURES="amd64 arm64"

# ─── Build System ───────────────────────────────────────────────────────────
BUILD_DIR="build"
OUTPUT_DIR="output"
CACHE_DIR="cache"
REPO_NAME="shadowos"
REPO_MAINTAINER="ShadowOS Team <team@shadowos.local>"
REPO_SIGN_KEY="shadowos-keyring"

# ─── Color Palette ──────────────────────────────────────────────────────────
COLOR_NEON_CYAN="#00FFFF"
COLOR_NEON_MAGENTA="#FF00FF"
COLOR_NEON_AMBER="#FFBF00"
COLOR_NEON_GREEN="#00FF88"
COLOR_NEON_RED="#FF0055"
COLOR_BACKGROUND="#0A0A0F"
COLOR_FOREGROUND="#F0F0FF"
COLOR_ACCENT="${COLOR_NEON_CYAN}"

# ─── Default Desktop ────────────────────────────────────────────────────────
DEFAULT_DE="kde-plasma"
DEFAULT_TERMINAL="alacritty"
DEFAULT_SHELL="zsh"

# ─── AI Runtime ─────────────────────────────────────────────────────────────
AI_RUNTIME="ollama"
# Updated models: Llama 3.2, Gemma 2, Mixtral, CodeLlama 2.0
DEFAULT_AI_MODELS="llama3.2:8b,gemma2:9b,mixtral:8x7b,codeLlama:7b,pentestGPT:latest,llama3.1:8b,phi3:mini"
DEFAULT_AI_MODEL="llama3.2:8b"

# ─── Security ───────────────────────────────────────────────────────────────
SECURITY_PROFILE="maximum"
ENCRYPTION_DEFAULT="luks2"
FIREWALL_DEFAULT="nftables"
SSH_PORT="2222"
SSH_HARDENING="true"

# ─── Build Options ──────────────────────────────────────────────────────────
BUILD_ISO="true"
BUILD_LIVE="true"
BUILD_VM="true"
BUILD_CONTAINER="true"
BUILD_FLATPAK="true"

# ─── Feature Flags ──────────────────────────────────────────────────────────
DEFAULT_TOR="false"
DEFAULT_VPN="false"
DNS_OVER_HTTPS="true"
DNS_OVER_HTTPS_PROVIDER="cloudflare"  # cloudflare, quad9, google
INCLUDE_DEV_TOOLS="true"
INCLUDE_AI_TOOLS="true"
INCLUDE_PENTEST_TOOLS="true"
INCLUDE_GAMING="false"
INCLUDE_MULTIMEDIA="false"
INCLUDE_OFFICE="true"
BUILD_DOCS="true"
DOCS_FORMATS="html pdf dash"
RUN_TESTS="true"
TEST_SUITE="basic"
RELEASE_TYPE="stable"
SIGN_RELEASES="true"

# ─── Performance ────────────────────────────────────────────────────────────
ENABLE_ZRAM="true"
ZRAM_SIZE="512M"
ENABLE_ZSWAP="true"
BTRFS_COMPRESSION="zstd"
ENABLE_TRIM="true"

# ─── Privacy ────────────────────────────────────────────────────────────────
ENABLE_MAC_RANDOMIZATION="true"
ENABLE_KILL_SWITCH="true"
DNSSEC_VALIDATE="true"
BLOCK_GEOIP="false"
GEOIP_BLOCK_COUNTRIES="CN,RU"
