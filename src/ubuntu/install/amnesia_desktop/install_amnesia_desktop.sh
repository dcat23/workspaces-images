#!/usr/bin/env bash
set -ex

echo "Install Amnesia Desktop privacy tools"

apt-get update
apt-get install -y \
  keepassxc \
  gnupg \
  gpg-agent \
  pinentry-gtk2 \
  mat2 \
  torsocks \
  imagemagick

# OnionShare is in Ubuntu universe; best-effort install
set +e
apt-get install -y onionshare
ONIONSHARE_INSTALLED=$?
set -e

# Torsocks helper script
cat > /usr/local/bin/amnesia-tor-help <<'TORHELP'
#!/bin/bash
cat <<'EOF'
==============================================
  AMNESIA DESKTOP — Tor CLI Usage Guide
==============================================

To route CLI tools through Tor, prefix with torsocks:

  torsocks curl https://check.torproject.org/api/ip
  torsocks wget https://example.com/file
  torsocks git clone https://github.com/user/repo

Verify your Tor exit node:
  torsocks curl -s https://check.torproject.org/api/ip

NOTES:
  • Tor Browser uses Tor automatically — no torsocks needed.
  • torsocks only covers TCP; UDP and ICMP cannot use Tor.
  • DNS is proxied through Tor when using torsocks.

==============================================
EOF
TORHELP
chmod +x /usr/local/bin/amnesia-tor-help

# Privacy-hardened bashrc additions for kasm-default-profile
cat >> $HOME/.bashrc <<'BASHRC'

# Amnesia Desktop — minimize session traces
export HISTFILE=/dev/null
export HISTSIZE=0
export HISTFILESIZE=0

# Privacy helpers
alias tor-help='amnesia-tor-help'
alias check-tor='torsocks curl -s https://check.torproject.org/api/ip'
alias mat2-help='mat2 --help'
BASHRC

# Suppress GTK recently-used file tracking
mkdir -p $HOME/.local/share
cat > $HOME/.local/share/recently-used.xbel <<'XBEL'
<?xml version="1.0" encoding="UTF-8"?>
<xbel version="1.0"
      xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks"
      xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info"
>
</xbel>
XBEL
chmod 444 $HOME/.local/share/recently-used.xbel

# Disable Thunar thumbnail cache
mkdir -p $HOME/.config/tumbler
cat > $HOME/.config/tumbler/tumbler.rc <<'TUMBLER'
[Daemon]
MaxCacheAge=0
MaxCacheSize=0
TUMBLER

# Quiet XFCE terminal — no saved history on disk
mkdir -p $HOME/.config/xfce4/terminal
cat > $HOME/.config/xfce4/terminal/terminalrc <<'TERMRC'
[Configuration]
ScrollingLines=500
MiscRememberGeometry=FALSE
TERMRC

# About Amnesia Desktop plain-text file placed on Desktop
mkdir -p $HOME/Desktop
cat > $HOME/Desktop/ABOUT-AMNESIA-DESKTOP.txt <<'ABOUT'
==============================================
  AMNESIA DESKTOP
  Ephemeral, Privacy-First Workspace
==============================================

Amnesia Desktop is a Tails-inspired, privacy-focused Kasm workspace
designed to minimize digital traces and support anonymous workflows.

SOFTWARE INCLUDED
  Tor Browser     — Anonymous web browsing via the Tor network
  Thunderbird     — Email client (supports OpenPGP end-to-end encryption)
  KeePassXC       — Offline, encrypted password manager
  GnuPG / GPG     — PGP encryption for files and email signing
  MAT2            — Metadata anonymization for documents and images
  OnionShare      — Tor-based anonymous file sharing (if installed)
  LibreOffice     — Full office suite for documents, spreadsheets, etc.
  Torsocks        — Route CLI tools through Tor (see: amnesia-tor-help)

PRIVACY MODEL
  Sessions run as ephemeral Kasm containers. By default no data
  persists beyond the current session — the "amnesic" behavior.
  Enabling Kasm persistent profiles reduces this guarantee.

USING TOR FOR CLI TOOLS
  Prefix any CLI command with torsocks to route it through Tor:
    torsocks curl https://check.torproject.org/api/ip
  Run `amnesia-tor-help` in a terminal for more examples.

LIMITATIONS vs REAL TAILS
  • NOT all traffic is routed through Tor. Only Tor Browser uses
    Tor by default. Kasm agent and streaming use direct connections.
  • There is no full-disk encryption or hardware-level isolation.
  • Kasm's browser-based delivery (noVNC) adds trust layers absent
    in real Tails booted from USB.
  • If persistent storage is enabled in Kasm, data may survive
    between sessions, reducing the amnesia guarantee.
  • This workspace is not a substitute for booting real Tails from
    a verified USB drive in high-risk situations.

PRACTICAL ADVICE
  • Use Tor Browser for all sensitive browsing.
  • Use KeePassXC for passwords; do not save credentials in browsers.
  • Use GPG to encrypt sensitive files before saving or sending.
  • Use MAT2 to strip metadata from files before sharing:
      mat2 document.pdf
  • Prefer OnionShare over cloud services for file transfers.

==============================================
  This workspace is Tails-INSPIRED, not Tails.
  It does not claim or provide the same security guarantees.
==============================================
ABOUT

# About Amnesia Desktop launcher
cp $INST_SCRIPTS/amnesia_desktop/amnesia-about.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/amnesia-about.desktop

# KeePassXC desktop icon
if [ -f /usr/share/applications/org.keepassxc.KeePassXC.desktop ]; then
  cp /usr/share/applications/org.keepassxc.KeePassXC.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/org.keepassxc.KeePassXC.desktop
fi

# OnionShare desktop icon (if installed successfully)
if [ $ONIONSHARE_INSTALLED -eq 0 ] && [ -f /usr/share/applications/org.onionshare.OnionShare.desktop ]; then
  cp /usr/share/applications/org.onionshare.OnionShare.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/org.onionshare.OnionShare.desktop
fi

# File manager (Thunar)
if [ -f /usr/share/applications/thunar.desktop ]; then
  cp /usr/share/applications/thunar.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/thunar.desktop
fi

# Terminal
if [ -f /usr/share/applications/xfce4-terminal.desktop ]; then
  cp /usr/share/applications/xfce4-terminal.desktop $HOME/Desktop/
  chmod +x $HOME/Desktop/xfce4-terminal.desktop
fi

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi
