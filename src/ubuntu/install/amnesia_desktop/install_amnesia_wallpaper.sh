#!/usr/bin/env bash
set -ex

echo "Install Amnesia Desktop wallpaper"

# Brand palette from the Amnesia Desktop logo:
#   deep navy/indigo   #1e1b4b
#   medium violet      #5b48cc
#   teal ghost accent  #4ecdc4
#
# Wallpaper: dark navy-to-near-black radial gradient with subtle teal
# concentric rings that echo the onion-layer / ghost motif of the logo.

convert -size 1920x1080 \
  radial-gradient:"#1e1b4b"-"#0a0818" \
  \( -size 1920x1080 \
     xc:"none" \
     -fill "none" \
     -stroke "#4ecdc4" \
     -strokewidth 1 \
     -draw "circle 960,540 960,220" \
     -draw "circle 960,540 960,340" \
     -draw "circle 960,540 960,460" \
     -draw "circle 960,540 960,580" \
     -blur 0x6 \) \
  -compose Screen -composite \
  \( -size 1920x1080 \
     xc:"none" \
     -fill "none" \
     -stroke "#5b48cc" \
     -strokewidth 2 \
     -draw "circle 960,540 960,700" \
     -blur 0x12 \) \
  -compose Screen -composite \
  /usr/share/backgrounds/bg_amnesia.png

cp /usr/share/backgrounds/bg_amnesia.png /usr/share/backgrounds/bg_default.png
