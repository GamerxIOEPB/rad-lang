#!/usr/bin/env bash
# ==============================================================================
# scripts/test_alpine_docker.sh — Complete Local Alpine Portability Test Suite
#
# Tests the standalone Rad distribution on a clean, isolated Alpine Linux (musl)
# environment via local Docker, verifying zero external shared dependencies,
# static PIE execution, compiler functionality, relocation, and glibc compatibility.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

ALPINE_IMAGE="${ALPINE_IMAGE:-alpine:3.23}"
TEST_IMAGE_TAG="rad-alpine-test:3.23"
DIST_DIR="$ROOT_DIR/target/dist"
ARCHIVE_NAME="rad-0.2.1-linux-x86_64.tar.gz"

BOLD="\033[1m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

log_info() {
    printf "${CYAN}==>${RESET} ${BOLD}%s${RESET}\n" "$1"
}

log_pass() {
    printf "  ${GREEN}[PASS]${RESET} %s\n" "$1"
}

log_fail() {
    printf "  ${RED}[FAIL]${RESET} %s\n" "$1" >&2
}

# 1. Verify Docker Availability
log_info "Verifying Docker engine availability..."
if ! command -v docker >/dev/null 2>&1; then
    log_fail "Docker CLI is not installed or not in PATH."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    log_fail "Cannot connect to Docker daemon. Ensure docker service is running."
    exit 1
fi
log_pass "Docker engine is running and accessible."

# 2. Build or Verify Distribution Archive
log_info "Checking Rad distribution package..."
if [ ! -f "$DIST_DIR/$ARCHIVE_NAME" ]; then
    log_info "Archive $ARCHIVE_NAME not found. Building distribution..."
    bash "$ROOT_DIR/scripts/build_distribution.sh" -y
fi

if [ ! -f "$DIST_DIR/$ARCHIVE_NAME" ]; then
    log_fail "Distribution archive $DIST_DIR/$ARCHIVE_NAME was not produced."
    exit 1
fi
log_pass "Found distribution package: $DIST_DIR/$ARCHIVE_NAME"

# 3. Ensure Alpine Test Docker Image is Built
log_info "Preparing clean Alpine Docker test environment ($TEST_IMAGE_TAG)..."
if ! docker image inspect "$TEST_IMAGE_TAG" >/dev/null 2>&1; then
    log_info "Building diagnostic Alpine test container image..."
    docker build --network host --platform linux/amd64 -t "$TEST_IMAGE_TAG" "$ROOT_DIR/tests/docker/alpine"
fi
log_pass "Test container image ready: $TEST_IMAGE_TAG"

# 4. Execute Alpine Portability Test Suite Inside Isolated Container
log_info "Running isolated Alpine Linux portability verification suite..."

docker run --rm \
    --platform linux/amd64 \
    --network none \
    -v "$ROOT_DIR:/workspace:ro" \
    "$TEST_IMAGE_TAG" \
    bash -c '
        set -euo pipefail

        echo "=== [Step 1/6] Installing Rad from distribution archive ==="
        export HOME=/tmp/rad-test-home
        mkdir -p "$HOME"
        export RAD_HOME="$HOME/.rad-alpine-test"
        export RAD_DIST_DIR=/workspace/target/dist

        # Run installer
        sh /workspace/scripts/install.sh \
            -v 0.2.1 \
            -y \
            --no-modify-path

        export PATH="$RAD_HOME/bin:$PATH"

        echo "=== [Step 2/6] Validating mandatory binaries ==="
        rad --version
        radc --version
        rad doctor || true

        echo "=== [Step 3/6] Inspecting ELF properties (Static PIE verification) ==="
        for bin in rad radc rad-clang rad-clang++; do
            TARGET="$RAD_HOME/bin/$bin"
            echo "Checking $bin:"
            file "$TARGET"

            # Must NOT have dynamic interpreter (PT_INTERP)
            if readelf -l "$TARGET" | grep -q "INTERP"; then
                echo "FAIL: $bin contains PT_INTERP dynamic interpreter header!" >&2
                exit 1
            fi

            # Must NOT have DT_NEEDED shared library dependencies
            if readelf -d "$TARGET" | grep -q "NEEDED"; then
                echo "FAIL: $bin contains DT_NEEDED dynamic shared library dependencies!" >&2
                exit 1
            fi
            echo "  -> [OK] Pure static-pie verified with zero external dynamic dependencies."
        done

        echo "=== [Step 4/6] Compiling & Executing Algorithmic Test Programs ==="
        WORK="/tmp/rad_algo_tests"
        mkdir -p "$WORK"
        cd "$WORK"

        # 4.1 Hello World
        cat << "EOF" > test_hello.rad
