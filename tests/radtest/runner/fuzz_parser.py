#!/usr/bin/env python3
"""
Rad Compiler Parser Fuzzer
Tests that arbitrary malformed, truncated, and corrupted inputs produce compiler
errors rather than compiler segmentation faults, aborts, or crashes.
"""

import os
import random
import subprocess
import sys
import tempfile

RADC = os.path.expanduser("~/.rad/bin/radc")
if not os.path.isfile(RADC):
    RADC = os.path.abspath("bin/radc")

SEEDS = [
    'fn main() -> i32 { return 0; }',
    'fn bubble(var a: []i64) { for i in 0..10 { arr[i] = 1; } }',
    'struct Foo { x: i64, y: str }',
    'let x = [1, 2, 3]; println(x[0]);',
    'if x > 10 { println("big"); } else { println("small"); }',
    'while i < 100 { i = i + 1; break; }',
    'extern "C" fn puts(s: str) -> i32;',
]

MUTATION_CHARS = [
    '{', '}', '(', ')', '[', ']', ';', ':', ',', '.', '..', '...',
    '"', '\'', '\\', '/', '%', '*', '+', '-', '<', '>', '=', '==',
    '!', '!=', '&', '&&', '|', '||', '^', '~', '\0', '\n', '\t', ' '
]

def mutate(seed: str) -> str:
    s = list(seed)
    num_mutations = random.randint(1, 5)
    for _ in range(num_mutations):
        action = random.choice(['insert', 'delete', 'replace', 'truncate'])
        if action == 'insert':
            pos = random.randint(0, len(s))
            s.insert(pos, random.choice(MUTATION_CHARS))
        elif action == 'delete' and len(s) > 0:
            pos = random.randint(0, len(s) - 1)
            del s[pos]
        elif action == 'replace' and len(s) > 0:
            pos = random.randint(0, len(s) - 1)
            s[pos] = random.choice(MUTATION_CHARS)
        elif action == 'truncate' and len(s) > 0:
            pos = random.randint(0, len(s))
            s = s[:pos]
    return ''.join(s)

def run_fuzzer(iterations: int = 200) -> bool:
    print(f"Running Rad parser fuzzer ({iterations} iterations)...")
    crashes = 0

    with tempfile.TemporaryDirectory() as tmpdir:
        test_file = os.path.join(tmpdir, "fuzz_input.rad")
        out_bin = os.path.join(tmpdir, "fuzz_bin")

        for i in range(iterations):
            seed = random.choice(SEEDS)
            fuzzed = mutate(seed)

            with open(test_file, 'w', encoding='utf-8', errors='ignore') as f:
                f.write(fuzzed)

            try:
                proc = subprocess.run(
                    [RADC, test_file, "-o", out_bin],
                    capture_output=True,
                    timeout=2
                )
                if proc.returncode < 0:
                    # Negative returncode in subprocess indicates termination by signal
                    sig = -proc.returncode
                    print(f"\n[CRASH] Iteration {i}: Compiler crashed with signal {sig}!")
                    print("Input:")
                    print(repr(fuzzed))
                    crashes += 1
            except subprocess.TimeoutExpired:
                print(f"\n[HANG] Iteration {i}: Compiler timed out!")
                crashes += 1

    if crashes == 0:
        print(f"SUCCESS: {iterations}/{iterations} fuzzed inputs rejected/handled safely with 0 crashes.")
        return True
    else:
        print(f"FAILURE: {crashes} crashes encountered during fuzzing.")
        return False

if __name__ == '__main__':
    ok = run_fuzzer(200)
    sys.exit(0 if ok else 1)
