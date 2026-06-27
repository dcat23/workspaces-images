#!/usr/bin/env bash
set -ex
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

# Fetch latest teams-for-linux release .deb from GitHub
DEB_URL=$(curl -fsSL https://api.github.com/repos/IsmaelMartinez/teams-for-linux/releases/latest \
    | grep "browser_download_url" \
    | grep "_${ARCH}\.deb" \
    | head -1 \
    | cut -d '"' -f 4)

if [ -z "${DEB_URL}" ]; then
    echo "Could not find teams-for-linux .deb for ${ARCH}, skipping"
    exit 0
fi

curl -L -o teams.deb "${DEB_URL}"
apt-get install -y ./teams.deb
rm teams.deb

sed -i 's|Exec=/opt/teams-for-linux/teams-for-linux|Exec=/opt/teams-for-linux/teams-for-linux --no-sandbox|g' /usr/share/applications/teams-for-linux.desktop
cp /usr/share/applications/teams-for-linux.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/teams-for-linux.desktop
