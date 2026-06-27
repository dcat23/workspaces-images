#!/usr/bin/env bash
set -ex

# During Docker build HOME=/home/kasm-default-profile, but at runtime HOME=/home/kasm-user.
# The upstream installer hardcodes the build-time HOME into ALIAS_CLI_DIR and the source path
# in .bashrc, so new aliases written to $ALIAS_CLI_DIR/alias_commands during a session would
# land outside the persistent profile path and be lost on logout.
# We patch .bashrc after install so both references use $HOME at runtime instead.
bash <(wget -qO- https://raw.githubusercontent.com/dcat23/aliascli/main/install.sh)

sed -i "s|${HOME}/.aliascli|\$HOME/.aliascli|g" "$HOME/.bashrc"

source "$HOME/.bashrc"