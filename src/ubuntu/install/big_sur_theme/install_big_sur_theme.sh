#!/usr/bin/env bash
set -ex

echo "Installing Big Sur (WhiteSur) theme for Kasm"

export DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# Packages
# Omitted from original install-debian.sh:
#   xfce4-indicator-plugin   — dropped from Ubuntu repos after Focal.
#   xfce4-sensors-plugin     — hardware sensors unavailable in containers;
#     causes panel errors every session.
#   xfce4-statusnotifier-plugin — removed in Noble; SNI merged into systray
#     plugin in XFCE 4.18.
#   ulauncher                — not in Noble apt repos; requires manual PPA.
#
# xfce4-appmenu-plugin (originally assumed missing) IS in Noble universe.
# appmenu-gtk{2,3}-module + appmenu-registrar provide the DBus global menu
# bridge that feeds app menu items to the panel plugin.
# ---------------------------------------------------------------------------
apt-get update
apt-get install -y \
    xfce4-power-manager \
    xfce4-pulseaudio-plugin \
    xfce4-notifyd \
    xfce4-appmenu-plugin \
    appmenu-gtk2-module \
    appmenu-gtk3-module \
    appmenu-registrar \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf \
    sassc \
    git \
    plank

WORK_DIR=/tmp/bigsur-theme-install
mkdir -p "$WORK_DIR"

# WhiteSur installer scripts resolve the calling user via:
#   MY_USERNAME="${SUDO_USER:-$(logname 2>/dev/null || echo "${USER}")}"
# In a Docker build there is no login session, so logname and $USER are both
# empty, which causes getent passwd '' to fail under set -Eeo pipefail.
# Exporting SUDO_USER=root makes the installers resolve to root correctly.
export SUDO_USER=root

# ---------------------------------------------------------------------------
# GTK theme (WhiteSur)
# Install system-wide (/usr/share/themes) so both kasm-default-profile and
# kasm-user pick it up.  -c is repeatable; pass both variants in one call so
# the second invocation does not wipe what the first installed.
# ---------------------------------------------------------------------------
git clone --depth=1 https://github.com/jothi-prasath/WhiteSur-gtk-theme.git \
    "$WORK_DIR/WhiteSur-gtk-theme"
"$WORK_DIR/WhiteSur-gtk-theme/install.sh" -d /usr/share/themes -c dark -c light

# ---------------------------------------------------------------------------
# Icon theme (WhiteSur)
# ---------------------------------------------------------------------------
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git \
    "$WORK_DIR/WhiteSur-icon-theme"
"$WORK_DIR/WhiteSur-icon-theme/install.sh" -d /usr/share/icons

# ---------------------------------------------------------------------------
# Cursor theme (WhiteSur)
# The repo ships pre-built cursor dirs under dist/; copy directly to the
# system icons directory.
# ---------------------------------------------------------------------------
git clone --depth=1 https://github.com/vinceliuice/WhiteSur-cursors.git \
    "$WORK_DIR/WhiteSur-cursors"
# The cursor repo ships the theme files directly under dist/; its own
# install.sh (which is simple and root-safe) copies dist/ → WhiteSur-cursors/
( cd "$WORK_DIR/WhiteSur-cursors" && bash install.sh )

# ---------------------------------------------------------------------------
# SmallSur assets (wallpapers + plank theme)
# Clone only for its bundled assets; the incompatible install-debian.sh is
# not executed.
# ---------------------------------------------------------------------------
git clone --depth=1 https://github.com/jothi-prasath/SmallSur.git \
    "$WORK_DIR/SmallSur"

# Wallpapers → system backgrounds directory; set one as the Kasm default
mkdir -p /usr/share/backgrounds/bigsur
cp -r "$WORK_DIR/SmallSur/wallpaper/"* /usr/share/backgrounds/bigsur/
cp /usr/share/backgrounds/bigsur/monterey.png /usr/share/backgrounds/bg_default.png

# Plank theme (kept for images that run plank; no-op otherwise)
mkdir -p /usr/share/plank/themes
cp -rp "$WORK_DIR/SmallSur/plank/mcOS-BS-iMacM1-Black" /usr/share/plank/themes/
if [ -d "$WORK_DIR/WhiteSur-gtk-theme/src/other/plank" ]; then
    cp -rp "$WORK_DIR/WhiteSur-gtk-theme/src/other/plank/"* /usr/share/plank/themes/
fi

# ---------------------------------------------------------------------------
# Remove the symlink emblem arrow from desktop icons.
# Kasm's Downloads/Uploads are symlinked directories; XFCE/GTK renders
# emblem-symbolic-link on top of them.  Replace it with a transparent 1×1 PNG
# in the hicolor fallback so all icon themes inherit the suppression.
# ---------------------------------------------------------------------------
python3 - << 'PYEOF'
import zlib, struct, os

