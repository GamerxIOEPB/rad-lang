#!/usr/bin/env bash
# ==============================================================================
# scripts/fetch_sysroot.sh — Fetch prebuilt static target libraries
# Downloads canonical musl target sysroot and static archives (libc.a, libsqlite3.a)
# from official GitHub Releases when building from source.
# ==============================================================================
set -euo pipefail

REPO="${RAD_REPO:-GamerxIOEPB/rad-lang}"
VERSION="${RAD_VERSION:-0.2.5}"
TARGET_TRIPLE="${TARGET_TRIPLE:-x86_64-unknown-linux-musl}"
SYSROOT_DIR="lib/targets/${TARGET_TRIPLE}"
LIB_DIR="${SYSROOT_DIR}/lib"
CRT_DIR="${SYSROOT_DIR}/crt"

echo "==> Checking target sysroot libraries in ${SYSROOT_DIR}..."

# Check if essential static libraries already exist
if [[ -f "${LIB_DIR}/libc.a" && -f "${CRT_DIR}/rcrt1.o" && -f "${LIB_DIR}/libsqlite3.a" ]]; then
    echo "  [✓] Target sysroot (${TARGET_TRIPLE}) already present and complete."
    exit 0
fi

echo "==> Fetching target sysroot for ${TARGET_TRIPLE} (v${VERSION})..."
mkdir -p "${LIB_DIR}" "${CRT_DIR}"

TMP_DIR="$(mktemp -d /tmp/rad-sysroot.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

ARCHIVE_NAME="rad-${VERSION}-linux-x86_64.tar.xz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE_NAME}"

# Attempt download via gh, curl, or wget
DOWNLOADED=0
if command -v gh >/dev/null 2>&1; then
    echo "  -> Downloading via GitHub CLI..."
    if gh release download "${VERSION}" --repo "${REPO}" --pattern "${ARCHIVE_NAME}" --dir "${TMP_DIR}" 2>/dev/null; then
        DOWNLOADED=1
    fi
fi

if [[ "$DOWNLOADED" -eq 0 ]] && command -v curl >/dev/null 2>&1; then
    echo "  -> Downloading from ${DOWNLOAD_URL}..."
    if curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${ARCHIVE_NAME}"; then
        DOWNLOADED=1
    fi
fi

if [[ "$DOWNLOADED" -eq 0 ]] && command -v wget >/dev/null 2>&1; then
    echo "  -> Downloading via wget..."
    if wget -q "${DOWNLOAD_URL}" -O "${TMP_DIR}/${ARCHIVE_NAME}"; then
        DOWNLOADED=1
    fi
fi

if [[ "$DOWNLOADED" -eq 1 && -f "${TMP_DIR}/${ARCHIVE_NAME}" ]]; then
    echo "  -> Extracting sysroot components..."
    tar -xf "${TMP_DIR}/${ARCHIVE_NAME}" -C "${TMP_DIR}"
    if [[ -d "${TMP_DIR}/lib/targets/${TARGET_TRIPLE}" ]]; then
        cp -rf "${TMP_DIR}/lib/targets/${TARGET_TRIPLE}"/* "${SYSROOT_DIR}/"
        echo "  [✓] Sysroot libraries installed successfully to ${SYSROOT_DIR}."
        exit 0
    fi
fi

# Fallback: check ~/.rad installation
if [[ -d "${HOME}/.rad/lib/targets/${TARGET_TRIPLE}" ]]; then
    echo "  -> Copying sysroot from local ~/.rad installation..."
    cp -rf "${HOME}/.rad/lib/targets/${TARGET_TRIPLE}"/* "${SYSROOT_DIR}/"
    echo "  [✓] Sysroot restored from ~/.rad."
    exit 0
fi

echo "error: failed to fetch target sysroot libraries for ${TARGET_TRIPLE}." >&2
exit 1
