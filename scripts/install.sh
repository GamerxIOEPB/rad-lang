#!/bin/sh
# ==============================================================================
# install.sh — Official Installer for the Rad Programming Language Toolchain
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/GamerxIOEPB/rad-lang/main/scripts/install.sh | sh
# ==============================================================================

set -eu

# Default configuration
DEFAULT_VERSION="0.2.1"
DEFAULT_REPO="GamerxIOEPB/rad-lang"
DEFAULT_RAD_HOME="$HOME/.rad"

VERSION="${VERSION:-$DEFAULT_VERSION}"
VERSION="${VERSION#v}"
VERSION_EXPLICIT=0
REPO="$DEFAULT_REPO"
RAD_HOME="${RAD_HOME:-$DEFAULT_RAD_HOME}"
PACKAGE_TYPE="full"   # "full" or "core"
MODIFY_PATH=1
UNATTENDED=0
OFFLINE_MODE=0

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

# ANSI formatting (fallback to plain text if not a tty)
if [ -t 1 ]; then
    BOLD="\033[1m"
    GREEN="\033[32m"
    RED="\033[31m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
    CYAN="\033[36m"
    RESET="\033[0m"
else
    BOLD=""
    GREEN=""
    RED=""
    YELLOW=""
    BLUE=""
    CYAN=""
    RESET=""
fi

log_info() {
    printf "${CYAN}==>${RESET} ${BOLD}%s${RESET}\n" "$1"
}

log_step() {
    printf "  ${BLUE}->${RESET} %s\n" "$1"
}

log_success() {
    printf "  ${GREEN}[✓]${RESET} %s\n" "$1"
}

log_warn() {
    printf "  ${YELLOW}[WARN]${RESET} %s\n" "$1"
}

log_error() {
    printf "${RED}error:${RESET} %s\n" "$1" >&2
}

list_versions() {
    REPO="${RAD_REPO:-$REPO}"
    printf "${BOLD}Available Rad Toolchain Releases:${RESET}\n\n"

    FETCHED=""
    if command -v curl >/dev/null 2>&1; then
        FETCHED="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' | sed -E 's/^v//' || true)"
    elif command -v wget >/dev/null 2>&1; then
        FETCHED="$(wget -qO- "https://api.github.com/repos/${REPO}/releases" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' | sed -E 's/^v//' || true)"
    fi

    if [ -n "$FETCHED" ]; then
        FIRST=1
        for ver in $FETCHED; do
            if [ "$FIRST" -eq 1 ]; then
                printf "  * ${GREEN}%s${RESET} (latest)\n" "$ver"
                FIRST=0
            else
                printf "  * %s\n" "$ver"
            fi
        done
    else
        printf "  * ${GREEN}0.2.1${RESET} (latest)\n"
        printf "  * 0.2.0\n"
        printf "  * 0.1.0\n"
    fi

    printf "\nTo install a specific version, run:\n"
    printf "  curl -fsSL https://raw.githubusercontent.com/${REPO}/main/scripts/install.sh | sh -s -- --version <version>\n\n"
}

validate_version() {
    REQ_VER="$1"

    # Known stable releases
    case "$REQ_VER" in
        "0.2.1"|"0.2.0"|"0.1.0")
            return 0
            ;;
    esac

    if [ "$OFFLINE_MODE" -eq 1 ]; then
        return 0
    fi

    # Probe GitHub releases for the requested version tag
    REPO="${RAD_REPO:-$REPO}"
    CHECK_URL="https://github.com/${REPO}/releases/tag/${REQ_VER}"
    CHECK_URL_V="https://github.com/${REPO}/releases/tag/v${REQ_VER}"
    EXISTS=0

    if command -v curl >/dev/null 2>&1; then
        if curl -fsIL "$CHECK_URL" >/dev/null 2>&1 || curl -fsIL "$CHECK_URL_V" >/dev/null 2>&1; then
            EXISTS=1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget --spider -q "$CHECK_URL" 2>/dev/null || wget --spider -q "$CHECK_URL_V" 2>/dev/null; then
            EXISTS=1
        fi
    fi

    if [ "$EXISTS" -ne 1 ]; then
        log_error "Version '${REQ_VER}' is not a valid or published Rad release."
        printf "\n${BOLD}Available releases:${RESET}\n"
        printf "  * 0.2.1 (latest)\n"
        printf "  * 0.2.0\n"
        printf "  * 0.1.0\n\n"
        printf "Run '$0 --list' to view all available releases.\n\n"
        exit 1
    fi
}

