#!/usr/bin/env bash
set -ex
ARCH=$(arch | sed 's/aarch64/arm64/g' | sed 's/x86_64/amd64/g')

# Source OS info to detect distro
. /etc/os-release

# Debian-based distros (Parrot OS, Kali, etc.) use the debian Docker repo
if [ "${ID}" = "ubuntu" ]; then
    DOCKER_DISTRO="ubuntu"
    DOCKER_CODENAME="${VERSION_CODENAME}"
else
    DOCKER_DISTRO="debian"
    # DEBIAN_CODENAME is set on true Debian; fall back to VERSION_CODENAME
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

# Enable Docker repo (apt-key removed in Debian 12+ / Ubuntu 22.04+)
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
    openssh-client \
    sudo \
    supervisor \
    uidmap \
    wget

# Install dind init and hacks
useradd -U dockremap
usermod -G dockremap dockremap
echo 'dockremap:165536:65536' >> /etc/subuid
echo 'dockremap:165536:65536' >> /etc/subgid
curl -o \
    /usr/local/bin/dind -L \
    https://raw.githubusercontent.com/moby/moby/master/hack/dind
chmod +x /usr/local/bin/dind
curl -o \
    /usr/local/bin/dockerd-entrypoint.sh -L \
    https://kasm-ci.s3.amazonaws.com/dockerd-entrypoint.sh
chmod +x /usr/local/bin/dockerd-entrypoint.sh
echo 'hosts: files dns' > /etc/nsswitch.conf
usermod -aG docker kasm-user

# Install k3d tools
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -o \
    /usr/local/bin/kubectl -L \
    "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
chmod +x /usr/local/bin/kubectl

# Passwordless Sudo
echo 'kasm-user:kasm-user' | chpasswd
echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Cleanup
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*
fi
