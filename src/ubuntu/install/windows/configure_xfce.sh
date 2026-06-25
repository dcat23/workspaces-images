#!/usr/bin/env bash
set -ex

export DEBIAN_FRONTEND=noninteractive

# ── Segoe UI Fonts ────────────────────────────────────────────────────────────
FONT_DEST="/usr/share/fonts/Microsoft/TrueType/SegoeUI"
mkdir -p "$FONT_DEST"
git clone --depth=1 https://github.com/mrbvrz/segoe-ui-linux.git /tmp/segoe-ui-linux
cp /tmp/segoe-ui-linux/font/*.ttf "$FONT_DEST/"
fc-cache -fv
rm -rf /tmp/segoe-ui-linux

# ── XFCE xsettings: GTK theme, icon theme, font ───────────────────────────────
# Overwrites the default profile config so every new session gets Win11 theming.
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
    <property name="Net" type="empty">
        <property name="ThemeName" type="string" value="Win11-round-Light"/>
        <property name="IconThemeName" type="string" value="Win11"/>
        <property name="DoubleClickTime" type="empty"/>
        <property name="DoubleClickDistance" type="empty"/>
        <property name="DndDragThreshold" type="empty"/>
        <property name="CursorBlink" type="empty"/>
        <property name="CursorBlinkTime" type="empty"/>
        <property name="SoundThemeName" type="empty"/>
        <property name="EnableEventSounds" type="empty"/>
        <property name="EnableInputFeedbackSounds" type="empty"/>
    </property>
    <property name="Xft" type="empty">
        <property name="DPI" type="int" value="96"/>
        <property name="Antialias" type="int" value="1"/>
        <property name="Hinting" type="int" value="1"/>
        <property name="HintStyle" type="string" value="hintslight"/>
        <property name="RGBA" type="string" value="rgb"/>
    </property>
    <property name="Gtk" type="empty">
        <property name="CanChangeAccels" type="empty"/>
        <property name="ColorPalette" type="empty"/>
        <property name="FontName" type="string" value="Segoe UI 11"/>
        <property name="IconSizes" type="empty"/>
        <property name="KeyThemeName" type="empty"/>
        <property name="ToolbarStyle" type="empty"/>
        <property name="ToolbarIconSize" type="empty"/>
        <property name="MenuImages" type="empty"/>
        <property name="ButtonImages" type="empty"/>
        <property name="MenuBarAccel" type="empty"/>
        <property name="CursorThemeName" type="string" value="bridge"/>
        <property name="CursorThemeSize" type="empty"/>
        <property name="DecorationLayout" type="empty"/>
    </property>
    <property name="Xfce" type="empty">
        <property name="LastCustomDPI" type="int" value="96"/>
    </property>
</channel>
EOF

# ── XFCE xfwm4: Win11 window decorations, Segoe UI title bar, Win-style buttons ─
XFWM4="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"
sed -i 's/name="theme" type="string" value="[^"]*"/name="theme" type="string" value="Win11-round-Light"/' "$XFWM4"
sed -i 's/name="title_font" type="string" value="[^"]*"/name="title_font" type="string" value="Segoe UI Bold 9"/' "$XFWM4"
# Windows-style button layout: menu on left, then minimize/maximize/close on right
sed -i 's/name="button_layout" type="string" value="[^"]*"/name="button_layout" type="string" value="O|HMC,"/' "$XFWM4"
