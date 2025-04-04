#!/bin/bash

WEBSTORM_VER_DATE="2024.3.5"

cd /tmp
wget -q -O webstorm.tar.gz "https://download.jetbrains.com/webstorm/WebStorm-${WEBSTORM_VER_DATE}.tar.gz"
tar -xzf webstorm.tar.gz --one-top-level=/opt/webstorm --strip-components=1 \
    && rm webstorm.tar.gz


cp $INST_SCRIPTS/webstorm/webstorm.desktop $HOME/Desktop/
cp $INST_SCRIPTS/webstorm/webstorm.desktop /usr/share/applications/

chmod +x $HOME/Desktop/webstorm.desktop
chmod +x /usr/share/applications/webstorm.desktop