def png_chunk(tag, data):
    payload = tag + data
    return struct.pack('>I', len(data)) + payload + struct.pack('>I', zlib.crc32(payload) & 0xffffffff)

ihdr = struct.pack('>IIBBBBB', 1, 1, 8, 6, 0, 0, 0)   # 1×1 RGBA
idat = zlib.compress(b'\x00\x00\x00\x00\x00')          # filter=0 + 4 zero bytes (RGBA)
png  = b'\x89PNG\r\n\x1a\n'
png += png_chunk(b'IHDR', ihdr)
png += png_chunk(b'IDAT', idat)
png += png_chunk(b'IEND', b'')

for size in ('16x16', '22x22', '24x24', '32x32', '48x48'):
    path = f'/usr/share/icons/hicolor/{size}/emblems'
    os.makedirs(path, exist_ok=True)
    with open(f'{path}/emblem-symbolic-link.png', 'wb') as f:
        f.write(png)
PYEOF
gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true

# ---------------------------------------------------------------------------
# Plank dock
# Install autostart entry so Plank launches with the XFCE session, and write
# a minimal preferences file that selects our Big Sur dock theme.
# ---------------------------------------------------------------------------
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/plank.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Plank
Comment=Dock
Exec=plank
Icon=plank
Terminal=false
StartupNotify=false
Categories=Utility;
EOF

mkdir -p "$HOME/.config/plank/dock1"
cat > "$HOME/.config/plank/dock1/settings" << 'EOF'
[PlankDockPreferences]
#Whether to show only windows of the current workspace.
CurrentWorkspaceOnly=false
#The size of dock icons (in pixels).
IconSize=48
#If 0, the dock won't hide. If 1, the dock auto-hides. If 2, the dock intellihides. If 3, the dock auto-hides and is dodge-active. If 4, the dock auto-hides and is dodge-maximized. If 5, the dock auto-hides and is windows-dodge.
HideMode=0
#Time to wait before unhiding the dock (in milliseconds).
UnhideDelay=0
#The dock theme to use.
Theme=mcOS-BS-iMacM1-Black
#The alignment of the dock on the monitor's edge.
Alignment=3
#Whether the dock is shown on all monitors.
LockItems=false
#Zoom level (0 to disable).
ZoomPercent=120
EOF

# ---------------------------------------------------------------------------
# XFCE panel config
# Cannot use xfconf-query during image build (no running XFCE/DBus session).
# Write the XML configs directly into the default profile home so XFCE picks
# them up on first launch.
#
# Changes from the SmallSur xfce4-panel.xml:
#   - Removed plugin-16 (appmenu) — package unavailable / DBus not running
#   - Removed plugin-7  (xfce4-sensors-plugin) — hardware sensors absent in
#     containers; leaving it in causes panel startup errors every session
#   - Removed plugin-6  (notification-plugin) — not a standard plugin id;
#     xfce4-notifyd provides a daemon, not a panel applet that embeds here
#   - Kept: applicationsmenu, systray, pulseaudio, power-manager, clock
#   - Panel background colour shifted to a neutral dark (~macOS menubar tone)
# ---------------------------------------------------------------------------
mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="25"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
        <value type="int" value="8"/>
      </property>
      <property name="background-style" type="uint" value="1"/>
      <property name="background-rgba" type="array">
        <value type="double" value="0.000000"/>
        <value type="double" value="0.000000"/>
        <value type="double" value="0.000000"/>
        <value type="double" value="0.300000"/>
      </property>
      <property name="length-adjust" type="bool" value="true"/>
      <property name="span-monitors" type="bool" value="false"/>
      <property name="mode" type="uint" value="0"/>
      <property name="autohide-behavior" type="uint" value="0"/>
      <property name="disable-struts" type="bool" value="false"/>
      <property name="icon-size" type="uint" value="16"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu">
      <property name="button-icon" type="string" value="/usr/share/extra/icons/icon_default.png"/>
      <property name="show-button-title" type="bool" value="false"/>
    </property>
    <property name="plugin-2" type="string" value="appmenu">
      <property name="plugins" type="empty">
        <property name="plugin-2" type="empty">
          <property name="compact-mode" type="bool" value="false"/>
          <property name="bold-application-name" type="bool" value="true"/>
          <property name="expand" type="bool" value="false"/>
        </property>
      </property>
    </property>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="clock">
      <property name="digital-format" type="string" value="%a %d %b  %l:%M %p"/>
    </property>
    <property name="plugin-5" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-6" type="string" value="systray">
      <property name="show-frame" type="bool" value="false"/>
      <property name="square-icons" type="bool" value="true"/>
      <property name="size-max" type="uint" value="22"/>
    </property>
    <property name="plugin-7" type="string" value="pulseaudio">
      <property name="enable-keyboard-shortcuts" type="bool" value="true"/>
      <property name="show-notifications" type="bool" value="true"/>
    </property>
    <property name="plugin-8" type="string" value="power-manager-plugin"/>
  </property>
