# Chapter 12: Compiler (`radc`) & Build Deep-Dive

## 12.1 Compiler CLI Flags (`radc`)

The `radc` binary is the self-hosted Rad compiler. Its command-line interface provides precise control over code generation, optimization, and linking:

```bash
radc <file1.rad> [file2.rad ...] [options]
```

### Options Reference:

| Flag | Description | Default |
| :--- | :--- | :--- |
| `-o <path>` | Set output binary path or object path | Auto-named / `a.out` |
| `-O0` | Disable LLVM optimizations for fastest compile speed | — |
| `-O1` | Basic optimizations | — |
| `-O2` | Standard production optimization (recommended) | **Default** |
| `-O3` | Aggressive optimization (vectorization, loop unrolling) | — |
| `--emit-llvm`, `--emit-ir` | Emit textual LLVM IR (`.tmp.ll`) without assembling or linking | Disabled |
| `--check` | Lex and parse all inputs to verify syntax and types without code generation | Disabled |
| `--target <triple>` | Set compilation target architecture | `x86_64-unknown-linux-gnu` |
| `--linker <cmd>` | Override the default linker cascade with a custom command | Bundled `rad-lld` |
| `-V`, `--version` | Display compiler version and build information | — |

---

## 12.2 Inspecting Generated LLVM IR (`--emit-llvm`)

Because `radc` directly emits textual LLVM IR, you can inspect the exact low-level SSA representation produced by the compiler:

```bash
radc main.rad --emit-llvm -o main.ll
```

Open `main.ll` to see the generated LLVM IR:

```llvm
; ModuleID = 'radc_compiled'
source_filename = "rad"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare ptr @malloc(i64)
declare void @free(ptr)
declare i32 @puts(ptr)
...
```

This is invaluable for systems engineers wanting to verify zero-overhead abstractions, loop vectorization, and memory layouts.

---

## 12.3 The Static PIE Linker Cascade

When linking an executable, `radc` executes a two-stage cascade:

1. **Object Assembly**:
   ```bash
   rad-llc -filetype=obj -relocation-model=pic -O2 input.tmp.ll -o output.o
   ```
2. **Static PIE Linking**:
   ```bash
   rad-lld -flavor gnu -m elf_x86_64 -static -pie --no-dynamic-linker -z text -z noexecstack \
       -o output \
       $SYSROOT/crt/rcrt1.o \
       $SYSROOT/crt/crti.o \
       output.o \
       -L$SYSROOT/lib \
       --start-group $SYSROOT/lib/libc.a $SYSROOT/lib/libclang_rt.builtins-x86_64.a --end-group \
       $SYSROOT/crt/crtn.o
   ```

### Why Position-Independent Executables (PIE)?
- **Full ASLR (Address Space Layout Randomization)**: The Linux kernel loads the code, stack, and heap at randomized memory addresses for defense against buffer overflows and ROP (Return-Oriented Programming) attacks.
- **Static Linking**: Musl's `rcrt1.o` initializes the static executable's own relocations at runtime without requiring an external dynamic linker (`/lib64/ld-linux-x86-64.so.2`).
