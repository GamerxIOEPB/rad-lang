#!/usr/bin/env bash
# Compile-check all in-tree std/alloc modules and package roots, then run
# functional and memory-stress programs. Valgrind/LLVM probes are conditional.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"
RADC="${RADC:-$ROOT_DIR/bin/radc}"
if [[ ! -x "$RADC" ]]; then
    if [[ -x "$HOME/.rad/bin/radc" ]]; then
        RADC="$HOME/.rad/bin/radc"
    else
        echo "error: radc not found; set RADC=/path/to/radc" >&2
        exit 2
    fi
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/rad-quality.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT
checked=0
failed=0

check_import() {
    local spec="$1"
    local file="$TMP_DIR/import_probe.rad"
    printf 'import %s;\nfn main() -> i32 { return 0; }\n' "$spec" > "$file"
    if "$RADC" --check "$file" >"$TMP_DIR/import.log" 2>&1; then
        checked=$((checked + 1))
        printf '  [OK] %s\n' "$spec"
    else
        failed=$((failed + 1))
        printf '  [FAIL] %s\n' "$spec"
        cat "$TMP_DIR/import.log"
    fi
}

echo "==> Standard-library root and individual modules"
check_import "std"
for source in "$ROOT_DIR"/lib/rad/std/src/*.rad; do
    [[ -f "$source" ]] || continue
    module="$(basename "$source" .rad)"
    [[ "$module" == "lib" ]] && continue
    check_import "std/$module"
done

echo "==> Allocator modules"
for source in "$ROOT_DIR"/lib/rad/alloc/src/*.rad; do
    [[ -f "$source" ]] || continue
    module="$(basename "$source" .rad)"
    [[ "$module" == "lib" ]] && continue
    check_import "alloc/$module"
done

echo "==> Ecosystem package roots"
while IFS= read -r package_root; do
    package="$(basename "$(dirname "$(dirname "$package_root")")")"
    [[ "$package" == "std" || "$package" == "alloc" ]] && continue
    check_import "\"$package\""
done < <(find "$ROOT_DIR/lib/rad" -mindepth 3 -maxdepth 3 -type f -path '*/src/lib.rad' | sort)

echo "==> Existing functional integration suites"
for source in tests/test_memory.rad tests/test_collections.rad tests/test_stdlib.rad; do
    name="$(basename "$source" .rad)"
    binary="$TMP_DIR/$name"
    if "$RADC" -g -O0 "$source" -o "$binary" >"$TMP_DIR/$name.compile.log" 2>&1; then
        if "$binary" >"$TMP_DIR/$name.run.log" 2>&1; then
            printf '  [OK] %s\n' "$source"
        else
            failed=$((failed + 1))
            printf '  [FAIL] runtime %s\n' "$source"
            cat "$TMP_DIR/$name.run.log"
        fi
    else
        failed=$((failed + 1))
        printf '  [FAIL] compile %s\n' "$source"
        cat "$TMP_DIR/$name.compile.log"
    fi
done

echo "==> Allocator, collections, and pointer stress suite"
MEMORY_BIN="$TMP_DIR/memory_safety"
if "$RADC" -g -O0 tests/quality/memory_safety.rad -o "$MEMORY_BIN" >"$TMP_DIR/memory.compile.log" 2>&1; then
    if "$MEMORY_BIN" >"$TMP_DIR/memory.run.log" 2>&1; then
        cat "$TMP_DIR/memory.run.log"
    else
        failed=$((failed + 1))
        cat "$TMP_DIR/memory.run.log"
    fi
else
    failed=$((failed + 1))
    cat "$TMP_DIR/memory.compile.log"
fi

echo "==> LLVM compiler crash-reporting probe"
LLVM_CONFIG="${LLVM_CONFIG:-llvm-config}"
CXX="${CXX:-clang++}"
if command -v "$LLVM_CONFIG" >/dev/null 2>&1 && command -v "$CXX" >/dev/null 2>&1; then
    read -r -a LLVM_CXXFLAGS <<<"$("$LLVM_CONFIG" --cxxflags)"
    read -r -a LLVM_LINK_FLAGS <<<"$("$LLVM_CONFIG" --ldflags --libs support --system-libs)"
    if "$CXX" "${LLVM_CXXFLAGS[@]}" \
        -Isrc/compiler/radc/src \
        src/compiler/radc/src/crash_report.cpp \
        tests/quality/crash_report_probe.cpp \
        "${LLVM_LINK_FLAGS[@]}" \
        -o "$TMP_DIR/crash-report-probe"; then
        for signal_mode in segv abort; do
            set +e
            (ulimit -c 0; "$TMP_DIR/crash-report-probe" "$signal_mode") \
                >"$TMP_DIR/crash-$signal_mode.log" 2>&1
            status=$?
            set -e
            if [[ "$status" -eq 0 ]] ||
               ! grep -Fq "internal compiler error" "$TMP_DIR/crash-$signal_mode.log" ||
               ! grep -Eiq 'stack dump|backtrace|#0|0x[[:xdigit:]]+' "$TMP_DIR/crash-$signal_mode.log"; then
                failed=$((failed + 1))
                printf '  [FAIL] fatal signal handler (%s, exit %s)\n' "$signal_mode" "$status"
                cat "$TMP_DIR/crash-$signal_mode.log"
            else
                printf '  [OK] fatal signal handler (%s)\n' "$signal_mode"
            fi
        done
    else
        failed=$((failed + 1))
        echo "  [FAIL] unable to build crash-report probe"
    fi
else
    echo "  [SKIP] llvm-config or C++ compiler unavailable; crash probe not built"
fi

echo "==> Valgrind memory checking"
if command -v valgrind >/dev/null 2>&1 && [[ -x "$MEMORY_BIN" ]]; then
    if valgrind --quiet --error-exitcode=99 --leak-check=full \
        --errors-for-leak-kinds=definite,indirect "$MEMORY_BIN" \
        >"$TMP_DIR/valgrind.log" 2>&1; then
        echo "  [OK] Valgrind reported no invalid accesses or definite/indirect leaks"
    else
        failed=$((failed + 1))
        echo "  [FAIL] Valgrind found a memory error or leak"
        cat "$TMP_DIR/valgrind.log"
    fi
elif [[ "${REQUIRE_VALGRIND:-0}" == "1" ]]; then
    failed=$((failed + 1))
    echo "  [FAIL] REQUIRE_VALGRIND=1 but Valgrind is unavailable"
else
    echo "  [SKIP] Valgrind not installed (set REQUIRE_VALGRIND=1 in CI)"
fi

echo
echo "Library/module import checks: $checked"
echo "Failures: $failed"
[[ "$failed" -eq 0 ]]