</channel>
EOF

# ---------------------------------------------------------------------------
# XFCE settings (theme / icon / cursor)
# Writing xsettings.xml directly replaces the three xfconf-query calls from
# install-debian.sh, which cannot run without a live XFCE session.
# ---------------------------------------------------------------------------
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
    <property name="Net" type="empty">
        <property name="ThemeName" type="string" value="WhiteSur-Dark"/>
        <property name="IconThemeName" type="string" value="WhiteSur-Dark"/>
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
        <property name="FontName" type="empty"/>
        <property name="IconSizes" type="empty"/>
        <property name="KeyThemeName" type="empty"/>
        <property name="ToolbarStyle" type="empty"/>
        <property name="ToolbarIconSize" type="empty"/>
        <property name="MenuImages" type="empty"/>
        <property name="ButtonImages" type="empty"/>
        <property name="MenuBarAccel" type="empty"/>
        <property name="CursorThemeName" type="string" value="WhiteSur-cursors"/>
        <property name="CursorThemeSize" type="empty"/>
        <property name="DecorationLayout" type="empty"/>
    </property>
    <property name="Xfce" type="empty">
        <property name="LastCustomDPI" type="int" value="96"/>
    </property>
</channel>
EOF

# ---------------------------------------------------------------------------
# Set default wallpaper via XFCE desktop channel config
# One entry covers the default monitor/workspace slot; Kasm will apply it
# on first XFCE start.
# ---------------------------------------------------------------------------
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
      </property>
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
      </property>
      <property name="monitorVNC-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
      </property>
      <property name="monitorVNC-2" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
      </property>
      <property name="monitorVNC-3" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace1" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/bg_default.png"/>
        </property>
      </property>
    </property>
  </property>
  <property name="last" type="empty">
    <property name="window-width" type="int" value="1280"/>
    <property name="window-height" type="int" value="1024"/>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-home" type="bool" value="false"/>
      <property name="show-trash" type="bool" value="false"/>
    </property>
  </property>
</channel>
EOF

# ---------------------------------------------------------------------------
# Window manager theme (xfwm4)
# WhiteSur-gtk-theme also ships matching xfwm4 decorations; set the theme
# name so window title bars match the GTK chrome.
# ---------------------------------------------------------------------------
cat > "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
    <property name="general" type="empty">
        <property name="theme" type="string" value="WhiteSur-Dark"/>
        <property name="title_font" type="string" value="Sans Bold 9"/>
        <property name="title_alignment" type="string" value="center"/>
        <property name="button_layout" type="string" value="CHM|O"/>
        <property name="use_compositing" type="bool" value="true"/>
        <property name="sync_to_vblank" type="bool" value="false"/>
        <property name="workspace_count" type="int" value="4"/>
    </property>
</channel>
EOF

# ---------------------------------------------------------------------------
# GTK 2/3 theme pointers in the profile home (belt-and-suspenders for apps
# that read ~/.gtkrc-2.0 or ~/.config/gtk-3.0/settings.ini directly)
# ---------------------------------------------------------------------------
cat > "$HOME/.gtkrc-2.0" << 'EOF'
gtk-theme-name="WhiteSur-Dark"
gtk-icon-theme-name="WhiteSur-Dark"
gtk-cursor-theme-name="WhiteSur-cursors"
gtk-font-name="Sans 10"
EOF

mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=WhiteSur-Dark
gtk-icon-theme-name=WhiteSur-Dark
gtk-cursor-theme-name=WhiteSur-cursors
gtk-font-name=Sans 10
EOF

# ---------------------------------------------------------------------------
# GTK appmenu module
# appmenu-gtk{2,3}-module export running app menus over DBus so that
# xfce4-appmenu-plugin can display them in the panel.  The module is loaded
# by setting GTK_MODULES in the session environment.
# ---------------------------------------------------------------------------
mkdir -p /etc/X11/Xsession.d
cat > /etc/X11/Xsession.d/81appmenu << 'EOF'
export GTK_MODULES="${GTK_MODULES:+$GTK_MODULES:}appmenu-gtk-module"
EOF
chmod +x /etc/X11/Xsession.d/81appmenu

# ---------------------------------------------------------------------------
# Ownership and cache cleanup
# ---------------------------------------------------------------------------
chown -R 1000:0 "$HOME"
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;

rm -rf "$WORK_DIR"

if [ -z "${SKIP_CLEAN+x}" ]; then
    apt-get autoclean
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
fi

echo "Big Sur theme installation complete"
