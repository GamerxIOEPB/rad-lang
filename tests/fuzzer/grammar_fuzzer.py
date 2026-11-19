#!/usr/bin/env python3
"""
Grammar & AST Fuzzer for the Rad Compiler (radc)
Synthesizes randomized grammar constructs, complex nested expressions,
deep control flow, and stress-tests compiler stability.
"""

import os
import sys
import random
import subprocess
import tempfile
import time

TYPES = ["i32", "i64", "u8", "u16", "u32", "u64", "usize", "bool", "f64", "str"]
BIN_OPS = ["+", "-", "*", "/", "%", "==", "!=", "<", "<=", ">", ">=", "&&", "||", "&", "|", "^"]
UN_OPS = ["-", "!"]

def gen_expr(depth=0, max_depth=3):
    if depth >= max_depth or random.random() < 0.4:
        choice = random.randint(0, 4)
        if choice == 0:
            return str(random.randint(-100, 100))
        elif choice == 1:
            return f"{random.randint(0, 50)}u8"
        elif choice == 2:
            return "true" if random.random() < 0.5 else "false"
        elif choice == 3:
            return f'"{random.choice(["foo", "bar", "rad", "test", ""])}"'
        else:
            return f"{random.uniform(-10.0, 10.0):.2f}"

    choice = random.randint(0, 3)
    if choice == 0:
        op = random.choice(BIN_OPS)
        lhs = gen_expr(depth + 1, max_depth)
        rhs = gen_expr(depth + 1, max_depth)
        return f"({lhs} {op} {rhs})"
    elif choice == 1:
        op = random.choice(UN_OPS)
        inner = gen_expr(depth + 1, max_depth)
        return f"({op}{inner})"
    elif choice == 2:
        inner = gen_expr(depth + 1, max_depth)
        tgt = random.choice(TYPES)
        return f"({inner} as {tgt})"
    else:
        return f"({gen_expr(depth + 1, max_depth)})"

def gen_stmt(depth=0, max_depth=3):
    choice = random.randint(0, 4)
    if depth >= max_depth or choice == 0:
        var_name = f"v_{random.randint(0, 20)}"
        ty = random.choice(TYPES)
        val = gen_expr(0, 2)
        is_mut = "var" if random.random() < 0.5 else "let"
        return f"    {is_mut} {var_name}: {ty} = {val};\n"
    elif choice == 1:
        cond = "true" if random.random() < 0.5 else "false"
        then_body = "".join(gen_stmt(depth + 1, max_depth) for _ in range(random.randint(1, 3)))
        else_body = "".join(gen_stmt(depth + 1, max_depth) for _ in range(random.randint(0, 2)))
        res = f"    if {cond} {{\n{then_body}    }}"
        if else_body:
            res += f" else {{\n{else_body}    }}"
        return res + "\n"
    elif choice == 2:
        cond = "false" # Prevent infinite runtime
        body = "".join(gen_stmt(depth + 1, max_depth) for _ in range(random.randint(1, 2)))
        return f"    while {cond} {{\n{body}    }}\n"
    elif choice == 3:
        arr_elems = ", ".join(str(random.randint(0, 10)) for _ in range(random.randint(1, 4)))
        return f"    let arr = [{arr_elems}];\n"
    else:
        return f"    let _dummy = {gen_expr(0, 2)};\n"

def gen_program():
    num_structs = random.randint(0, 2)
    structs = []
    for si in range(num_structs):
        sname = f"Struct{si}"
        fields = [f"    pub f_{fi}: {random.choice(TYPES)}" for fi in range(random.randint(1, 4))]
        structs.append(f"struct {sname} {{\n" + ",\n".join(fields) + "\n}\n")

    num_stmts = random.randint(3, 10)
    body = "".join(gen_stmt(0, 2) for _ in range(num_stmts))
    fn_main = f"fn main() -> i32 {{\n{body}    return 0;\n}}\n"

    return "\n".join(structs) + "\n" + fn_main

def run_fuzzer(iterations=200):
    radc_bin = os.path.abspath("bin/radc")
    print(f"Starting grammar fuzzer ({iterations} iterations) against {radc_bin}...")
    start_time = time.time()
    crashes = 0
    checks_passed = 0

    with tempfile.TemporaryDirectory() as tmpdir:
        for i in range(iterations):
            code = gen_program()
            src_file = os.path.join(tmpdir, f"fuzz_{i}.rad")
            with open(src_file, "w") as f:
                f.write(code)

            # Test parser check
            p = subprocess.run([radc_bin, "--check", src_file], capture_output=True, text=True)

            # Assert no segfault or core dump
            if p.returncode < 0:
                print(f"[!] CRASH detected on iteration {i}: exit code {p.returncode}")
                print(code)
                crashes += 1
                break
            if "rad runtime panic" in p.stderr.lower() or "segmentation fault" in p.stderr.lower():
                print(f"[!] PANIC detected on iteration {i}: {p.stderr}")
                crashes += 1
                break

            checks_passed += 1

    elapsed = time.time() - start_time
    print(f"\nFuzzing completed in {elapsed:.2f}s:")
    print(f"  Iterations: {iterations}")
    print(f"  Valid Check/Diagnostics: {checks_passed}")
    print(f"  Crashes: {crashes}")
    assert crashes == 0, f"Fuzzer found {crashes} compiler crashes!"
    print("  \033[1;32m✓ 100% Compiler Stability Verified (0 crashes)\033[0m\n")

if __name__ == "__main__":
    n = 200
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    run_fuzzer(n)
