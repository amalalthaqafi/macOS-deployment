#!/bin/bash

set -euo pipefail

FONT_DIR="/Library/Fonts"
TMP_DIR="/tmp/installFonts"

mkdir -p "$TMP_DIR"
mkdir -p "$FONT_DIR"

fonts=(
  "Cairo-VariableFont_slnt,wght.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Cairo-VariableFont_slnt,wght.ttf"
  "Inter-Italic-VariableFont_opsz,wght.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Inter-Italic-VariableFont_opsz,wght.ttf"
  "Inter-VariableFont_opsz,wght.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Inter-VariableFont_opsz,wght.ttf"
  "SpaceGrotesk-VariableFont_wght.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/SpaceGrotesk-VariableFont_wght.ttf"
  "Tajawal-Black.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Black.ttf"
  "Tajawal-Bold.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Bold.ttf"
  "Tajawal-ExtraBold.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-ExtraBold.ttf"
  "Tajawal-ExtraLight.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-ExtraLight.ttf"
  "Tajawal-Light.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Light.ttf"
  "Tajawal-Medium.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Medium.ttf"
  "Tajawal-Regular.ttf|https://raw.githubusercontent.com/amalalthaqafi/macOS-deployment/main/fonts/Tajawal-Regular.ttf"
)

installed_any=0

for item in "${fonts[@]}"; do
  font_name="${item%%|*}"
  font_url="${item##*|}"
  tmp_file="${TMP_DIR}/${font_name}"
  dest_file="${FONT_DIR}/${font_name}"

  if [ -f "$dest_file" ]; then
    echo "Font already exists: $font_name"
    continue
  fi

  echo "Downloading $font_name ..."
  if curl -L -f -o "$tmp_file" "$font_url"; then
    cp "$tmp_file" "$dest_file"
    chown root:wheel "$dest_file"
    chmod 644 "$dest_file"
    echo "Installed: $font_name"
    installed_any=1
  else
    echo "Failed to download: $font_name"
  fi

  rm -f "$tmp_file"
done

if [ "$installed_any" -eq 1 ]; then
  echo "Refreshing font cache..."
  atsutil databases -remove || true
  atsutil server -shutdown || true
  atsutil server -ping || true
fi

rm -rf "$TMP_DIR"

echo "Font installation process completed."
exit 0