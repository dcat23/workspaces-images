#!/usr/bin/env bash
set -ex

export DEBIAN_FRONTEND=noninteractive

# ── Segoe UI Fonts ────────────────────────────────────────────────────────────
# Clone and copy font files directly — bypasses the interactive install.sh
FONT_DEST="/usr/share/fonts/Microsoft/TrueType/SegoeUI"
mkdir -p "$FONT_DEST"
git clone --depth=1 https://github.com/mrbvrz/segoe-ui-linux.git /tmp/segoe-ui-linux
cp /tmp/segoe-ui-linux/font/*.ttf "$FONT_DEST/"
fc-cache -fv
rm -rf /tmp/segoe-ui-linux

# ── Blur My Shell Extension ───────────────────────────────────────────────────
BMS_UUID="blur-my-shell@aunetx"
BMS_DIR="/usr/share/gnome-shell/extensions/$BMS_UUID"
mkdir -p "$BMS_DIR"
wget -qO /tmp/blur-my-shell.zip \
    "https://github.com/aunetx/blur-my-shell/releases/download/v72/blur-my-shell%40aunetx.shell-extension.zip"
unzip -q /tmp/blur-my-shell.zip -d "$BMS_DIR"
rm /tmp/blur-my-shell.zip

# ── ArcMenu Extension ─────────────────────────────────────────────────────────
# Download from GNOME Extensions for the installed shell version (GNOME 46 on Noble)
ARCMENU_UUID="arcmenu@arcmenu.com"
ARCMENU_DIR="/usr/share/gnome-shell/extensions/$ARCMENU_UUID"
mkdir -p "$ARCMENU_DIR"
wget -qO /tmp/arcmenu.zip \
    "https://extensions.gnome.org/download-extension/arcmenu%40arcmenu.com.shell-extension.zip?shell_version=46"
unzip -q /tmp/arcmenu.zip -d "$ARCMENU_DIR"
rm /tmp/arcmenu.zip

# Compile ArcMenu GSettings schemas
if [ -d "$ARCMENU_DIR/schemas" ]; then
    glib-compile-schemas "$ARCMENU_DIR/schemas/"
fi

# ── GSettings Schema Override ─────────────────────────────────────────────────
# Pre-configures GNOME settings at build time — no D-Bus session required.
# All extensions are declared here so they auto-enable on first login.
cat > /usr/share/glib-2.0/schemas/99_macchiato-windows.gschema.override << 'SCHEMA'
[org.gnome.shell]
enabled-extensions=['dash-to-panel@jderose9.github.com', 'arcmenu@arcmenu.com', 'blur-my-shell@aunetx']
disable-user-extensions=false

[org.gnome.desktop.interface]
gtk-theme='Win11-Light'
icon-theme='Win11'
font-name='Segoe UI 11'
document-font-name='Segoe UI 11'
monospace-font-name='Cascadia Code 11'
color-scheme='default'

[org.gnome.desktop.wm.preferences]
button-layout=':minimize,maximize,close'
theme='Win11-Light'

[org.gnome.desktop.background]
picture-options='zoom'
primary-color='#0078d4'
SCHEMA

glib-compile-schemas /usr/share/glib-2.0/schemas/
