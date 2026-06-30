#!/usr/bin/env bash
set -ex

ARCH=$(dpkg --print-architecture)

# Add Google Cloud apt repo
mkdir -p /usr/share/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | gpg --dearmor \
  | tee /usr/share/keyrings/cloud.google.gpg > /dev/null

echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  > /etc/apt/sources.list.d/google-cloud-sdk.list

apt-get update
apt-get install -y google-cloud-cli

# Cleanup
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi
