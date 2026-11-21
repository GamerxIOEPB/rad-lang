#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BIN_DIR="$SCRIPT_DIR/bin"
mkdir -p "$BIN_DIR"

echo "======================================================================"
echo "  RAD PERFORMANCE BENCHMARK SUITE: Rad vs Clang C vs Rust"
echo "  Compiler Optimization: -O3 + LTO (Full Link-Time Optimization)"
echo "======================================================================"

RADC="$ROOT_DIR/bin/radc"
if [ ! -x "$RADC" ]; then
    echo "ERROR: radc not found at $RADC"
    exit 1
fi

echo ""
echo "==> Compiling Benchmarks..."
# 1. Matmul
"$RADC" "$SCRIPT_DIR/suite/matmul.rad" -O3 -flto -s -o "$BIN_DIR/matmul_rad"
clang -O3 -flto -s "$SCRIPT_DIR/suite/matmul.c" -o "$BIN_DIR/matmul_c"
rustc -O -C lto=fat "$SCRIPT_DIR/suite/matmul.rs" -o "$BIN_DIR/matmul_rust"
strip -s "$BIN_DIR/matmul_rust"

# 2. N-Queens
"$RADC" "$SCRIPT_DIR/suite/nqueens.rad" -O3 -flto -s -o "$BIN_DIR/nqueens_rad"
clang -O3 -flto -s "$SCRIPT_DIR/suite/nqueens.c" -o "$BIN_DIR/nqueens_c"
rustc -O -C lto=fat "$SCRIPT_DIR/suite/nqueens.rs" -o "$BIN_DIR/nqueens_rust"
strip -s "$BIN_DIR/nqueens_rust"

# 3. SHA-256
"$RADC" "$SCRIPT_DIR/suite/sha256_bench.rad" -O3 -flto -s -o "$BIN_DIR/sha256_rad"

echo "[✓] All benchmark binaries compiled successfully with -O3 + LTO."
echo ""

echo "==> Binary Size Comparison:"
printf "%-25s | %-12s | %-12s | %-12s\n" "Benchmark" "Rad (-O3+LTO)" "Clang C (-O3)" "Rust (Release)"
echo "----------------------------------------------------------------------"
printf "%-25s | %-12s | %-12s | %-12s\n" \
    "Matrix Multiplication" \
    "$(ls -lh "$BIN_DIR/matmul_rad" | awk '{print $5}')" \
    "$(ls -lh "$BIN_DIR/matmul_c" | awk '{print $5}')" \
    "$(ls -lh "$BIN_DIR/matmul_rust" | awk '{print $5}')"

printf "%-25s | %-12s | %-12s | %-12s\n" \
    "14-Queens Backtracking" \
    "$(ls -lh "$BIN_DIR/nqueens_rad" | awk '{print $5}')" \
    "$(ls -lh "$BIN_DIR/nqueens_c" | awk '{print $5}')" \
    "$(ls -lh "$BIN_DIR/nqueens_rust" | awk '{print $5}')"

printf "%-25s | %-12s | %-12s | %-12s\n" \
    "SHA-256 Pure Engine" \
    "$(ls -lh "$BIN_DIR/sha256_rad" | awk '{print $5}')" \
    "N/A" \
    "N/A"

echo ""
echo "==> Running Execution Benchmarks (3 Trials, best time recorded)..."
echo ""

run_trials() {
    local cmd="$1"
    local best=999999
    local out=""
    for i in 1 2 3; do
        res="$($cmd)"
        out="$res"
        ms=$(echo "$res" | grep -oE "[0-9]+ ms" | awk '{print $1}')
        if [ -n "$ms" ] && [ "$ms" -lt "$best" ]; then
            best="$ms"
        fi
    done
    echo "$best ms"
}

RAD_MATMUL=$(run_trials "$BIN_DIR/matmul_rad")
C_MATMUL=$(run_trials "$BIN_DIR/matmul_c")
RUST_MATMUL=$(run_trials "$BIN_DIR/matmul_rust")

RAD_NQUEENS=$(run_trials "$BIN_DIR/nqueens_rad")
C_NQUEENS=$(run_trials "$BIN_DIR/nqueens_c")
RUST_NQUEENS=$(run_trials "$BIN_DIR/nqueens_rust")

SHA256_OUT=$("$BIN_DIR/sha256_rad")
RAD_SHA256=$(echo "$SHA256_OUT" | grep -oE "[0-9]+ ms")
RAD_SHA256_TP=$(echo "$SHA256_OUT" | grep -oE "throughput: [0-9.]+ MB/s" | awk '{print $2, $3}')

echo "======================================================================"
echo "                   FINAL EXECUTION BENCHMARK RESULTS                  "
echo "======================================================================"
printf "%-25s | %-14s | %-14s | %-14s\n" "Benchmark" "Rad (-O3+LTO)" "Clang C (-O3)" "Rust (Release)"
echo "----------------------------------------------------------------------"
printf "%-25s | %-14s | %-14s | %-14s\n" "Matmul (512x512 f64)" "$RAD_MATMUL" "$C_MATMUL" "$RUST_MATMUL"
printf "%-25s | %-14s | %-14s | %-14s\n" "14-Queens Recursion" "$RAD_NQUEENS" "$C_NQUEENS" "$RUST_NQUEENS"
printf "%-25s | %-14s | %-14s | %-14s\n" "SHA-256 (20k blocks)" "$RAD_SHA256 ($RAD_SHA256_TP)" "N/A" "N/A"
echo "======================================================================"
