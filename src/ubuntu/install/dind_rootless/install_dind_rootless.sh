#!/usr/bin/env bash
set -ex

# Enable Docker repo
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

# Source OS info to detect distro
. /etc/os-release

# Debian-based distros (Parrot OS, Kali, etc.) use the debian Docker repo
if [ "${ID}" = "ubuntu" ]; then
    DOCKER_DISTRO="ubuntu"
    DOCKER_CODENAME="${VERSION_CODENAME}"
else
    DOCKER_DISTRO="debian"
    DOCKER_CODENAME="${DEBIAN_CODENAME:-${VERSION_CODENAME}}"
    # Parrot OS and other derivatives use their own codenames (e.g. "echo", "lory")
    # that don't exist in Docker's repo. Map them via /etc/debian_version.
    if ! echo "buster bullseye bookworm trixie" | grep -qw "${DOCKER_CODENAME}"; then
        DEBIAN_MAJOR=$(cut -d. -f1 /etc/debian_version 2>/dev/null || echo "12")
        case "${DEBIAN_MAJOR}" in
            13) DOCKER_CODENAME="trixie" ;;
            12) DOCKER_CODENAME="bookworm" ;;
            11) DOCKER_CODENAME="bullseye" ;;
            10) DOCKER_CODENAME="buster" ;;
            *)  DOCKER_CODENAME="bookworm" ;;
        esac
    fi
fi

# Enable Docker repo (apt-key removed in Debian 12+/Ubuntu 22.04+)
install -m 0755 -d /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/${DOCKER_DISTRO}/gpg" | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DOCKER_DISTRO} ${DOCKER_CODENAME} stable" > \
    /etc/apt/sources.list.d/docker.list

# Install deps
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    dbus-user-session \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    fuse-overlayfs \
    iptables \
    kmod \
    slirp4netns \
    openssh-client \
    sudo \
    supervisor \
    uidmap \
    wget

# User settings
echo 'hosts: files dns' > /etc/nsswitch.conf

# Cleanup
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi
