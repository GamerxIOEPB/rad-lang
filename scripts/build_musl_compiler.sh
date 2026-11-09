#!/usr/bin/env bash
# ==============================================================================
# scripts/build_musl_compiler.sh — Build Static-PIE Rad Compiler for Musl (x86_64)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BUILDER_IMAGE="rad-musl-builder:3.23"

# 1. Ensure Builder Docker Image is Available
if ! docker image inspect "$BUILDER_IMAGE" >/dev/null 2>&1; then
    echo "==> Building Docker image $BUILDER_IMAGE..."
    docker build --network host --platform linux/amd64 -t "$BUILDER_IMAGE" "$ROOT_DIR/tests/docker/builder"
fi

# 2. Compile Rad frontend object file on host using existing radc
echo "==> [1/3] Compiling self-hosted Rad compiler frontend to radc_rad.o..."
mkdir -p "$ROOT_DIR/bin"

if [ -d "$HOME/.rad/lib/llvm" ]; then
    export LD_LIBRARY_PATH="$HOME/.rad/lib/llvm:${LD_LIBRARY_PATH:-}"
fi
if [ -d "$ROOT_DIR/lib/llvm" ]; then
    export LD_LIBRARY_PATH="$ROOT_DIR/lib/llvm:${LD_LIBRARY_PATH:-}"
fi

RADC="${RADC:-$ROOT_DIR/bin/radc}"
if [ ! -x "$RADC" ]; then
    if [ -x "$HOME/.rad/bin/radc" ]; then
        RADC="$HOME/.rad/bin/radc"
    elif command -v radc >/dev/null 2>&1; then
        RADC="$(command -v radc)"
    fi
fi

RADC_SRCS=(
    "$ROOT_DIR/src/compiler/radc/src/main.rad"
    "$ROOT_DIR/src/compiler/radc/src/util.rad"
    "$ROOT_DIR/src/compiler/radc/src/token.rad"
    "$ROOT_DIR/src/compiler/radc/src/ast.rad"
    "$ROOT_DIR/src/compiler/radc/src/parser.rad"
    "$ROOT_DIR/src/compiler/radc/src/codegen.rad"
    "$ROOT_DIR/src/compiler/radc/src/linker.rad"
)

COMPILED=0
if [ -n "${RADC:-}" ] && [ -x "$RADC" ]; then
    echo "  -> Attempting compilation with $RADC..."
    if "$RADC" -c "${RADC_SRCS[@]}" -o "$ROOT_DIR/bin/radc_rad.o" 2>/dev/null; then
        COMPILED=1
        echo "  [✓] Successfully compiled radc_rad.o with $RADC"
    else
        echo "  [!] Host radc execution failed (e.g. libc or environment incompatibility)"
    fi
fi

if [ "$COMPILED" -eq 0 ]; then
    if [ -f "$ROOT_DIR/src/bootstrap/radc_rad.o" ]; then
        echo "  -> Falling back to bootstrap object src/bootstrap/radc_rad.o..."
        cp "$ROOT_DIR/src/bootstrap/radc_rad.o" "$ROOT_DIR/bin/radc_rad.o"
        echo "  [✓] Used bootstrap radc_rad.o"
    else
        echo "error: No working radc compiler found and no src/bootstrap/radc_rad.o available" >&2
        exit 1
    fi
fi

# 3. Inside the hermetic Docker builder, compile backend bridge and link static-pie radc
echo "==> [2/3] Compiling backend bridge & statically linking radc inside $BUILDER_IMAGE..."
docker run --rm \
    --platform linux/amd64 \
    -v "$ROOT_DIR:/workspace" \
    "$BUILDER_IMAGE" \
    bash -c '
        set -euo pipefail
        cd /workspace

        echo "  -> Compiling backend_bridge.cpp (musl)..."
        g++ -c -O2 -fPIC \
            -I/usr/include \
            -I/usr/lib/llvm21/include \
            -I/usr/local/include \
            src/compiler/radc/src/backend_bridge.cpp \
            -o bin/backend_bridge.o

        echo "  -> Statically linking radc (static-pie)..."
        LLVM_LIBS="$(/usr/lib/llvm21/bin/llvm-config --link-static --libs all-targets option lto irreader)"
        LLVM_SYSLIBS="-lz -lzstd -lm -lrt -ldl"

        g++ -static-pie -z text -z noexecstack \
            bin/radc_rad.o \
            bin/backend_bridge.o \
            -L/usr/local/lib/lld \
            -llldELF -llldCommon \
            -L/usr/lib/llvm21/lib \
            ${LLVM_LIBS} \
            ${LLVM_SYSLIBS} \
            -o bin/radc

        chmod 755 bin/radc
        strip bin/radc
    '

# 4. Verification of ELF properties
echo "==> [3/3] Verifying radc ELF properties..."
FILE_TYPE="$(file "$ROOT_DIR/bin/radc")"
echo "  $FILE_TYPE"

if ! echo "$FILE_TYPE" | grep -q "static-pie linked"; then
    echo "error: bin/radc is not static-pie linked!" >&2
    exit 1
fi

if readelf -l "$ROOT_DIR/bin/radc" | grep -q "INTERP"; then
    echo "error: bin/radc has PT_INTERP dynamic interpreter header!" >&2
    exit 1
fi

if readelf -d "$ROOT_DIR/bin/radc" | grep -q "NEEDED"; then
    echo "error: bin/radc has DT_NEEDED shared library dependencies!" >&2
    exit 1
fi

echo "[✓] Static-PIE radc compiled successfully with zero shared library dependencies!"