fn main() {
    println("Hello from clean Alpine Linux!")
}
EOF
        radc test_hello.rad -o hello_bin -O2
        OUT="$(./hello_bin)"
        echo "$OUT"
        if [ "$OUT" != "Hello from clean Alpine Linux!" ]; then
            echo "FAIL: Hello World output mismatch" >&2
            exit 1
        fi
        echo "  [PASS] Hello World"

        # 4.2 Fibonacci
        cat << "EOF" > test_fibo.rad
fn fib(n: i64) -> i64 {
    if n <= 1 { return n }
    return fib(n - 1) + fib(n - 2)
}
fn main() {
    let res = fib(10)
    println(res)
}
EOF
        radc test_fibo.rad -o fibo_bin -O2
        FIB_OUT="$(./fibo_bin)"
        if [ "$FIB_OUT" != "55" ]; then
            echo "FAIL: Fibonacci expected 55, got $FIB_OUT" >&2
            exit 1
        fi
        echo "  [PASS] Fibonacci recursive (fib(10) = 55)"

        # 4.3 Factorial
        cat << "EOF" > test_fact.rad
fn factorial(n: i64) -> i64 {
    var res: i64 = 1
    var i: i64 = 2
    while i <= n {
        res = res * i
        i = i + 1
    }
    return res
}
fn main() {
    println(factorial(7))
}
EOF
        radc test_fact.rad -o fact_bin -O2
        FACT_OUT="$(./fact_bin)"
        if [ "$FACT_OUT" != "5040" ]; then
            echo "FAIL: Factorial expected 5040, got $FACT_OUT" >&2
            exit 1
        fi
        echo "  [PASS] Factorial iterative (7! = 5040)"

        # 4.4 Bubble Sort
        cat << "EOF" > test_bubble.rad
fn bubble_sort(var arr: []i64) {
    let n = arr.len
    for i in 0..n {
        for j in 0..(n - i - 1usize) {
            if arr[j] > arr[j + 1usize] {
                swap(arr[j], arr[j + 1usize])
            }
        }
    }
}
fn main() -> i32 {
    var arr = [64, 34, 25, 12, 22, 11, 90]
    bubble_sort(arr)
    var sum: i64 = 0
    for x in arr {
        sum = sum * 100 + x
    }
    println(sum)
    return 0
}
EOF
        radc test_bubble.rad -o bubble_bin -O2
        BUBBLE_OUT="$(./bubble_bin)"
        if [ "$BUBBLE_OUT" != "11122225346490" ]; then
            echo "FAIL: Bubble sort output mismatch: $BUBBLE_OUT" >&2
            exit 1
        fi
        echo "  [PASS] Bubble Sort"

        # 4.5 Merge Sort (1,000 Elements)
        cat << "EOF" > test_merge.rad
fn merge(var arr: []i64, temp: *raw var i64, l: usize, m: usize, r: usize) {
    var i = l
    var j = m + 1usize
    var k = l

    while i <= m && j <= r {
        if arr[i] <= arr[j] {
            temp[k] = arr[i]
            i = i + 1usize
        } else {
            temp[k] = arr[j]
            j = j + 1usize
        }
        k = k + 1usize
    }

    while i <= m {
        temp[k] = arr[i]
        i = i + 1usize
        k = k + 1usize
    }

    while j <= r {
        temp[k] = arr[j]
        j = j + 1usize
        k = k + 1usize
    }

    for idx in l..(r + 1usize) {
        arr[idx] = temp[idx]
    }
}

fn merge_sort_rec(var arr: []i64, temp: *raw var i64, l: usize, r: usize) {
    if l < r {
        let m = l + (r - l) / 2usize
        merge_sort_rec(arr, temp, l, m)
        merge_sort_rec(arr, temp, m + 1usize, r)
        merge(arr, temp, l, m, r)
    }
}

fn merge_sort(var arr: []i64) {
    let n = arr.len
    if n <= 1usize {
        return
    }
    let temp = malloc(n * 8usize) as *raw var i64
    merge_sort_rec(arr, temp, 0usize, n - 1usize)
    free(temp as *raw u8)
}

fn is_sorted(arr: []i64) -> bool {
    let n = arr.len
    if n <= 1usize {
        return true
    }
    for i in 0..(n - 1usize) {
        if arr[i] > arr[i + 1usize] {
            return false
        }
    }
    return true
}

