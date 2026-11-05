#!/usr/bin/env bash
# ==============================================================================
# scripts/build_distribution.sh — Rad Toolchain Distribution Builder & Publisher
# Produces only the single complete, all-in-one distribution archive:
#   rad-0.1.0-x86_64-unknown-linux-gnu.tar.gz
#
# Flags:
#   --upload, -u           Upload the release archive to GitHub Releases
#   --title <title>        Override release title (default: UTC date/time e.g. "11/5/2026 7:15 P.M.")
#   --desc, --notes <text> Release description / release notes
#   --tag <tag>            Release git tag (default: "v0.1.0")
#   -y, --yes              Non-interactive mode (auto-proceed with upload, ideal for AI agents)
#   -h, --help             Show help
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="0.1.0"
HOST_TRIPLE="x86_64-unknown-linux-gnu"
TARGET_TRIPLE="x86_64-unknown-linux-musl"
REPO="GamerxIOEPB/rad-lang"

DIST_OUT="$ROOT_DIR/target/dist"
BUILD_TMP="$ROOT_DIR/target/dist_build"

DIST_NAME="rad-${VERSION}-${HOST_TRIPLE}"
DIST_ROOT="$BUILD_TMP/$DIST_NAME"

DO_UPLOAD=0
AUTO_CONFIRM=0
RELEASE_TITLE=""
RELEASE_DESC=""
RELEASE_TAG="v${VERSION}"

# Parse command line options
while [ $# -gt 0 ]; do
    case "$1" in
        -u|--upload|--release)
            DO_UPLOAD=1
            shift
            ;;
        --title)
            if [ -z "${2:-}" ]; then
                echo "error: --title requires an argument" >&2
                exit 1
            fi
            RELEASE_TITLE="$2"
            shift 2
            ;;
        --desc|--notes)
            if [ -z "${2:-}" ]; then
                echo "error: --desc requires an argument" >&2
                exit 1
            fi
            RELEASE_DESC="$2"
            shift 2
            ;;
        --tag)
            if [ -z "${2:-}" ]; then
                echo "error: --tag requires an argument" >&2
                exit 1
            fi
            RELEASE_TAG="$2"
            shift 2
            ;;
        -y|--yes)
            AUTO_CONFIRM=1
            shift
            ;;
        -h|--help)
            cat << EOF
Usage: build_distribution.sh [options]

Options:
    -u, --upload           Upload the built package to GitHub Releases
    --title <title>        Release title (default: exact UTC date/time e.g. "11/5/2026 7:15 P.M.")
    --desc, --notes <text> Release description / notes
    --tag <tag>            Release git tag (default: "v${VERSION}")
    -y, --yes              Non-interactive confirmation (auto-proceed with upload)
    -h, --help             Show this help message
EOF
            exit 0
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

echo "======================================================================"
echo " Building Rad Complete Toolchain Distribution v${VERSION}"
echo " Host:    ${HOST_TRIPLE}"
echo " Target:  ${TARGET_TRIPLE}"
echo " Archive: ${DIST_NAME}.tar.gz"
echo "======================================================================"

rm -rf "$BUILD_TMP" "$DIST_OUT"
mkdir -p "$DIST_OUT" "$BUILD_TMP"
mkdir -p "$DIST_ROOT/bin" \
         "$DIST_ROOT/lib/llvm" \
         "$DIST_ROOT/lib/rad" \
         "$DIST_ROOT/lib/targets/$TARGET_TRIPLE" \
         "$DIST_ROOT/lib/targets/$TARGET_TRIPLE/include" \
         "$DIST_ROOT/lib/cxx/$TARGET_TRIPLE/lib" \
         "$DIST_ROOT/lib/cxx/$TARGET_TRIPLE/include" \
         "$DIST_ROOT/share/rad/LICENSES"

# ------------------------------------------------------------------------------
# 1. Build Toolchain Binaries via Makefile
# ------------------------------------------------------------------------------
echo "==> [1/4] Building production binaries via Makefile..."
make -C "$ROOT_DIR" all

