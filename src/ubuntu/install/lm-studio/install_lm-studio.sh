#!/usr/bin/env bash
set -ex

# Install lm-studio 
apt-get update
curl -L -o lm-studio.deb  "https://lmstudio.ai/download/latest/linux/x64?format=deb"
apt-get install -y ./lm-studio.deb
rm lm-studio.deb

# Desktop file setup
sed -i "s@Exec=/usr/bin/lm-studio@Exec=/usr/bin/lm-studio --no-sandbox@g"  /usr/share/applications/lm-studio.desktop
cp /usr/share/applications/lm-studio.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/lm-studio.desktop

# Cleanup
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi

# Cleanup for app layer
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