fn alloc_slice(n: usize) -> []i64 {
    let buf = malloc(n * 8usize) as *raw var i64
    let desc = malloc(24usize) as *raw var usize
    desc[0] = buf as usize
    desc[1] = n
    desc[2] = n
    return desc as []i64
}

fn main() -> i32 {
    var arr = alloc_slice(1000usize)
    for i in 0..arr.len {
        arr[i] = ((1000usize - i) * 37usize % 10000usize) as i64
    }
    merge_sort(arr)
    if is_sorted(arr) {
        println("MERGE_SORT_1000_OK")
    } else {
        println("MERGE_SORT_FAILED")
    }
    return 0
}
EOF
        radc test_merge.rad -o merge_bin -O2
        MERGE_OUT="$(./merge_bin)"
        if [ "$MERGE_OUT" != "MERGE_SORT_1000_OK" ]; then
            echo "FAIL: Merge sort 1000 elements failed: $MERGE_OUT" >&2
            exit 1
        fi
        echo "  [PASS] Merge Sort (1,000 Elements Dynamic Vector)"

        # 4.6 Multi-file Module
        cat << "EOF" > math_helper.rad
fn square(x: i64) -> i64 {
    return x * x
}
EOF
        cat << "EOF" > main_mod.rad
import "./math_helper.rad";
fn main() {
    let val = square(12)
    println(val)
}
EOF
        radc main_mod.rad -o multifile_bin -O2
        MULTI_OUT="$(./multifile_bin)"
        if [ "$MULTI_OUT" != "144" ]; then
            echo "FAIL: Multi-file module expected 144, got $MULTI_OUT" >&2
            exit 1
        fi
        echo "  [PASS] Multi-file Rad compilation"

        echo "=== [Step 5/6] Testing Relocation to New Path ==="
        RELOC_DIR="/tmp/relocated-rad-dir"
        mv "$RAD_HOME" "$RELOC_DIR"
        export RAD_HOME="$RELOC_DIR"
        export PATH="$RELOC_DIR/bin:$PATH"

        rad --version
        radc --version
        radc test_hello.rad -o hello_reloc_bin -O2
        RELOC_OUT="$(./hello_reloc_bin)"
        if [ "$RELOC_OUT" != "Hello from clean Alpine Linux!" ]; then
            echo "FAIL: Relocated compiler execution failed: $RELOC_OUT" >&2
            exit 1
        fi
        echo "  [PASS] Toolchain successfully relocated and fully functional at $RELOC_DIR"

        echo "=== [Step 6/6] All Alpine Portability Checks Passed Cleanly ==="
    '

log_pass "Alpine Linux portability acceptance tests passed successfully!"

# 5. Clean glibc Compatibility Test (Minimal Debian Slim)
log_info "Verifying cross-distro compatibility on clean glibc container (debian:bookworm-slim)..."
docker run --rm \
    --platform linux/amd64 \
    --network none \
    -v "$ROOT_DIR:/workspace:ro" \
    debian:bookworm-slim \
    bash -c '
        set -euo pipefail
        export HOME=/tmp/glibc-home
        mkdir -p "$HOME"
        export RAD_HOME="$HOME/.rad-glibc"
        export RAD_DIST_DIR=/workspace/target/dist

        ARCH=$(ls /workspace/target/dist/rad-0.2.1-*.tar.gz | head -n 1)
        tar -xzf "$ARCH" -C "$HOME"
        mv "$HOME"/rad-0.2.1-* "$RAD_HOME"
        export PATH="$RAD_HOME/bin:$PATH"

        rad --version
        radc --version

        cat << "EOF" > /tmp/glibc_test.rad
fn main() {
    println("Hello from clean glibc Debian!")
}
EOF
        radc /tmp/glibc_test.rad -o /tmp/glibc_test_bin -O2
        GLIBC_OUT="$(/tmp/glibc_test_bin)"
        echo "$GLIBC_OUT"
        if [ "$GLIBC_OUT" != "Hello from clean glibc Debian!" ]; then
            echo "FAIL: glibc output mismatch" >&2
            exit 1
        fi
        echo "  [PASS] Rad runs and compiles natively on clean glibc distribution."
    '
log_pass "Cross-distribution glibc compatibility verified successfully!"

printf "\n${GREEN}${BOLD}======================================================================${RESET}\n"
printf "${GREEN}${BOLD} ALL ALPINE AND GLIBC PORTABILITY ACCEPTANCE TESTS PASSED!${RESET}\n"
printf "${GREEN}${BOLD}======================================================================${RESET}\n\n"
