#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== Building Pure-Rad Native Desktop GUI Demo ==="
echo "Zero C bridge files, zero -lwayland-client, zero -lX11."

# Compile pure Rad executable with radc
../../bin/radc main.rad -o rad_wayland_demo

echo "=== Build Complete: demos/wayland_gui/rad_wayland_demo ==="
echo "Run interactively: ./demos/wayland_gui/rad_wayland_demo"
echo "Run automated test: RAD_DEMO_FRAMES=60 ./demos/wayland_gui/rad_wayland_demo"
