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
    local bin="$TMP_DIR/import_probe.bin"
    printf 'import %s;\nfn main() -> i32 { return 0; }\n' "$spec" > "$file"
    if "$RADC" "$file" -o "$bin" >"$TMP_DIR/import.log" 2>&1; then
        checked=$((checked + 1))
        printf '  [OK] %s\n' "$spec"
    else
        failed=$((failed + 1))
        printf '  [FAIL] %s\n' "$spec"
        cat "$TMP_DIR/import.log"
    fi
}

echo "==> Core root and individual modules"
check_import "core"
for source in "$ROOT_DIR"/lib/rad/core/src/*.rad; do
    [[ -f "$source" ]] || continue
    module="$(basename "$source" .rad)"
    [[ "$module" == "lib" ]] && continue
    check_import "core/$module"
done

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
declare -a INTEGRATION_BINS=()
for source in tests/test_memory.rad tests/test_collections.rad tests/test_stdlib.rad; do
    name="$(basename "$source" .rad)"
    binary="$TMP_DIR/$name"
    if "$RADC" -g -O0 "$source" -o "$binary" >"$TMP_DIR/$name.compile.log" 2>&1; then
        INTEGRATION_BINS+=("$binary")
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

echo "==> Ecosystem package functional suites"
while IFS= read -r source; do
    package="$(basename "$(dirname "$(dirname "$source")")")"
    name="$(basename "$source" .rad)"
    binary="$TMP_DIR/${package}_$name"
    extra_flags=()
    if [[ "$package" == "rad-sqlite" ]]; then
        if [[ -f "$ROOT_DIR/lib/targets/x86_64-unknown-linux-musl/lib/libsqlite3.a" || -f "$HOME/.rad/lib/targets/x86_64-unknown-linux-musl/lib/libsqlite3.a" ]] || ld.lld -m elf_x86_64 -L"$ROOT_DIR/lib/targets/x86_64-unknown-linux-musl/lib" -lsqlite3 -o /dev/null 2>/dev/null; then
            extra_flags=("-lsqlite3")
        else
            if "$RADC" --check "$source" >"$TMP_DIR/$name.compile.log" 2>&1; then
                printf '  [SKIP] %s/%s (typecheck OK; libsqlite3.a not installed for static linking)\n' "$package" "$name"
            else
                failed=$((failed + 1))
                printf '  [FAIL] check %s/%s\n' "$package" "$name"
                cat "$TMP_DIR/$name.compile.log"
            fi
            continue
        fi
    fi
    if "$RADC" -g -O0 "${extra_flags[@]}" "$source" -o "$binary" >"$TMP_DIR/$name.compile.log" 2>&1; then
        INTEGRATION_BINS+=("$binary")
        if "$binary" >"$TMP_DIR/$name.run.log" 2>&1; then
            printf '  [OK] %s/%s\n' "$package" "$name"
        else
            failed=$((failed + 1))
            printf '  [FAIL] runtime %s/%s\n' "$package" "$name"
            cat "$TMP_DIR/$name.run.log"
        fi
    else
        failed=$((failed + 1))
        printf '  [FAIL] compile %s/%s\n' "$package" "$name"
        cat "$TMP_DIR/$name.compile.log"
    fi
done < <(find "$ROOT_DIR/lib/rad" -mindepth 3 -maxdepth 3 -type f -path '*/tests/test_*.rad' | sort)

echo "==> On-demand package installation & static archive test (rad-sqlite)"
if [[ -x "$ROOT_DIR/bin/rad" ]]; then
    rm -rf "$HOME/.rad/lib/rad/rad-sqlite" "$HOME/.rad/lib/rad/sqlite" "$HOME/.rad/lib/targets/x86_64-unknown-linux-musl/lib/libsqlite3.a" 2>/dev/null || true
    if "$ROOT_DIR/bin/rad" install rad-sqlite >"$TMP_DIR/install_sqlite.log" 2>&1; then
        if [[ -f "$HOME/.rad/lib/targets/x86_64-unknown-linux-musl/lib/libsqlite3.a" ]]; then
            sqlite_test_src="$HOME/.rad/lib/rad/rad-sqlite/tests/test_sqlite.rad"
            if [[ -f "$sqlite_test_src" ]]; then
                if "$RADC" -g -O0 -lsqlite3 "$sqlite_test_src" -o "$TMP_DIR/ondemand_sqlite_bin" >"$TMP_DIR/ondemand_sqlite.compile.log" 2>&1; then
                    if "$TMP_DIR/ondemand_sqlite_bin" >"$TMP_DIR/ondemand_sqlite.run.log" 2>&1; then
                        printf '  [OK] rad install rad-sqlite provisions libsqlite3.a and runs successfully\n'
                    else
                        failed=$((failed + 1))
                        printf '  [FAIL] runtime on-demand rad-sqlite\n'
                        cat "$TMP_DIR/ondemand_sqlite.run.log"
                    fi
                else
                    failed=$((failed + 1))
                    printf '  [FAIL] compile on-demand rad-sqlite\n'
                    cat "$TMP_DIR/ondemand_sqlite.compile.log"
                fi
            fi
        else
            failed=$((failed + 1))
            printf '  [FAIL] libsqlite3.a not provisioned to sysroot\n'
        fi
    else
        failed=$((failed + 1))
        printf '  [FAIL] rad install rad-sqlite failed\n'
        cat "$TMP_DIR/install_sqlite.log"
    fi
