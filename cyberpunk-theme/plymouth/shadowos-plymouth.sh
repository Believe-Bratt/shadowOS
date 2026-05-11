#!/bin/bash
# ============================================================================
# ShadowOS Plymouth Boot Theme Installer
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'

PLYMOUTH_DIR="/usr/share/plymouth/themes/shadowos"
mkdir -p "$PLYMOUTH_DIR"

# ─── Install Plymouth Theme ─────────────────────────────────────────────
cat > "$PLYMOUTH_DIR/shadowos.plymouth" << 'PLYMOUTH'
[Plymouth Theme]
Name=ShadowOS
Description=Cyberpunk boot animation for ShadowOS
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/shadowos
ScriptFile=/usr/share/plymouth/themes/shadowos/shadowos.script
PLYMOUTH

# ─── Plymouth Boot Script ───────────────────────────────────────────────
cat > "$PLYMOUTH_DIR/shadowos.script" << 'PLYMOUTHSCRIPT'
// ShadowOS Plymouth Boot Animation
// Cyberpunk-themed boot sequence with matrix rain and neon effects

Window.SetBackgroundTopColor(0.02, 0.02, 0.06);
Window.SetBackgroundBottomColor(0.0, 0.0, 0.0);

screen_width = Window.GetWidth();
screen_height = Window.GetHeight();

// ─── Matrix-style Rain Effect ──────────────────────────────────────────
char_count = 80;
char_speed = array();
char_y = array();
char_x = array();
char_val = array();

for (i = 0; i < char_count; i++) {
    char_speed[i] = 0.02 + Math.random() * 0.03;
    char_y[i] = Math.random() * screen_height;
    char_x[i] = Math.random() * screen_width;
    char_val[i] = String.fromCharCode(33 + Math.floor(Math.random() * 94));
}

function draw_matrix() {
    for (i = 0; i < char_count; i++) {
        char_y[i] += char_speed[i] * screen_height * 0.01;
        if (char_y[i] > screen_height) {
            char_y[i] = 0;
            char_x[i] = Math.random() * screen_width;
            char_val[i] = String.fromCharCode(33 + Math.floor(Math.random() * 94));
        }
        
        // Neon green characters with glow
        fun.text {
            text = char_val[i];
            font = "Monospace Bold 11";
            x = char_x[i];
            y = char_y[i];
            color = 0, 1, 0, 0.6;
        }
    }
}

// ─── Hexagonal Grid Background ─────────────────────────────────────────
function draw_hex_grid() {
    grid_size = 40;
    for (row = 0; row < screen_height / grid_size + 1; row++) {
        for (col = 0; col < screen_width / grid_size + 1; col++) {
            x = col * grid_size * 1.5;
            y = row * grid_size + (col % 2) * (grid_size / 2);
            
            fun.rectangle {
                x = x; y = y;
                width = grid_size - 2; height = grid_size - 2;
                color = 0.03, 0.03, 0.06, 0.3;
            }
        }
    }
}

// ─── Boot Progress Bar ─────────────────────────────────────────────────
boot_progress = 0;
target_progress = 0;

function update_progress() {
    if (boot_progress < target_progress) {
        boot_progress += (target_progress - boot_progress) * 0.05;
    }
}

function draw_progress_bar() {
    bar_x = screen_width * 0.15;
    bar_y = screen_height * 0.82;
    bar_width = screen_width * 0.7;
    bar_height = 6;
    
    // Outer glow
    fun.glow {
        x = bar_x + bar_width / 2;
        y = bar_y + bar_height / 2;
        color = 0, 1, 1;
        radius = 30;
    }
    
    // Background bar
    fun.rectangle {
        x = bar_x; y = bar_y;
        width = bar_width; height = bar_height;
        color = 0.05, 0.05, 0.1, 0.9;
    }
    
    // Neon fill
    fill_width = bar_width * (boot_progress / 100);
    fun.rectangle {
        x = bar_x; y = bar_y;
        width = fill_width; height = bar_height;
        color = 0, 0.8, 0.8, 0.9;
    }
    
    // Edge glow
    if (fill_width > 0) {
        fun.glow {
            x = bar_x + fill_width;
            y = bar_y + bar_height / 2;
            color = 0, 1, 1;
            radius = 10;
        }
    }
}

// ─── Boot Messages ─────────────────────────────────────────────────────
boot_messages = [
    "▌ INITIALIZING SHADOWOS v2026.1...",
    "▌ LOADING KERNEL MODULES...",
    "▌ VERIFYING SYSTEM INTEGRITY...",
    "▌ DECRYPTING ROOT FILESYSTEM...",
    "▌ ENCRYPTION STATUS: ██ ACTIVE",
    "▌ LOADING SECURITY MODULES...",
    "▌ ██ FIREWALL: nftables [ACTIVE]",
    "▌ ██ APP ARMOR: [ENFORCING]",
    "▌ ESTABLISHING SECURE NETWORKS...",
    "▌ ██ TOR ROUTING: [READY]",
    "▌ ██ VPN: [STANDBY]",
    "▌ INITIALIZING AI SUBSYSTEM...",
    "▌ ██ OLLAMA ENGINE: [LOADING]",
    "▌ ██ NEURAL NETWORK: [ONLINE]",
    "▌ AI CORE: ██ ONLINE",
    "▌ LOADING DESKTOP ENVIRONMENT...",
    "▌ ██ HYPRLAND/WAYLAND: [READY]",
    "▌ ██ STATUS BAR: [ACTIVE]",
    "▌ SHADOWOS SYSTEM READY",
    "▌ WELCOME TO THE SHADOW"
];

