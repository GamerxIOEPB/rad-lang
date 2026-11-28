#!/usr/bin/env bash
# ==============================================================================
# scripts/verify_self_hosting.sh — Self-Hosting Reproducibility & Determinism Verification
# Verifies that radc compiling itself (Stage 2 -> Stage 3 -> Stage 4)
# produces bit-for-bit identical object code every time.
# ==============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

RADC="${RADC:-$ROOT_DIR/bin/radc}"
if [[ ! -x "$RADC" ]]; then
    echo "error: radc binary not found at $RADC" >&2
    exit 1
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/rad-selfhost.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

RADC_DIR="src/compiler/radc/src"
RADC_SRCS=(
    "${RADC_DIR}/main.rad"
    "${RADC_DIR}/util.rad"
    "${RADC_DIR}/token.rad"
    "${RADC_DIR}/ast.rad"
    "${RADC_DIR}/parser.rad"
    "${RADC_DIR}/parser_types.rad"
    "${RADC_DIR}/parser_expr.rad"
    "${RADC_DIR}/parser_stmt.rad"
    "${RADC_DIR}/parser_decl.rad"
    "${RADC_DIR}/codegen.rad"
    "${RADC_DIR}/codegen_types.rad"
    "${RADC_DIR}/codegen_struct.rad"
    "${RADC_DIR}/codegen_type_query.rad"
    "${RADC_DIR}/codegen_expr.rad"
    "${RADC_DIR}/codegen_expr_ops.rad"
    "${RADC_DIR}/codegen_expr_access.rad"
    "${RADC_DIR}/codegen_call.rad"
    "${RADC_DIR}/codegen_stmt.rad"
    "${RADC_DIR}/codegen_sema.rad"
    "${RADC_DIR}/linker.rad"
)

LLVM_CXXFLAGS="$(llvm-config --cxxflags 2>/dev/null || echo "")"
LLVM_LDFLAGS="$(llvm-config --ldflags 2>/dev/null || echo "")"
LLVM_SYSLIBS="-lz -lzstd -lrt -ldl -lm"

echo "==> Step 1: Compiling Stage 3 object with current compiler ($RADC)..."
"$RADC" -c "${RADC_SRCS[@]}" -o "$TMP_DIR/radc_stage3.o" -O2

echo "==> Step 2: Linking Stage 3 compiler ($TMP_DIR/radc-stage3)..."
mkdir -p bin
if [[ ! -f bin/backend_bridge.o ]]; then
    clang++ -c -O2 -fPIC $LLVM_CXXFLAGS -fexceptions "${RADC_DIR}/backend_bridge.cpp" -o bin/backend_bridge.o
fi
if [[ ! -f bin/crash_report.o ]]; then
    clang++ -c -O2 -fPIC $LLVM_CXXFLAGS "${RADC_DIR}/crash_report.cpp" -o bin/crash_report.o
fi

clang++ "$TMP_DIR/radc_stage3.o" bin/backend_bridge.o bin/crash_report.o \
    $LLVM_LDFLAGS -lLLVM -llldELF -llldWasm -llldCommon $LLVM_SYSLIBS \
    -o "$TMP_DIR/radc-stage3"

echo "==> Step 3: Compiling Stage 4 object with Stage 3 compiler ($TMP_DIR/radc-stage3)..."
"$TMP_DIR/radc-stage3" -c "${RADC_SRCS[@]}" -o "$TMP_DIR/radc_stage4.o" -O2

echo "==> Step 4: Comparing Stage 3 and Stage 4 object checksums..."
HASH_STAGE3="$(sha256sum "$TMP_DIR/radc_stage3.o" | awk '{print $1}')"
HASH_STAGE4="$(sha256sum "$TMP_DIR/radc_stage4.o" | awk '{print $1}')"

echo "  Stage 3 SHA-256: $HASH_STAGE3"
echo "  Stage 4 SHA-256: $HASH_STAGE4"

if [[ "$HASH_STAGE3" == "$HASH_STAGE4" ]]; then
    echo "  [✓] Bit-for-bit identical self-hosting determinism verified!"
    exit 0
else
    echo "error: Stage 3 and Stage 4 compiler object outputs differ!" >&2
    exit 1
fi
