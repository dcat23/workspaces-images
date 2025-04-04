#!/bin/bash

INTELLIJ_VER_DATE="2024.3.5"

cd /tmp
wget -q -O intellij.tar.gz "https://download.jetbrains.com/idea/ideaIU-${INTELLIJ_VER_DATE}.tar.gz"
tar -xzf intellij.tar.gz --one-top-level=/opt/idea-IU --strip-components=1

cp $INST_SCRIPTS/intellij/intellij.desktop $HOME/Desktop/
cp $INST_SCRIPTS/intellij/intellij.desktop /usr/share/applications/

chmod +x $HOME/Desktop/intellij.desktop /usr/share/applications/intellij.desktop