message_index = 0;
message_timer = 0;

function display_messages() {
    message_timer++;
    if (message_timer % 25 == 0 && message_index < boot_messages.length) {
        message_index++;
        if (message_index <= 10) {
            target_progress = message_index * 5;
        }
    }
    
    // Title
    fun.text {
        text = "╔══════════════════════════════════════════════════╗";
        font = "Monospace Bold 14";
        x = screen_width * 0.15;
        y = screen_height * 0.15;
        color = 0, 1, 1, 0.9;
    }
    fun.text {
        text = "║  🌑 SHADOWOS v2026.1 — NeonVanguard             ║";
        font = "Monospace Bold 14";
        x = screen_width * 0.15;
        y = screen_height * 0.15 + 25;
        color = 0.5, 0, 0.5, 0.9;
    }
    fun.text {
        text = "╚══════════════════════════════════════════════════╝";
        font = "Monospace Bold 14";
        x = screen_width * 0.15;
        y = screen_height * 0.15 + 50;
        color = 0, 1, 1, 0.9;
    }
    
    // Boot messages with typewriter effect
    for (i = 0; i < message_index && i < boot_messages.length; i++) {
        y_pos = screen_height * 0.25 + i * 22;
        opacity = (i == message_index - 1) ? 1.0 : 0.6;
        
        // Neon green for active message, dimmer for past
        if (i == message_index - 1) {
            fun.text {
                text = boot_messages[i];
                font = "Monospace Bold 13";
                x = screen_width * 0.18;
                y = y_pos;
                color = 0, 1, 0.8, opacity;
            }
        } else {
            fun.text {
                text = boot_messages[i];
                font = "Monospace 11";
                x = screen_width * 0.18;
                y = y_pos;
                color = 0, 0.8, 0.6, opacity * 0.7;
            }
        }
    }
}

// ─── Scanline Effect ───────────────────────────────────────────────────
function draw_scanlines() {
    for (y = 0; y < screen_height; y += 4) {
        fun.rectangle {
            x = 0; y = y;
            width = screen_width; height = 1;
            color = 0, 0, 0, 0.1;
        }
    }
}

// ─── Corner Decorations ────────────────────────────────────────────────
function draw_corners() {
    corner_size = 20;
    // Top-left
    fun.rectangle { x = 0; y = 0; width = corner_size; height = 2; color = 0, 1, 1, 0.5; }
    fun.rectangle { x = 0; y = 0; width = 2; height = corner_size; color = 0, 1, 1, 0.5; }
    // Top-right
    fun.rectangle { x = screen_width - corner_size; y = 0; width = corner_size; height = 2; color = 1, 0, 1, 0.5; }
    fun.rectangle { x = screen_width - 2; y = 0; width = 2; height = corner_size; color = 1, 0, 1, 0.5; }
    // Bottom-left
    fun.rectangle { x = 0; y = screen_height - 2; width = corner_size; height = 2; color = 0, 1, 1, 0.5; }
    fun.rectangle { x = 0; y = screen_height - corner_size; width = 2; height = corner_size; color = 0, 1, 1, 0.5; }
    // Bottom-right
    fun.rectangle { x = screen_width - corner_size; y = screen_height - 2; width = corner_size; height = 2; color = 1, 0, 1, 0.5; }
    fun.rectangle { x = screen_width - 2; y = screen_height - corner_size; width = 2; height = corner_size; color = 1, 0, 1, 0.5; }
}

// ─── Main Animation Loop ───────────────────────────────────────────────
fun.animation_loop() {
    draw_hex_grid();
    draw_matrix();
    draw_scanlines();
    draw_progress_bar();
    display_messages();
    draw_corners();
    update_progress();
}

// Boot callbacks
Plymouth.SetBootProgressFunction(function(new_progress, new_message) {
    target_progress = new_progress;
    if (new_message) {
        message_index++;
    }
});

Plymouth.SetMessageFunction(function(message) {
    message_index++;
});

// Start
fun.animation_loop();
PLYMOUTHSCRIPT

# ─── Set as Default Theme ────────────────────────────────────────────────
plymouth-set-default-theme shadowos 2>/dev/null || true
update-initramfs -u 2>/dev/null || true

echo -e "${GREEN}✓ ShadowOS Plymouth theme installed${NC}"
echo -e "  Theme location: $PLYMOUTH_DIR"
echo -e "  Features:"
echo -e "    • Matrix-style rain animation"
echo -e "    • Hexagonal grid background"
echo -e "    • Neon cyan/magenta progress bar"
echo -e "    • Boot message sequence"
echo -e "    • Scanline CRT effect"
echo -e "    • Corner decorations"