#!/bin/bash
# Launches GNOME Shell session on the Kasm VNC display.
# D-Bus is already running (dbus-launch was called in vnc_startup.sh).
# START_XFCE4=0 prevents XFCE from starting, so this is the sole WM.
export DISPLAY=:1
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=GNOME
export GNOME_SHELL_SESSION_MODE=ubuntu

exec gnome-session
