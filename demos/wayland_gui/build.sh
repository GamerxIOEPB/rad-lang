#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== Building Rad Native Wayland GUI Demo ==="

# 1. Compile XDG-shell protocol object
clang -O2 -c xdg-shell-protocol.c -o xdg-shell-protocol.o

# 2. Compile Wayland native bridge & rasterizer
clang -O2 -c wayland_native.c -I. -o wayland_native.o

# 3. Compile Rad executable with radc
../../bin/radc main.rad wayland_native.o xdg-shell-protocol.o --linker "clang -lwayland-client" -o rad_wayland_demo

echo "=== Build Complete: demos/wayland_gui/rad_wayland_demo ==="
echo "Run interactively: ./demos/wayland_gui/rad_wayland_demo"
echo "Run automated test: RAD_DEMO_FRAMES=60 ./demos/wayland_gui/rad_wayland_demo"