cp "$ROOT_DIR/bin/radc" "$DIST_ROOT/bin/radc"
cp "$ROOT_DIR/bin/rad" "$DIST_ROOT/bin/rad"
cp "$ROOT_DIR/bin/rad-llc" "$DIST_ROOT/bin/rad-llc"
cp "$ROOT_DIR/bin/rad-lld" "$DIST_ROOT/bin/rad-lld"
cp "$ROOT_DIR/bin/rad-llc" "$DIST_ROOT/bin/rad-clang"
cp "$ROOT_DIR/bin/rad-llc" "$DIST_ROOT/bin/rad-clang++"
chmod 755 "$DIST_ROOT/bin"/*

# ------------------------------------------------------------------------------
# 2. Assemble LLVM Runtime Libraries and Real Executables
# ------------------------------------------------------------------------------
echo "==> [2/4] Bundling host LLVM runtime components..."
cp /usr/bin/llc "$DIST_ROOT/lib/llvm/llc_real"
cp /usr/bin/ld.lld "$DIST_ROOT/lib/llvm/ld.lld_real"
ln -sf ld.lld_real "$DIST_ROOT/lib/llvm/ld.lld"
chmod 755 "$DIST_ROOT/lib/llvm/llc_real" "$DIST_ROOT/lib/llvm/ld.lld_real"

# Copy clang / clang++ binaries
if [ -x /usr/bin/clang ]; then
    cp -L /usr/bin/clang "$DIST_ROOT/lib/llvm/clang"
    ln -sf clang "$DIST_ROOT/lib/llvm/clang++"
    chmod 755 "$DIST_ROOT/lib/llvm/clang"
fi

# Copy required LLVM shared libraries from system
cp -P /usr/lib/libLLVM*.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/liblld*.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/libclang-cpp*.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/libzstd.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/libxml2.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/libedit.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/libncursesw.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/libicu*.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true
cp -P /usr/lib/libffi.so* "$DIST_ROOT/lib/llvm/" 2>/dev/null || true

# Clang resource headers
if [ -d /usr/lib/clang ]; then
    cp -r /usr/lib/clang "$DIST_ROOT/lib/"
    ln -sf . "$DIST_ROOT/lib/lib"
fi

# ------------------------------------------------------------------------------
# 3. Bundle Canonical Target Sysroot, Standard Library, C/C++ Assets
# ------------------------------------------------------------------------------
echo "==> [3/4] Bundling canonical target sysroot, standard library, and C/C++ assets..."
SYSROOT_DIR="$ROOT_DIR/lib/targets/$TARGET_TRIPLE"
cp -r "$SYSROOT_DIR"/* "$DIST_ROOT/lib/targets/$TARGET_TRIPLE/"

# Standard library sources
cp -r "$ROOT_DIR/library/core" "$DIST_ROOT/lib/rad/"
cp -r "$ROOT_DIR/library/alloc" "$DIST_ROOT/lib/rad/"
cp -r "$ROOT_DIR/library/std" "$DIST_ROOT/lib/rad/"

# C headers
cp -r /usr/include/* "$DIST_ROOT/lib/targets/$TARGET_TRIPLE/include/" 2>/dev/null || true

# C++ static libraries and headers
if [ -f /usr/lib/gcc/x86_64-pc-linux-gnu/16/libstdc++.a ]; then
    cp /usr/lib/gcc/x86_64-pc-linux-gnu/16/libstdc++.a "$DIST_ROOT/lib/cxx/$TARGET_TRIPLE/lib/"
fi
cp "$SYSROOT_DIR/lib/libunwind.a" "$DIST_ROOT/lib/cxx/$TARGET_TRIPLE/lib/" 2>/dev/null || true
if [ -d /usr/include/c++/16 ]; then
    cp -r /usr/include/c++/16/* "$DIST_ROOT/lib/cxx/$TARGET_TRIPLE/include/" 2>/dev/null || true
fi

# Manifests and Licenses
cat << EOF > "$DIST_ROOT/share/rad/VERSION"
Rad Programming Language
Version: ${VERSION}
Commit:  $(git rev-parse HEAD 2>/dev/null || echo "release")
Built:   $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Host:    ${HOST_TRIPLE}
Target:  ${TARGET_TRIPLE}
EOF

cat << 'EOF' > "$DIST_ROOT/share/rad/toolchain.toml"
[toolchain]
version = "0.1.0"
channel = "stable"
host = "x86_64-unknown-linux-gnu"
default_target = "x86_64-unknown-linux-musl"

[components]
rad = { path = "bin/rad", role = "package_manager" }
radc = { path = "bin/radc", role = "compiler" }
rad-llc = { path = "bin/rad-llc", role = "backend" }
rad-lld = { path = "bin/rad-lld", role = "linker" }
rad-clang = { path = "bin/rad-clang", role = "c_compiler" }
rad-clangxx = { path = "bin/rad-clang++", role = "cxx_compiler" }

[llvm]
version = "23.1.4"
components = ["llc", "lld"]
EOF

cat << 'EOF' > "$DIST_ROOT/share/rad/targets.toml"
["x86_64-unknown-linux-musl"]
arch = "x86_64"
os = "linux"
env = "musl"
format = "elf"
static_pie = true
linker_flavor = "gnu"
linker_flags = [
    "-flavor", "gnu",
    "-m", "elf_x86_64",
    "-static",
    "-pie",
    "--no-dynamic-linker",
    "-z", "text",
    "-z", "noexecstack"
]
crt_objects = ["rcrt1.o", "crti.o", "crtn.o"]
libraries = ["libc.a", "libclang_rt.builtins-x86_64.a"]
EOF

cat << EOF > "$DIST_ROOT/share/rad/manifest.toml"
[package]
name = "rad"
version = "${VERSION}"
target = "${TARGET_TRIPLE}"
host = "${HOST_TRIPLE}"
description = "Complete self-contained Rad programming language toolchain"

[components]
core = true
c_pack = true
cxx_pack = true
EOF

echo "Apache License 2.0 / MIT License" > "$DIST_ROOT/share/rad/LICENSES/LICENSE-RAD"
echo "LLVM Apache 2.0 with LLVM Exception" > "$DIST_ROOT/share/rad/LICENSES/LICENSE-LLVM"
echo "MIT License (Musl libc)" > "$DIST_ROOT/share/rad/LICENSES/LICENSE-MUSL"

# ------------------------------------------------------------------------------
# 4. Archive Unified Single Package
# ------------------------------------------------------------------------------
echo "==> [4/4] Packaging unified tarball..."

tar -czf "$DIST_OUT/${DIST_NAME}.tar.gz" -C "$BUILD_TMP" "$DIST_NAME"
sha256sum "$DIST_OUT/${DIST_NAME}.tar.gz" | awk '{print $1}' > "$DIST_OUT/${DIST_NAME}.tar.gz.sha256"
echo "  [✓] Created ${DIST_NAME}.tar.gz ($(du -h "$DIST_OUT/${DIST_NAME}.tar.gz" | awk '{print $1}'))"

# Generate unified SHA256SUMS manifest
(
    cd "$DIST_OUT"
    sha256sum "${DIST_NAME}.tar.gz" > SHA256SUMS
)
echo "  [✓] Generated SHA256SUMS manifest"

# Clean up temporary staging directory
rm -rf "$BUILD_TMP"

echo ""
echo "Distribution build complete!"
echo "Artifact placed in: $DIST_OUT"
ls -lh "$DIST_OUT"

# ------------------------------------------------------------------------------
# 5. Upload to GitHub Releases (Optional / Prompted)
# ------------------------------------------------------------------------------
if [ "$DO_UPLOAD" -eq 1 ]; then
    # Calculate default exact UTC date and time: M/D/YYYY H:MM A.M./P.M.
    if [ -z "$RELEASE_TITLE" ]; then
        p_val=$(date -u +"%p" | sed 's/AM/A.M./;s/PM/P.M./')
        date_str=$(date -u +"%-m/%-d/%Y %-I:%M")
        RELEASE_TITLE="$date_str $p_val"
    fi

    # Interactive description prompt if not provided via CLI
    if [ -z "$RELEASE_DESC" ]; then
        if [ -t 0 ] && [ "$AUTO_CONFIRM" -eq 0 ]; then
            echo ""
            echo "Release title: $RELEASE_TITLE"
            read -r -p "Enter release description (leave blank for default): " user_desc
            if [ -n "$user_desc" ]; then
                RELEASE_DESC="$user_desc"
            else
                RELEASE_DESC="Rad ${VERSION} standalone toolchain release (${RELEASE_TITLE})."
            fi
        else
            RELEASE_DESC="Rad ${VERSION} standalone toolchain release (${RELEASE_TITLE})."
        fi
    fi

    # Interactive Proceed(y/n) confirmation unless -y/--yes was passed
    if [ "$AUTO_CONFIRM" -eq 0 ]; then
        echo ""
        echo "======================================================================"
        echo " GitHub Release Upload Summary"
        echo "   Repository:  $REPO"
        echo "   Tag:         $RELEASE_TAG"
        echo "   Title:       $RELEASE_TITLE"
        echo "   Asset:       $DIST_OUT/${DIST_NAME}.tar.gz"
        echo "   Description: $RELEASE_DESC"
        echo "======================================================================"
        read -r -p "Proceed with upload? (y/n)> " proceed
        if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
            echo "Upload cancelled."
            exit 0
        fi
    fi

    echo ""
    echo "==> Uploading release to GitHub (${REPO})..."
    if command -v gh >/dev/null 2>&1; then
        # Check if release tag exists
        if gh release view "$RELEASE_TAG" --repo "$REPO" >/dev/null 2>&1; then
            echo "  -> Updating existing release $RELEASE_TAG..."
            gh release upload "$RELEASE_TAG" "$DIST_OUT/${DIST_NAME}.tar.gz" "$DIST_OUT/SHA256SUMS" \
                --repo "$REPO" --clobber
            gh release edit "$RELEASE_TAG" --repo "$REPO" --title "$RELEASE_TITLE" --notes "$RELEASE_DESC" --draft=false
        else
            echo "  -> Creating new release $RELEASE_TAG..."
            gh release create "$RELEASE_TAG" \
                "$DIST_OUT/${DIST_NAME}.tar.gz" \
                "$DIST_OUT/SHA256SUMS" \
                --repo "$REPO" \
                --title "$RELEASE_TITLE" \
                --notes "$RELEASE_DESC"
        fi
        echo "  [✓] Release uploaded successfully to GitHub!"
        echo "  URL: https://github.com/${REPO}/releases/tag/${RELEASE_TAG}"
    else
        echo "error: GitHub CLI ('gh') is not installed. Please install 'gh' to upload releases." >&2
        exit 1
    fi
fi