fi

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
    read -r -a LLVM_LDFLAGS <<<"$("$LLVM_CONFIG" --ldflags)"
    LLVM_LIBDIR="$("$LLVM_CONFIG" --libdir)"
    RAD_LLVM_DIR="${RAD_LLVM_DIR:-$HOME/.rad/lib/llvm}"
    if [[ ! -d "$RAD_LLVM_DIR" ]]; then
        RAD_LLVM_DIR="$LLVM_LIBDIR"
    fi

    if "$CXX" "${LLVM_CXXFLAGS[@]}" \
        -Isrc/compiler/radc/src \
        src/compiler/radc/src/crash_report.cpp \
        tests/quality/crash_report_probe.cpp \
        "${LLVM_LDFLAGS[@]}" \
        -L"$RAD_LLVM_DIR" -L"$LLVM_LIBDIR" \
        -lLLVM -lz -lzstd -lrt -ldl -lm \
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
    failed=$((failed + 1))
    echo "  [FAIL] llvm-config or C++ compiler unavailable"
fi

echo "==> Valgrind memory checking"
if ! command -v valgrind >/dev/null 2>&1; then
    if [[ "${REQUIRE_VALGRIND:-0}" == "1" ]]; then
        failed=$((failed + 1))
        echo "  [FAIL] REQUIRE_VALGRIND=1 but Valgrind is unavailable"
    else
        echo "  [SKIP] Valgrind not installed (set REQUIRE_VALGRIND=1 in CI)"
    fi
else
    for program in "${INTEGRATION_BINS[@]}"; do
        name="$(basename "$program")"
        set +e
        valgrind --quiet --track-origins=yes --error-exitcode=99 \
            --leak-check=full --errors-for-leak-kinds=definite,indirect \
            "$program" >"$TMP_DIR/valgrind-$name.log" 2>&1
        status=$?
        set -e
        if [[ "$status" -eq 0 ]]; then
            printf '  [OK] Valgrind: %s\n' "$name"
        else
            failed=$((failed + 1))
            printf '  [FAIL] Valgrind: %s (exit %s)\n' "$name" "$status"
            cat "$TMP_DIR/valgrind-$name.log"
        fi
    done

    if [[ -x "$MEMORY_BIN" ]]; then
        set +e
        valgrind --quiet --track-origins=yes --error-exitcode=99 \
            --leak-check=full --errors-for-leak-kinds=definite,indirect \
            "$MEMORY_BIN" >"$TMP_DIR/valgrind-memory_safety.log" 2>&1
        memory_status=$?
        set -e
        if [[ "$memory_status" -eq 0 ]]; then
            echo "  [OK] Valgrind: memory_safety"
        else
            failed=$((failed + 1))
            printf '  [FAIL] Valgrind: memory_safety (exit %s)\n' "$memory_status"
            cat "$TMP_DIR/valgrind-memory_safety.log"
        fi
    else
        failed=$((failed + 1))
        echo "  [FAIL] memory stress binary was not produced; Valgrind stress check skipped"
    fi

    UAF_BIN="$TMP_DIR/use_after_free"
    if "$RADC" -g -O0 tests/quality/use_after_free.rad -o "$UAF_BIN" >"$TMP_DIR/uaf.compile.log" 2>&1; then
        set +e
        valgrind --quiet --track-origins=yes --error-exitcode=99 --leak-check=no \
            "$UAF_BIN" >"$TMP_DIR/uaf.log" 2>&1
        uaf_status=$?
        set -e
        if [[ "$uaf_status" -ne 0 ]] && grep -Eiq 'Invalid read of size|use-after-free' "$TMP_DIR/uaf.log"; then
            echo "  [OK] Valgrind detected the deliberate use-after-free probe"
        else
            failed=$((failed + 1))
            echo "  [FAIL] Valgrind did not report the deliberate use-after-free (exit $uaf_status)"
            cat "$TMP_DIR/uaf.log"
        fi
    else
        failed=$((failed + 1))
        echo "  [FAIL] unable to compile use-after-free detector probe"
        cat "$TMP_DIR/uaf.compile.log"
    fi
fi

echo
echo "Library/module import checks: $checked"
echo "Failures: $failed"
[[ "$failed" -eq 0 ]]
