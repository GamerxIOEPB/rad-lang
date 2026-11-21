#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== Building Pure-Rad Native Desktop GUI Demo ==="
echo "Zero C bridge files, zero -lwayland-client, zero -lX11."

# Compile pure Rad executable with radc
RADC="../../../bin/radc"
if [ ! -x "$RADC" ]; then
    RADC="$(which radc 2>/dev/null || echo "$HOME/.rad/bin/radc")"
fi
"$RADC" main.rad -o rad_wayland_demo

echo "=== Build Complete: tests/demos/wayland_gui/rad_wayland_demo ==="
echo "Run interactively: ./tests/demos/wayland_gui/rad_wayland_demo"
echo "Run automated test: RAD_DEMO_FRAMES=60 ./tests/demos/wayland_gui/rad_wayland_demo"
