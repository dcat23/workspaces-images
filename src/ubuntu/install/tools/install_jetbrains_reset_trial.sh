#!/usr/bin/env bash
set -ex

INSTALL_DIR="$HOME/.jetbrains-reset-trial"

git clone https://github.com/sandymandy12/jetbrains-reset-trial.git $INSTALL_DIR

chmod +x $INSTALL_DIR/linux/runme.sh
