#!/usr/bin/env bash
# =============================================================================
# Rad language test runner
#   - compiles each tests/<category>/<name>.rad with radc
#   - runs the binary, captures stdout/stderr/exit code
#   - verifies output against tests/expected/<name>.{out,contains,regex,exit}
#   - in tests/12_must_fail: PASS means the compiler correctly REJECTED the code
#
# Statuses:
#   PASS        compile+run+output all as expected
#   COMPILE_FAIL program should have compiled but did not
#   RUN_FAIL    compiled but crashed / wrong exit code / timeout
#   MISMATCH    ran but stdout differed from expectation
#   NEG_OK      must-fail test: compiler rejected it (correct)
#   NEG_BUG     must-fail test: compiler ACCEPTED invalid code
#   UNVERIFIED  deterministic run, but verification disabled (expected/<n>.unver)
# =============================================================================
set -u
cd "$(dirname "$0")/.."   # radtest root

RADC="${RADC:-$HOME/.rad/bin/radc}"
TDIR="tests"
EDIR="tests/expected"
BLD="build"
RES="results"
TMO="${TMO:-10}"

mkdir -p "$BLD" "$RES" "$EDIR"
: > "$RES/status.tsv"

declare -a CATS
if [ $# -gt 0 ]; then CATS=("$@"); else
    CATS=()
    for d in "$TDIR"/*/; do CATS+=("$(basename "$d")"); done
fi

pass=0; compile_fail=0; run_fail=0; mismatch=0; neg_ok=0; neg_bug=0; unverified=0
failed_tests=()

record() { # name cat status exitcode
    printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "${4:-0}" >> "$RES/status.tsv"
}

for cat in "${CATS[@]}"; do
    [ -d "$TDIR/$cat" ] || { echo "?? no such category: $cat" >&2; continue; }
    echo "── category $cat"
    shopt -s nullglob
    for f in "$TDIR/$cat"/*.rad; do
        name="$(basename "$f" .rad)"
        fdirname="$name"
        mkdir -p "$RES/$name"
        echo -n "  $name ... "

        # ---- compile ----
        t0=$(date +%s%N 2>/dev/null || echo 0)
        "$RADC" "$f" -o "$BLD/$fdirname" >"$RES/$name/compile.out" 2>&1
        crc=$?
        t1=$(date +%s%N 2>/dev/null || echo 0)
        ms=$(( (t1 - t0) / 1000000 ))

        if [ $crc -ne 0 ]; then
            if [ "$cat" = "12_must_fail" ] || [[ "$name" =~ (neg_|^nf_) ]]; then
                echo "NEG_OK (compiler rejected: $(head -1 "$RES/$name/compile.out" | cut -c1-90))"
                record "$name" "$cat" NEG_OK "$crc"
                neg_ok=$((neg_ok+1))
            else
                echo "COMPILE_FAIL  (see results/$name/compile.err)"
                record "$name" "$cat" COMPILE_FAIL "$crc"
                compile_fail=$((compile_fail+1)); failed_tests+=("$name(compile)")
            fi
            continue
        fi

        if [ "$cat" = "12_must_fail" ] || [[ "$name" =~ (neg_|^nf_) ]]; then
            echo "NEG_BUG (compiled though it must fail!)"
            record "$name" "$cat" NEG_BUG "$crc"
            neg_bug=$((neg_bug+1)); failed_tests+=("$name(accepted-invalid)")
            continue
        fi

        # ---- run ----
        args=()
        if [ -f "$EDIR/$name.args" ]; then
            # shellcheck disable=SC2046
            args=($(cat "$EDIR/$name.args"))
        fi
        exp_rc=0
        [ -f "$EDIR/$name.exit" ] && exp_rc="$(cat "$EDIR/$name.exit")"

        if [ ${#args[@]} -gt 0 ]; then
            timeout "$TMO" "$BLD/$fdirname" "${args[@]}" >"$RES/$name/stdout" 2>"$RES/$name/stderr"
        else
            timeout "$TMO" "$BLD/$fdirname" >"$RES/$name/stdout" 2>"$RES/$name/stderr"
        fi
        rrc=$?

        if [ $rrc -eq 124 ]; then
            echo "RUN_FAIL (timeout ${TMO}s)"
            record "$name" "$cat" RUN_FAIL 124
            run_fail=$((run_fail+1)); failed_tests+=("$name(timeout)")
            continue
        fi
        if [ $rrc -ne "$exp_rc" ]; then
            echo "RUN_FAIL (exit $rrc, expected $exp_rc; stderr: $(head -1 "$RES/$name/stderr" | cut -c1-90))"
            record "$name" "$cat" RUN_FAIL "$rrc"
            run_fail=$((run_fail+1)); failed_tests+=("$name(exit=$rrc)")
            continue
        fi

        # ---- verify output ----
        if [ -f "$EDIR/$name.unver" ]; then
            echo "UNVERIFIED (ran, checked manually)"
            record "$name" "$cat" UNVERIFIED "$rrc"
            unverified=$((unverified+1))
            continue
        fi

        if [ -f "$EDIR/$name.regex" ]; then
            if grep -qE "$(cat "$EDIR/$name.regex")" "$RES/$name/stdout"; then
                echo "PASS (regex)"
                record "$name" "$cat" PASS "$rrc"; pass=$((pass+1))
            else
                echo "MISMATCH (regex)"
                record "$name" "$cat" MISMATCH "$rrc"
                mismatch=$((mismatch+1)); failed_tests+=("$name(regex)")
            fi
        elif [ -f "$EDIR/$name.contains" ]; then
            if grep -qF "$(cat "$EDIR/$name.contains")" "$RES/$name/stdout"; then
                echo "PASS (contains)"
                record "$name" "$cat" PASS "$rrc"; pass=$((pass+1))
            else
                echo "MISMATCH (contains)"
                record "$name" "$cat" MISMATCH "$rrc"
                mismatch=$((mismatch+1)); failed_tests+=("$name(contains)")
            fi
        else
            expf="$EDIR/$name.out"
            if [ ! -f "$expf" ]; then
                echo "MISMATCH (no expected file)"; record "$name" "$cat" MISMATCH "$rrc"
                mismatch=$((mismatch+1)); failed_tests+=("$name(missing-expected)")
                continue
            fi
            if diff -q "$expf" "$RES/$name/stdout" >/dev/null; then
                echo "PASS"
                record "$name" "$cat" PASS "$rrc"; pass=$((pass+1))
            else
                echo "MISMATCH (diff tests/expected/$name.out results/$name/stdout)"
                record "$name" "$cat" MISMATCH "$rrc"
                mismatch=$((mismatch+1)); failed_tests+=("$name(diff)")
            fi
        fi
    done
    shopt -u nullglob
done

echo
echo "════════════ SUMMARY ════════════"
echo "PASS:        $pass"
echo "UNVERIFIED:  $unverified"
echo "COMPILE_FAIL $compile_fail"
echo "RUN_FAIL:    $run_fail"
echo "MISMATCH:    $mismatch"
echo "NEG_OK:      $neg_ok   (invalid code correctly rejected)"
echo "NEG_BUG:     $neg_bug  (invalid code accepted!)"
if [ ${#failed_tests[@]} -gt 0 ]; then
    echo
    echo "Failing tests:"
    printf '  - %s\n' "${failed_tests[@]}"
fi
exit 0
