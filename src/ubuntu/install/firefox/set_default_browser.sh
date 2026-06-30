#!/usr/bin/env bash
set -ex

# Set Firefox as the system default browser via update-alternatives
update-alternatives --set x-www-browser /usr/bin/firefox
update-alternatives --set gnome-www-browser /usr/bin/firefox

# Write mimeapps.list so XDG-aware apps (XFCE, file managers, etc.) open Firefox.
# Written to build-time HOME (kasm-default-profile); Kasm copies this to kasm-user on first start.
mkdir -p "$HOME/.config"
cat > "$HOME/.config/mimeapps.list" <<'EOF'
[Default Applications]
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/ftp=firefox.desktop
text/html=firefox.desktop
application/xhtml+xml=firefox.desktop

[Added Associations]
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/ftp=firefox.desktop
text/html=firefox.desktop
application/xhtml+xml=firefox.desktop
EOF

chown -R 1000:0 "$HOME/.config"
