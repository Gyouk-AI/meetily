#!/usr/bin/env bash
#
# install-linux-deps.sh
#
# One-shot helper to install the system packages needed to build Meetily on Linux.
# Supports common distros. Run this (or the commands it prints) before ./build-gpu.sh or pnpm tauri:build.
#
# Usage:
#   bash scripts/install-linux-deps.sh
#   bash scripts/install-linux-deps.sh --dry-run   # only show commands
#

set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
  DRY_RUN=true
  echo "== DRY RUN: commands will be printed but not executed =="
fi

run() {
  if $DRY_RUN; then
    echo "  $*" 
  else
    echo "→ $*"
    eval "$@"
  fi
}

echo "🐧 Meetily Linux dependency installer"
echo "This will install packages required for Tauri (WebKit, GTK, bundlers), audio, and AppImage support."
echo ""

if command -v apt-get >/dev/null 2>&1; then
  echo "Detected: Debian / Ubuntu / Pop!_OS / Mint (apt)"
  echo ""
  run "sudo apt-get update"
  run "sudo apt-get install -y \
    build-essential cmake git \
    libwebkit2gtk-4.1-dev libgtk-3-dev \
    libayatana-appindicator3-dev librsvg2-dev patchelf \
    libasound2-dev libpipewire-0.3-dev libpulse-dev \
    libx11-dev libxtst-dev libxrandr-dev \
    libfuse2 fuse \
    libopenblas-dev"

  echo ""
  echo "✅ Done. You can now cd frontend && pnpm install && ./build-gpu.sh"
  echo "   The resulting AppImage will be under frontend/src-tauri/target/.../bundle/appimage/"

elif command -v dnf >/dev/null 2>&1; then
  echo "Detected: Fedora / RHEL / Rocky / AlmaLinux (dnf)"
  echo ""
  run "sudo dnf install -y \
    gcc-c++ cmake git \
    webkit2gtk4.1-devel gtk3-devel \
    libappindicator-gtk3-devel librsvg2-devel patchelf \
    alsa-lib-devel pipewire-devel pulseaudio-libs-devel \
    libX11-devel libXtst-devel libXrandr-devel openssl-devel \
    fuse fuse-libs \
    openblas-devel"

  echo ""
  echo "✅ Done. You can now cd frontend && pnpm install && ./build-gpu.sh"
  echo "   The resulting AppImage will be under frontend/src-tauri/target/.../bundle/appimage/"
  echo ""
  echo "Tip: On some Fedora setups you may still need:"
  echo "   sudo dnf install fuse fuse-libs   (already attempted above)"

elif command -v pacman >/dev/null 2>&1; then
  echo "Detected: Arch / Manjaro (pacman)"
  echo ""
  run "sudo pacman -Syu --needed --noconfirm \
    base-devel cmake git \
    webkit2gtk-4.1 gtk3 \
    libappindicator-gtk3 librsvg patchelf \
    alsa-lib pipewire libpulse \
    libx11 libxtst libxrandr \
    fuse2 \
    openblas"

  echo ""
  echo "✅ Done. You can now cd frontend && pnpm install && ./build-gpu.sh"

else
  echo "❌ Could not detect a supported package manager (apt, dnf, or pacman)."
  echo ""
  echo "Please follow the manual instructions in:"
  echo "  docs/building_in_linux.md"
  echo "  docs/BUILDING.md"
  exit 1
fi

echo ""
echo "After building, the easiest Linux artifact is the AppImage:"
echo "  chmod +x Meetily_*.AppImage"
echo "  ./Meetily_*.AppImage"
echo ""
echo "Happy transcribing! 🎙️"
