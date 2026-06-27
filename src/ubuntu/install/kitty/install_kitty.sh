#!/usr/bin/env bash
set -ex

# Install Kitty as the default terminal emulator.

apt-get update
apt-get install -y kitty

# ── 1. exo-open TerminalEmulator helper ───────────────────────────────────────
# XFCE's "Open Terminal Here" and keyboard shortcut actions go through
# exo-open --launch TerminalEmulator. Registering a kitty helper lets exo
# resolve it; without this entry exo falls back to xfce4-terminal or prompts.
mkdir -p /usr/share/xfce4/helpers
cat > /usr/share/xfce4/helpers/kitty.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Icon=kitty
Type=X-XFCE-Helper
Name=kitty
X-XFCE-Binaries=kitty;
X-XFCE-Category=TerminalEmulator
X-XFCE-Commands=%B;
X-XFCE-CommandsWithParameter=%B %s;
EOF

# ── 2. helpers.rc ─────────────────────────────────────────────────────────────
# Mirrors the approach used for Nemo: only the TerminalEmulator key is written;
# other keys (FileManager, WebBrowser, …) are left intact.
set_terminal_helper() {
    local rc_file="$1"
    local rc_dir
    rc_dir="$(dirname "$rc_file")"
    mkdir -p "$rc_dir"

    if [ -f "$rc_file" ]; then
        if grep -q '^TerminalEmulator=' "$rc_file"; then
            sed -i 's/^TerminalEmulator=.*/TerminalEmulator=kitty/' "$rc_file"
        else
            printf 'TerminalEmulator=kitty\n' >> "$rc_file"
        fi
    else
        printf '[Default Applications]\nTerminalEmulator=kitty\n' > "$rc_file"
    fi
}

set_terminal_helper /etc/xdg/xfce4/helpers.rc
set_terminal_helper "$HOME/.config/xfce4/helpers.rc"

# ── 3. Shell ──────────────────────────────────────────────────────────────────
# Kitty does not source the login shell by default in this environment and
# falls back to /bin/sh. Explicitly configure bash so behaviour matches the
# other terminals in the image.
mkdir -p "$HOME/.config/kitty"
printf 'shell /bin/bash\n' >> "$HOME/.config/kitty/kitty.conf"
chown -R 1000:0 "$HOME/.config/kitty"

# ── 4. update-alternatives ────────────────────────────────────────────────────
# Priority 50 — higher than xterm (10) and xfce4-terminal (20) so kitty wins
# when x-terminal-emulator is invoked directly.
update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50

# ── 5. Cleanup ────────────────────────────────────────────────────────────────
chown -R 1000:0 "$HOME"
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z "${SKIP_CLEAN+x}" ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi
