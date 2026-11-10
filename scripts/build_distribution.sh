#!/usr/bin/env bash
# ==============================================================================
# scripts/build_distribution.sh — Rad Toolchain Distribution Builder & Publisher
# Produces only the single complete, all-in-one distribution archive:
#   rad-0.2.0-x86_64-unknown-linux-gnu.tar.gz
#
# Flags:
#   --upload, -u           Upload the release archive to GitHub Releases
#   --title <title>        Override release title (default: UTC date/time e.g. "11/5/2026 7:15 P.M.")
#   --desc, --notes <text> Release description / release notes
#   --tag <tag>            Release git tag (default: "v0.2.0")
#   -y, --yes              Non-interactive mode (auto-proceed with upload, ideal for AI agents)
#   -h, --help             Show help
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="0.2.3"
TARGET_TRIPLE="x86_64-unknown-linux-musl"
HOST_TRIPLE="x86_64-unknown-linux-musl"
REPO="GamerxIOEPB/rad-lang"

DIST_OUT="$ROOT_DIR/target/dist"
BUILD_TMP="$ROOT_DIR/target/dist_build"

DIST_NAME="rad-${VERSION}-linux-x86_64"
DIST_ROOT="$BUILD_TMP/$DIST_NAME"

DO_UPLOAD=0
AUTO_CONFIRM=0
RELEASE_TITLE=""
RELEASE_DESC=""
RELEASE_TAG="0.2.3"

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
         "$DIST_ROOT/lib/rad" \
         "$DIST_ROOT/lib/targets/$TARGET_TRIPLE" \
         "$DIST_ROOT/share/rad/LICENSES"

# ------------------------------------------------------------------------------
# 1. Build Hermetic Musl Toolchain Binaries
# ------------------------------------------------------------------------------
echo "==> [1/4] Building hermetic musl toolchain binaries..."

# 1.1 Compile static-pie radc via build_musl_compiler.sh (with selective LLVM)
bash "$SCRIPT_DIR/build_musl_compiler.sh"

# 1.2 Compile static-pie rad package manager using the new radc
"$ROOT_DIR/bin/radc" "$ROOT_DIR/src/tools/rad_pm/src/fmt.rad" "$ROOT_DIR/src/tools/rad_pm/src/lsp.rad" "$ROOT_DIR/src/tools/rad_pm/src/main.rad" -o "$ROOT_DIR/bin/rad" -O2
strip "$ROOT_DIR/bin/rad"

# 1.3 Rigorous ELF verification of core binaries
echo "==> Verifying binary properties (static-pie, zero dynamic dependencies)..."
for b in radc rad; do
    BIN_PATH="$ROOT_DIR/bin/$b"
    if [ ! -x "$BIN_PATH" ]; then
        echo "error: Expected binary $BIN_PATH missing or not executable" >&2
        exit 1
    fi
    FILE_INFO="$(file "$BIN_PATH")"
    if ! echo "$FILE_INFO" | grep -q "static-pie linked"; then
        echo "error: $BIN_PATH is not static-pie linked!" >&2
        exit 1
    fi
    if readelf -l "$BIN_PATH" | grep -q "INTERP"; then
        echo "error: $BIN_PATH contains PT_INTERP dynamic interpreter header!" >&2
        exit 1
    fi
    if readelf -d "$BIN_PATH" | grep -q "NEEDED"; then
        echo "error: $BIN_PATH contains DT_NEEDED shared library dependencies!" >&2
        exit 1
    fi
    echo "  [✓] $b: verified static-pie linked with zero external dependencies"
done

cp "$ROOT_DIR/bin/radc" "$DIST_ROOT/bin/radc"
cp "$ROOT_DIR/bin/rad" "$DIST_ROOT/bin/rad"
chmod 755 "$DIST_ROOT/bin"/*

# ------------------------------------------------------------------------------
# 2. Bundle Canonical Target Sysroot and Pure Rad Standard Library
# ------------------------------------------------------------------------------
echo "==> [2/4] Bundling canonical target sysroot and pure Rad standard library..."
SYSROOT_DIR="$ROOT_DIR/lib/targets/$TARGET_TRIPLE"
mkdir -p "$DIST_ROOT/lib/targets/$TARGET_TRIPLE/crt" "$DIST_ROOT/lib/targets/$TARGET_TRIPLE/lib"
cp -r "$SYSROOT_DIR/crt"/* "$DIST_ROOT/lib/targets/$TARGET_TRIPLE/crt/"
cp -r "$SYSROOT_DIR/lib"/* "$DIST_ROOT/lib/targets/$TARGET_TRIPLE/lib/"

# Standard library sources
cp -r "$ROOT_DIR/library/core" "$DIST_ROOT/lib/rad/"
cp -r "$ROOT_DIR/library/alloc" "$DIST_ROOT/lib/rad/"
cp -r "$ROOT_DIR/library/std" "$DIST_ROOT/lib/rad/"

# Documentation & top-level files
cp -f "$ROOT_DIR/README.md" "$DIST_ROOT/" 2>/dev/null || true
cp -f "$ROOT_DIR/LICENSE" "$DIST_ROOT/" 2>/dev/null || true

# Manifests and Licenses
cat << EOF > "$DIST_ROOT/share/rad/VERSION"
Rad Programming Language
Version: ${VERSION}
Commit:  $(git rev-parse HEAD 2>/dev/null || echo "release")
Built:   $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Host:    ${HOST_TRIPLE}
Target:  ${TARGET_TRIPLE}
EOF

cat << EOF > "$DIST_ROOT/share/rad/toolchain.toml"
[toolchain]
version = "${VERSION}"
channel = "stable"
host = "${HOST_TRIPLE}"
default_target = "${TARGET_TRIPLE}"

[components]
rad = { path = "bin/rad", role = "package_manager" }
radc = { path = "bin/radc", role = "compiler" }

[llvm]
version = "embedded-llvm-21-x86"
components = ["embedded-backend-x86", "embedded-lld"]
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
description = "Minimal self-contained Rad programming language toolchain (Static-PIE Linux x86_64)"

[components]
core = true
EOF

echo "Apache License 2.0 / MIT License" > "$DIST_ROOT/share/rad/LICENSES/LICENSE-RAD"
echo "LLVM Apache 2.0 with LLVM Exception" > "$DIST_ROOT/share/rad/LICENSES/LICENSE-LLVM"
echo "MIT License (Musl libc)" > "$DIST_ROOT/share/rad/LICENSES/LICENSE-MUSL"

# ------------------------------------------------------------------------------
# 3. Archive Unified Package
# ------------------------------------------------------------------------------
echo "==> [3/4] Packaging unified tarball..."

tar -czf "$DIST_OUT/${DIST_NAME}.tar.gz" -C "$BUILD_TMP" "$DIST_NAME"
sha256sum "$DIST_OUT/${DIST_NAME}.tar.gz" | awk '{print $1}' > "$DIST_OUT/${DIST_NAME}.tar.gz.sha256"
echo "  [✓] Created ${DIST_NAME}.tar.gz ($(du -h "$DIST_OUT/${DIST_NAME}.tar.gz" | awk '{print $1}'))"

# Copy VS Code extension if available
if [ -f "$ROOT_DIR/editors/vscode-rad/rad-utils-${VERSION}.vsix" ]; then
    cp "$ROOT_DIR/editors/vscode-rad/rad-utils-${VERSION}.vsix" "$DIST_OUT/"
    echo "  [✓] Bundled rad-utils-${VERSION}.vsix ($(du -h "$DIST_OUT/rad-utils-${VERSION}.vsix" | awk '{print $1}'))"
fi

# Generate SHA256SUMS manifest
(
    cd "$DIST_OUT"
    rm -f SHA256SUMS
    if [ -f "rad-utils-${VERSION}.vsix" ]; then
        sha256sum "${DIST_NAME}.tar.gz" "rad-utils-${VERSION}.vsix" > SHA256SUMS
    else
        sha256sum "${DIST_NAME}.tar.gz" > SHA256SUMS
    fi
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
    if [ -z "$RELEASE_TAG" ]; then
        RELEASE_TAG="v${VERSION}"
    fi

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
    UPLOAD_FILES=("$DIST_OUT/${DIST_NAME}.tar.gz" "$DIST_OUT/SHA256SUMS")
    if [ -f "$DIST_OUT/rad-utils-${VERSION}.vsix" ]; then
        UPLOAD_FILES+=("$DIST_OUT/rad-utils-${VERSION}.vsix")
    fi

    if command -v gh >/dev/null 2>&1; then
        if gh release view "$RELEASE_TAG" --repo "$REPO" >/dev/null 2>&1; then
            echo "  -> Updating existing release $RELEASE_TAG..."
            gh release upload "$RELEASE_TAG" \
                "${UPLOAD_FILES[@]}" \
                --clobber --repo "$REPO"
            gh release edit "$RELEASE_TAG" \
                --title "$RELEASE_TITLE" \
                --notes "$RELEASE_DESC" \
                --latest --repo "$REPO"
        else
            echo "  -> Creating release $RELEASE_TAG..."
            gh release create "$RELEASE_TAG" \
                "${UPLOAD_FILES[@]}" \
                --repo "$REPO" \
                --title "$RELEASE_TITLE" \
                --notes "$RELEASE_DESC" \
                --latest
        fi

        echo "  [✓] Release uploaded successfully to GitHub!"
        echo "  URL: https://github.com/${REPO}/releases/tag/${RELEASE_TAG}"
    else
        echo "error: GitHub CLI ('gh') is not installed. Please install 'gh' to upload releases." >&2
        exit 1
    fi
fi
