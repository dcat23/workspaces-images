#!/usr/bin/env bash
set -ex

export DEBIAN_FRONTEND=noninteractive

# Pre-answer the display manager selection prompt before gnome-session pulls in gdm3
echo "shared/default-x-display-manager select gdm3" | debconf-set-selections

apt-get update && apt-get upgrade -y

apt-get install -y git make gettext wget unzip

# --no-install-recommends avoids pulling in unnecessary desktop metapackages
apt-get install -y --no-install-recommends \
    gnome-shell \
    gnome-session \
    gnome-tweaks \
    gnome-shell-extensions \
    gnome-menus \
    dbus-x11