print_help() {
    cat << EOF
Rad Programming Language Installer

Usage:
    install.sh [options]

Options:
    -h, --help              Show this help message and exit
    -l, --list              List available Rad releases and exit
    -v, --version <version> Specify Rad version to install (default: ${DEFAULT_VERSION})
    -p, --prefix <dir>      Installation directory (default: ~/.rad, or \$RAD_HOME)
    --core                  Install minimal core toolchain only (default: full toolchain)
    --full                  Install complete toolchain with C/C++ packs (default)
    --offline, offline      Install directly from local Rad repository without downloading
    --no-modify-path        Do not configure PATH in shell startup files
    -y, --yes               Run non-interactively without prompting

Environment Variables:
    RAD_HOME                Installation directory prefix
    RAD_DIST_DIR            Local directory containing release archives for offline install
    RAD_RELEASE_URL         Custom base URL for release downloads
    RAD_REPO                GitHub repository owner/repo (default: ${DEFAULT_REPO})

Examples:
    # Install the latest stable release (v0.2.1):
    curl -fsSL https://raw.githubusercontent.com/${DEFAULT_REPO}/main/scripts/install.sh | sh

    # Install a specific version (e.g. v0.2.0):
    curl -fsSL https://raw.githubusercontent.com/${DEFAULT_REPO}/main/scripts/install.sh | sh -s -- --version 0.2.0

    # List all available releases:
    curl -fsSL https://raw.githubusercontent.com/${DEFAULT_REPO}/main/scripts/install.sh | sh -s -- --list
EOF
}

# Parse command line options
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -l|--list)
            list_versions
            exit 0
            ;;
        -v|--version)
            if [ -z "${2:-}" ]; then
                log_error "Option --version requires an argument"
                exit 1
            fi
            VERSION="${2#v}"
            VERSION_EXPLICIT=1
            shift 2
            ;;
        -p|--prefix)
            if [ -z "${2:-}" ]; then
                log_error "Option --prefix requires an argument"
                exit 1
            fi
            RAD_HOME="$2"
            shift 2
            ;;
        --core)
            PACKAGE_TYPE="core"
            shift
            ;;
        --full)
            PACKAGE_TYPE="full"
            shift
            ;;
        --offline|offline)
            OFFLINE_MODE=1
            shift
            ;;
        --no-modify-path)
            MODIFY_PATH=0
            shift
            ;;
        -y|--yes)
            UNATTENDED=1
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

REPO="${RAD_REPO:-$REPO}"

# Validate requested version
validate_version "$VERSION"

# 1. Platform Verification
if [ "$OS" != "Linux" ] || [ "$ARCH" != "x86_64" ]; then
    log_error "Rad toolchain currently supports Linux x86-64 (linux-x86_64)."
    log_error "Detected platform: OS='${OS}', Arch='${ARCH}'"
    log_error "Please build from source or report this at https://github.com/${REPO}/issues."
    exit 1
fi

TARGET_PLATFORM="linux-x86_64"
ARCHIVE_NAME="rad-${VERSION}-${TARGET_PLATFORM}.tar.gz"

printf "${BOLD}======================================================================${RESET}\n"
printf "${BOLD} Installing Rad Programming Language Toolchain v${VERSION}${RESET}\n"
printf " Target Prefix: %s\n" "$RAD_HOME"
printf " Architecture:  %s\n" "$TARGET_PLATFORM"
printf " Package Name:  %s\n" "$ARCHIVE_NAME"
printf "${BOLD}======================================================================${RESET}\n\n"

# Create secure temporary directory on the same filesystem as RAD_HOME for atomic operations
PARENT_DIR="$(dirname "$RAD_HOME")"
mkdir -p "$PARENT_DIR"
TMP_DIR="$(mktemp -d "${PARENT_DIR}/.rad_install.XXXXXX")"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

# 2. Acquire Release Archive or Prepare Offline Staging
STAGE_DIR="$TMP_DIR/stage"
mkdir -p "$STAGE_DIR"

