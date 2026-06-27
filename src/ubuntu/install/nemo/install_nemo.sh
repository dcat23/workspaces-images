#!/usr/bin/env bash
set -ex

# Install Nemo as the default file manager, replacing the Thunar daemon
# that the core XFCE session launches via execThunar.sh.

apt-get update
apt-get install -y nemo nemo-fileroller

# ── 1. Session daemon ─────────────────────────────────────────────────────────
# Mirrors the execThunar.sh pattern from core so the XFCE failsafe session
# can source generate_container_user before spawning nemo.
cat > /usr/bin/execNemo.sh << 'EOF'
#!/bin/sh
. /dockerstartup/generate_container_user
/usr/bin/nemo --no-default-window
EOF
chmod +x /usr/bin/execNemo.sh

# ── 2. XFCE failsafe session ──────────────────────────────────────────────────
# The core image writes xfce4-session.xml (Client3_Command = execThunar.sh)
# via ADD ./src/ubuntu/xfce/.config/ $HOME/.config/. Patch it here.
SESSION_XML=/home/kasm-default-profile/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
if [ -f "$SESSION_XML" ]; then
    sed -i 's|/usr/bin/execThunar.sh|/usr/bin/execNemo.sh|g' "$SESSION_XML"
fi

# ── 3. exo-open FileManager helper ───────────────────────────────────────────
# XFCE's "Open File Manager" actions (desktop right-click, keyboard shortcuts,
# panel buttons) all go through exo-open --launch FileManager, which looks up
# the active helper in helpers.rc then resolves it from the helpers directory.
# Without a registered nemo helper exo falls back to Thunar.
mkdir -p /usr/share/xfce4/helpers
cat > /usr/share/xfce4/helpers/nemo.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Icon=system-file-manager
Type=X-XFCE-Helper
Name=Nemo
X-XFCE-Binaries=nemo;
X-XFCE-Category=FileManager
X-XFCE-Commands=%B;
X-XFCE-CommandsWithParameter=%B "%s";
EOF

# helpers.rc uses GKeyFile format; the required section header is
# "[Default Applications]". Writing a file without it — or with the wrong
# header — causes exo to fail parsing and prompt for every category.
#
# Strategy: if the file already has a FileManager key, patch it in place.
# If the file exists but lacks the key, append inside the existing section.
# If the file doesn't exist at all, create it with the minimal valid header
# so other categories (WebBrowser, TerminalEmulator) stay auto-detected.
set_file_manager_helper() {
    local rc_file="$1"
    local rc_dir
    rc_dir="$(dirname "$rc_file")"
    mkdir -p "$rc_dir"

    if [ -f "$rc_file" ]; then
        if grep -q '^FileManager=' "$rc_file"; then
            sed -i 's/^FileManager=.*/FileManager=nemo/' "$rc_file"
        else
            printf 'FileManager=nemo\n' >> "$rc_file"
        fi
    else
        # New file: write a valid GKeyFile so exo can parse it.
        # Only FileManager is set; missing keys are auto-detected by exo.
        printf '[Default Applications]\nFileManager=nemo\n' > "$rc_file"
    fi
}

set_file_manager_helper /etc/xdg/xfce4/helpers.rc
set_file_manager_helper "$HOME/.config/xfce4/helpers.rc"

# ── 4. MIME defaults ──────────────────────────────────────────────────────────
# xdg-mime writes to $HOME/.config/mimeapps.list (kasm-default-profile here).
xdg-mime default nemo.desktop inode/directory
xdg-mime default nemo.desktop application/x-gnome-saved-search
update-alternatives --install /usr/bin/x-file-manager x-file-manager /usr/bin/nemo 100

# System-wide fallback so sessions not inheriting the profile mimeapps still
# resolve directories to nemo.
mkdir -p /etc/xdg
cat > /etc/xdg/mimeapps.list << 'EOF'
[Default Applications]
inode/directory=nemo.desktop
application/x-gnome-saved-search=nemo.desktop
EOF

# ── 5. Application menu visibility ───────────────────────────────────────────
# nemo.desktop ships with Categories=GNOME;GTK;Utility;Core; which omits
# System — add it so XFCE menus file it under a visible category.
NEMO_DESKTOP=/usr/share/applications/nemo.desktop
if [ -f "$NEMO_DESKTOP" ]; then
    sed -i 's/^Categories=.*/Categories=System;FileManager;GTK;Utility;Core;/' "$NEMO_DESKTOP"
fi

# ── 6. Cleanup ────────────────────────────────────────────────────────────────
chown -R 1000:0 "$HOME"
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z "${SKIP_CLEAN+x}" ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi
