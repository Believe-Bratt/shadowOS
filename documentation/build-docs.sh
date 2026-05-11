#!/bin/bash
# ============================================================================
# ShadowOS Documentation Builder
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }

DOC_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$DOC_DIR/output"
mkdir -p "$OUTPUT_DIR"

step "BUILDING SHADOWOS DOCUMENTATION"

# Generate HTML documentation from markdown files
if command -v pandoc &>/dev/null; then
    for md in "$DOC_DIR"/*.md; do
        if [ -f "$md" ]; then
            basename=$(basename "$md" .md)
            pandoc "$md" \
                --standalone \
                --metadata title="ShadowOS - $basename" \
                --css "$DOC_DIR/style.css" \
                --mathjax \
                -o "$OUTPUT_DIR/${basename}.html" 2>&1
            success "Built: $basename.html"
        fi
    done
else
    warn "pandoc not found — copying raw markdown instead"
    cp "$DOC_DIR"/*.md "$OUTPUT_DIR/" 2>/dev/null || true
fi

# Generate man pages
mkdir -p "$OUTPUT_DIR/man"
for script in /opt/ShadowOS/scripts/*.sh /opt/ShadowOS/system-services/*.sh; do
    if [ -f "$script" ]; then
        basename=$(basename "$script" .sh)
        head -20 "$script" | grep -E "^# " > "$OUTPUT_DIR/man/${basename}.1" 2>/dev/null || true
    fi
done

# Generate PDF (if wkhtmltopdf is available)
if command -v wkhtmltopdf &>/dev/null; then
    for html in "$OUTPUT_DIR"/*.html; do
        if [ -f "$html" ]; then
            basename=$(basename "$html" .html)
            wkhtmltopdf "$html" "$OUTPUT_DIR/${basename}.pdf" 2>&1
            success "Built: $basename.pdf"
        fi
    done
fi

# Generate Dash/Zeal docset
mkdir -p "$OUTPUT_DIR/docset/ShadowOS.docset/Contents/Resources/Documents"
cp "$OUTPUT_DIR"/*.html "$OUTPUT_DIR/docset/ShadowOS.docset/Contents/Resources/Documents/" 2>/dev/null || true

cat > "$OUTPUT_DIR/docset/ShadowOS.docset/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>shadowos</string>
    <key>CFBundleName</key>
    <string>ShadowOS</string>
    <key>DocSetPlatformFamily</key>
    <string>shadowos</string>
    <key>dashIndexFilePath</key>
    <string>index.html</string>
</dict>
</plist>
PLIST

success "Documentation built in $OUTPUT_DIR/"
echo ""
echo -e "  ${CYAN}Outputs:${NC}"
echo -e "    HTML:  $OUTPUT_DIR/*.html"
echo -e "    Man:   $OUTPUT_DIR/man/"
echo -e "    Docset: $OUTPUT_DIR/docset/"