if [ "$OFFLINE_MODE" -eq 1 ]; then
    LOCAL_REPO=""
    if [ -f "./src/compiler/radc/src/main.rad" ] || [ -f "./bin/radc" ]; then
        LOCAL_REPO="$(pwd)"
    elif [ -f "$(dirname "$0")/../src/compiler/radc/src/main.rad" ]; then
        LOCAL_REPO="$(cd "$(dirname "$0")/.." && pwd)"
    fi

    if [ -z "$LOCAL_REPO" ]; then
        log_error "Offline mode requested, but not inside a Rad repository (src/compiler/radc not found)."
        exit 1
    fi

    log_info "Performing offline installation from local repository ($LOCAL_REPO)..."
    mkdir -p "$STAGE_DIR/bin" "$STAGE_DIR/lib/rad" "$STAGE_DIR/lib/targets" "$STAGE_DIR/share/rad"

    # Ensure binaries are built
    if [ ! -f "$LOCAL_REPO/bin/radc" ] || [ ! -f "$LOCAL_REPO/bin/rad" ]; then
        log_step "Building Rad binaries via Makefile..."
        make -C "$LOCAL_REPO" all
    fi

    log_step "Staging toolchain binaries..."
    cp "$LOCAL_REPO/bin/radc" "$STAGE_DIR/bin/radc"
    cp "$LOCAL_REPO/bin/rad" "$STAGE_DIR/bin/rad"
    cp "$LOCAL_REPO/bin/rad-clang" "$STAGE_DIR/bin/rad-clang"
    cp "$LOCAL_REPO/bin/rad-clang++" "$STAGE_DIR/bin/rad-clang++"
    chmod 755 "$STAGE_DIR/bin"/*

    log_step "Staging Rad standard library..."
    if [ -d "$LOCAL_REPO/library" ]; then
        cp -r "$LOCAL_REPO/library"/* "$STAGE_DIR/lib/rad/"
    fi

    log_step "Staging canonical target sysroot..."
    if [ -d "$LOCAL_REPO/lib/targets" ]; then
        cp -r "$LOCAL_REPO/lib/targets"/* "$STAGE_DIR/lib/targets/"
    fi

    log_step "Staging runtime libraries and compiler assets..."
    # Preserve LLVM runtime libraries from existing install or system
    if [ -d "$RAD_HOME/lib/llvm" ]; then
        mkdir -p "$STAGE_DIR/lib"
        cp -r "$RAD_HOME/lib/llvm" "$STAGE_DIR/lib/"
    elif [ -d "/usr/lib/llvm" ] || [ -f "/usr/bin/llc" ]; then
        mkdir -p "$STAGE_DIR/lib/llvm"
        cp /usr/bin/llc "$STAGE_DIR/lib/llvm/llc_real" 2>/dev/null || true
        cp /usr/bin/ld.lld "$STAGE_DIR/lib/llvm/ld.lld_real" 2>/dev/null || true
        ln -sf ld.lld_real "$STAGE_DIR/lib/llvm/ld.lld" 2>/dev/null || true
        cp -L /usr/bin/clang "$STAGE_DIR/lib/llvm/clang" 2>/dev/null || true
        ln -sf clang "$STAGE_DIR/lib/llvm/clang++" 2>/dev/null || true
        cp -P /usr/lib/libLLVM*.so* "$STAGE_DIR/lib/llvm/" 2>/dev/null || true
        cp -P /usr/lib/liblld*.so* "$STAGE_DIR/lib/llvm/" 2>/dev/null || true
        cp -P /usr/lib/libclang-cpp*.so* "$STAGE_DIR/lib/llvm/" 2>/dev/null || true
    fi

    # Preserve clang resources
    if [ -d "$RAD_HOME/lib/clang" ]; then
        mkdir -p "$STAGE_DIR/lib"
        cp -r "$RAD_HOME/lib/clang" "$STAGE_DIR/lib/"
        ln -sf . "$STAGE_DIR/lib/lib" 2>/dev/null || true
    elif [ -d "/usr/lib/clang" ]; then
        mkdir -p "$STAGE_DIR/lib"
        cp -r /usr/lib/clang "$STAGE_DIR/lib/"
        ln -sf . "$STAGE_DIR/lib/lib" 2>/dev/null || true
    fi

    # Preserve C++ headers/libraries
    if [ -d "$RAD_HOME/lib/cxx" ]; then
        mkdir -p "$STAGE_DIR/lib"
        cp -r "$RAD_HOME/lib/cxx" "$STAGE_DIR/lib/"
    fi

    # Preserve metadata & licenses
    if [ -d "$RAD_HOME/share/rad" ]; then
        cp -r "$RAD_HOME/share/rad" "$STAGE_DIR/share/"
    else
        cat << EOF > "$STAGE_DIR/share/rad/VERSION"
Rad Programming Language
Version: ${VERSION}
Commit:  $(git -C "$LOCAL_REPO" rev-parse HEAD 2>/dev/null || echo "offline")
Built:   $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Host:    linux-x86_64
Target:  x86_64-unknown-linux-musl
EOF
    fi
else
    log_info "Acquiring release archive..."

    ARCHIVE_PATH="$TMP_DIR/$ARCHIVE_NAME"
    MANIFEST_PATH="$TMP_DIR/SHA256SUMS"

    if [ -n "${RAD_DIST_DIR:-}" ] && [ -d "$RAD_DIST_DIR" ]; then
        log_step "Using local distribution directory: $RAD_DIST_DIR"
        FOUND_ARCHIVE=""
        for cand in "$ARCHIVE_NAME" "rad-${VERSION}-linux-x86_64.tar.gz" "rad-${VERSION}-x86_64-unknown-linux-musl.tar.gz" "rad-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"; do
            if [ -f "$RAD_DIST_DIR/$cand" ]; then
                FOUND_ARCHIVE="$cand"
                break
            fi
        done
        if [ -z "$FOUND_ARCHIVE" ]; then
            log_error "Archive $ARCHIVE_NAME not found in local directory $RAD_DIST_DIR"
            exit 1
        fi
        ARCHIVE_NAME="$FOUND_ARCHIVE"
        ARCHIVE_PATH="$TMP_DIR/$ARCHIVE_NAME"
        cp "$RAD_DIST_DIR/$ARCHIVE_NAME" "$ARCHIVE_PATH"
        if [ -f "$RAD_DIST_DIR/SHA256SUMS" ]; then
            cp "$RAD_DIST_DIR/SHA256SUMS" "$MANIFEST_PATH"
        fi
    else
        if [ -n "${RAD_RELEASE_URL:-}" ]; then
            BASE_URL="$RAD_RELEASE_URL"
        elif [ "$VERSION_EXPLICIT" -eq 0 ] && [ "$VERSION" = "$DEFAULT_VERSION" ]; then
            BASE_URL="https://github.com/${REPO}/releases/latest/download"
        else
            BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"
        fi
        MANIFEST_URL="${BASE_URL}/SHA256SUMS"

        log_step "Downloading Rad release archive from $BASE_URL..."
        DOWNLOAD_OK=0
        for cand in "${ARCHIVE_NAME}" "rad-${VERSION}-linux-x86_64.tar.gz" "rad-${VERSION}-x86_64-unknown-linux-musl.tar.gz" "rad-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"; do
            cand_url="${BASE_URL}/${cand}"
            if command -v curl >/dev/null 2>&1; then
                if curl -fSL --progress-bar "$cand_url" -o "$TMP_DIR/$cand" 2>/dev/null; then
                    ARCHIVE_NAME="$cand"
                    ARCHIVE_PATH="$TMP_DIR/$cand"
                    DOWNLOAD_OK=1
                    break
                fi
            elif command -v wget >/dev/null 2>&1; then
                if wget -q --show-progress "$cand_url" -O "$TMP_DIR/$cand" 2>/dev/null; then
                    ARCHIVE_NAME="$cand"
                    ARCHIVE_PATH="$TMP_DIR/$cand"
                    DOWNLOAD_OK=1
                    break
                fi
            fi
        done

        if [ "$DOWNLOAD_OK" -eq 0 ]; then
            log_error "Failed to download Rad release package from $BASE_URL"
            exit 1
        fi

        # Download SHA256SUMS
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "$MANIFEST_URL" -o "$MANIFEST_PATH" 2>/dev/null || true
        elif command -v wget >/dev/null 2>&1; then
            wget -q "$MANIFEST_URL" -O "$MANIFEST_PATH" 2>/dev/null || true
        fi
    fi

    # 3. Checksum Verification
    log_info "Verifying archive integrity..."
    if [ -f "$MANIFEST_PATH" ]; then
        EXPECTED_HASH="$(grep -F "$ARCHIVE_NAME" "$MANIFEST_PATH" 2>/dev/null | awk '{print $1}' || true)"
        if [ -n "$EXPECTED_HASH" ]; then
            if command -v sha256sum >/dev/null 2>&1; then
                ACTUAL_HASH="$(sha256sum "$ARCHIVE_PATH" | awk '{print $1}')"
            elif command -v shasum >/dev/null 2>&1; then
                ACTUAL_HASH="$(shasum -a 256 "$ARCHIVE_PATH" | awk '{print $1}')"
            else
                log_warn "sha256sum/shasum utility not found; skipping hash verification."
                ACTUAL_HASH=""
            fi

            if [ -n "$ACTUAL_HASH" ]; then
                if [ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]; then
                    log_error "Checksum verification failed for $ARCHIVE_NAME!"
                    log_error "Expected: $EXPECTED_HASH"
                    log_error "Actual:   $ACTUAL_HASH"
                    exit 1
                fi
                log_success "Checksum verified: $ACTUAL_HASH"
            fi
        else
            log_warn "$ARCHIVE_NAME not found in SHA256SUMS manifest; proceeding with caution."
        fi
    else
        log_warn "SHA256SUMS manifest not available; skipping checksum verification."
    fi

    # 4. Staging and Extraction
    log_info "Extracting distribution into staging directory..."
    tar -xzf "$ARCHIVE_PATH" -C "$STAGE_DIR" --strip-components=1 || {
        log_error "Failed to extract archive $ARCHIVE_PATH"
        exit 1
    }
fi

# 5. Pre-installation Executable Validation
log_info "Validating toolchain components..."
for bin in rad radc rad-clang rad-clang++; do
    if [ ! -f "$STAGE_DIR/bin/$bin" ]; then
        log_error "Essential executable missing in distribution: bin/$bin"
        exit 1
    fi
    chmod 755 "$STAGE_DIR/bin/$bin"
done

# Basic executable functionality tests on staged binaries before replacing RAD_HOME
STAGE_RAD_VER="$("$STAGE_DIR/bin/rad" --version 2>/dev/null || true)"
if [ -z "$STAGE_RAD_VER" ]; then
    log_error "Staged 'rad' binary failed basic execution test in current environment."
    exit 1
fi

STAGE_RADC_VER="$("$STAGE_DIR/bin/radc" --version 2>/dev/null || true)"
if [ -z "$STAGE_RADC_VER" ]; then
    log_error "Staged 'radc' binary failed basic execution test in current environment."
    exit 1
fi

STAGE_CLANG_VER="$("$STAGE_DIR/bin/rad-clang" --version 2>/dev/null || true)"
if [ -z "$STAGE_CLANG_VER" ]; then
    log_error "Staged 'rad-clang' launcher failed basic execution test in current environment."
    exit 1
fi

log_success "Staged components verified ($STAGE_RAD_VER, $STAGE_RADC_VER)"

# 6. Atomic Installation / Upgrade
log_info "Installing to $RAD_HOME..."
mkdir -p "$(dirname "$RAD_HOME")"

BACKUP_DIR=""
if [ -d "$RAD_HOME" ]; then
    BACKUP_DIR="${RAD_HOME}.bak.$$"
    log_step "Preserving previous installation at $BACKUP_DIR..."
    mv "$RAD_HOME" "$BACKUP_DIR"
fi

if mv "$STAGE_DIR" "$RAD_HOME"; then
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        rm -rf "$BACKUP_DIR"
    fi
    log_success "Installed Rad toolchain to $RAD_HOME"
else
    log_error "Failed to move staged files to $RAD_HOME"
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        log_warn "Rolling back to previous installation..."
        mv "$BACKUP_DIR" "$RAD_HOME"
    fi
    exit 1
fi

# 7. Shell PATH Configuration
configure_path() {
    BIN_DIR="$RAD_HOME/bin"

    # Check if BIN_DIR is already in current PATH
    case ":${PATH}:" in
        *":${BIN_DIR}:"*)
            log_success "$BIN_DIR is already present in PATH"
            return 0
            ;;
    esac

    DETECTED_SHELL="$(basename "${SHELL:-sh}")"
    CONFIGURED=0

    # Helper function to append to an rc file safely
    update_rc_file() {
        RC_FILE="$1"
        LINE_TO_ADD="$2"
        FILE_DESC="$3"

        if [ -f "$RC_FILE" ] || [ -f "$(dirname "$RC_FILE")" ]; then
            if [ -f "$RC_FILE" ] && grep -F "$BIN_DIR" "$RC_FILE" >/dev/null 2>&1; then
                log_success "$FILE_DESC already configures PATH ($RC_FILE)"
                CONFIGURED=1
                return 0
            fi

            log_step "Configuring PATH in $FILE_DESC ($RC_FILE)..."
            if [ -f "$RC_FILE" ]; then
                cp "$RC_FILE" "${RC_FILE}.rad-bak"
            fi
            printf "\n# Added by Rad toolchain installer\n%s\n" "$LINE_TO_ADD" >> "$RC_FILE"
            log_success "Updated $RC_FILE (backup saved as ${RC_FILE}.rad-bak)"
            CONFIGURED=1
        fi
    }

    # Bash configuration
    if [ "$DETECTED_SHELL" = "bash" ] || [ -f "$HOME/.bashrc" ] || [ -f "$HOME/.bash_profile" ]; then
        TARGET_BASH_RC="$HOME/.bashrc"
        if [ ! -f "$TARGET_BASH_RC" ] && [ -f "$HOME/.bash_profile" ]; then
            TARGET_BASH_RC="$HOME/.bash_profile"
        fi
        update_rc_file "$TARGET_BASH_RC" "export PATH=\"$BIN_DIR:\$PATH\"" "Bash"
    fi

    # Zsh configuration
    if [ "$DETECTED_SHELL" = "zsh" ] || [ -f "$HOME/.zshrc" ]; then
        update_rc_file "$HOME/.zshrc" "export PATH=\"$BIN_DIR:\$PATH\"" "Zsh"
    fi

    # Fish configuration
    FISH_CONF_DIR="$HOME/.config/fish"
    FISH_CONF="$FISH_CONF_DIR/config.fish"
    if [ "$DETECTED_SHELL" = "fish" ] || [ -d "$FISH_CONF_DIR" ] || [ -f "$FISH_CONF" ]; then
        mkdir -p "$FISH_CONF_DIR"
        update_rc_file "$FISH_CONF" "set -gx PATH \"$BIN_DIR\" \$PATH" "Fish"
    fi

    if [ "$CONFIGURED" -eq 0 ]; then
        log_warn "Could not automatically detect shell startup files."
        log_warn "Please manually add $BIN_DIR to your PATH:"
        printf "    export PATH=\"%s:\$PATH\"\n\n" "$BIN_DIR"
    fi
}

if [ "$MODIFY_PATH" -eq 1 ]; then
    log_info "Configuring PATH environment variable..."
    configure_path
else
    log_step "Skipping shell PATH modification (--no-modify-path)"
fi

# 8. Post-Installation Verification
log_info "Running post-installation verification..."

RAD_BIN="$RAD_HOME/bin/rad"
RADC_BIN="$RAD_HOME/bin/radc"

if [ ! -x "$RAD_BIN" ] || [ ! -x "$RADC_BIN" ]; then
    log_error "Installed binaries not found or not executable in $RAD_HOME/bin"
    exit 1
fi

log_step "Verifying rad --version..."
"$RAD_BIN" --version

log_step "Verifying radc --version..."
"$RADC_BIN" --version

log_step "Running rad doctor..."
"$RAD_BIN" doctor || {
    log_warn "rad doctor reported potential environment issues."
}

log_step "Compiling minimal Rad verification program..."
TEST_SRC="$TMP_DIR/verify_install.rad"
TEST_EXE="$TMP_DIR/verify_install_bin"

cat << 'EOF' > "$TEST_SRC"
fn main() -> i32 {
    println("Rad toolchain installation verified successfully!");
    return 0;
}
EOF

if RAD_HOME="$RAD_HOME" "$RADC_BIN" "$TEST_SRC" -o "$TEST_EXE" -O2 >/dev/null 2>&1; then
    TEST_OUT="$("$TEST_EXE" 2>&1 || true)"
    if echo "$TEST_OUT" | grep -q "Rad toolchain installation verified successfully!"; then
        log_success "Compiler pipeline test passed: minimal program compiled and executed cleanly"
    else
        log_warn "Compiler produced binary but unexpected output: $TEST_OUT"
    fi
else
    log_warn "Could not execute in-place compilation test (system linker or musl sysroot check needed)."
fi

# 9. Completion Notice
printf "\n${GREEN}${BOLD}✓ Rad has been successfully installed!${RESET}\n\n"
printf "Installed location:\n"
printf "    %s\n\n" "$RAD_HOME"
printf "To get started in your current terminal session, run:\n"
printf "    ${BOLD}export PATH=\"%s/bin:\$PATH\"${RESET}\n\n" "$RAD_HOME"
printf "Then test the installation with:\n"
printf "    ${BOLD}rad doctor${RESET}\n"
printf "    ${BOLD}rad new my_first_app${RESET}\n"
printf "    ${BOLD}cd my_first_app && rad run${RESET}\n\n"
