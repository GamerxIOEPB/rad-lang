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
| `-c` | Compile source files to a relocatable object file (`.o`) without linking | Disabled |
| `-O0` | Disable LLVM optimizations for fastest compile speed | — |
| `-O1` | Basic optimizations | — |
| `-O2` | Standard production optimization (recommended) | **Default** |
| `-O3` | Aggressive optimization (auto-vectorization, loop unrolling) | — |
| `--emit-llvm`, `--emit-ir` | Emit textual LLVM IR (`.tmp.ll`) without assembling or linking | Disabled |
| `--check` | Lex, parse, and analyze source files for syntax and semantic errors without code generation | Disabled |
| `--color <auto\|always\|never>` | Set ANSI terminal diagnostic color styling mode | `auto` |
| `--error-format=json` | Emit machine-readable structured JSON compiler diagnostics | Disabled |
| `--target <triple>` | Set compilation target architecture | `x86_64-unknown-linux-musl` |
| `--sysroot <dir>` | Override canonical target sysroot directory | Autodetected via `$RAD_HOME` |
| `-V`, `--version` | Display compiler version and build information | — |

---

## 12.2 Inspecting Generated LLVM IR (`--emit-llvm`)

Because `radc` directly emits textual LLVM IR, you can inspect the exact low-level SSA representation produced by the compiler:

```bash
radc main.rad --emit-llvm -o main.ll
```

Open `main.ll` to inspect the generated SSA instructions:

```llvm
; ModuleID = 'radc_compiled'
source_filename = "rad"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-musl"

declare ptr @malloc(i64)
declare void @free(ptr)
declare i32 @puts(ptr)
...
```

This is invaluable for systems engineers wanting to verify zero-overhead abstractions, loop vectorization, and memory layouts.

---

## 12.3 Embedded In-Process LLVM & LLD Backend Engine

Starting in Rad 0.2.0, `radc` does not invoke external CLI subprocesses (`rad-llc` or `rad-lld`). Instead, `radc` directly embeds the LLVM and LLD libraries in-process via a C++ backend bridge:

### 1. In-Process LLVM TargetMachine Object Emission
When compiling an executable or object file, `radc`:
1. Constructs the complete textual LLVM IR in memory.
2. Invokes LLVM's C API (`LLVMParseIRInContext2`, `LLVMCreateTargetMachine`).
3. Emits relocatable machine code (`.o`) directly to the build target using LLVM's `LLVMTargetMachineEmitToFile`.

### 2. In-Process LLD ELF Static PIE Linking
For final binary linking, `radc` invokes the embedded LLD driver (`lld::elf::link`) in-process:
- Relocation model: **Static Position-Independent Executable (`static-pie`)**
- Sysroot assets linked:
  - Startup objects: `rcrt1.o`, `crti.o`, `crtn.o`
  - Runtime libraries: `libc.a` (Musl), `libclang_rt.builtins-x86_64.a`
- Linker flags: `--no-dynamic-linker -z text -z noexecstack`

This architecture eliminates all process fork/exec overhead, avoids temporary bitcode disk thrashing, and yields instant single-command compilation.

---

## 12.4 Why Position-Independent Executables (Static PIE)?

- **Full ASLR (Address Space Layout Randomization)**: The Linux kernel loads the executable code, stack, and heap at randomized memory addresses, preventing Return-Oriented Programming (ROP) and code injection exploits.
- **Zero Shared Library Dependencies**: Executables contain their own startup relocator (`rcrt1.o`) and standard C library (`libc.a`). There is no dynamic linker dependency (`no PT_INTERP` / `no /lib64/ld-linux-x86-64.so.2`), allowing the same binary to run effortlessly across Alpine Linux, Ubuntu, Debian, Fedora, Arch Linux, and container roots.

---

## 12.5 Compiler Diagnostics & Rustc-Style Error Formatting

Starting in v0.2.3, `radc` features a standardized diagnostics engine providing human-readable Rustc-style source code rendering and machine-readable JSON outputs.

### Diagnostic Visual Layout
Errors and warnings render with source code snippets, line numbers, and caret spans:

```text
error[E0020]: cannot assign to undeclared variable 'a' (declare with 'let' or 'var' first)
  --> src/main.rad:2:5
   |
 2 |     a = 10
   |     ^
```

```text
warning[W0001]: variable does not need to be mutable: 'var count' (consider using 'let count')
  --> src/main.rad:2:5
   |
 2 |     var count = 0
   |     ^^^^^^^^^
```

### Color Control (`--color`)
- `--color=auto` (default): Uses ANSI color when connected to an interactive TTY and `$NO_COLOR` is unset.
- `--color=always`: Force ANSI color escape codes even when piping or redirecting.
- `--color=never`: Suppress all ANSI escape sequences.
- Supports the standard `NO_COLOR` environment variable (respecting [no-color.org](https://no-color.org)).

### Structured JSON Diagnostics (`--error-format=json`)
For CI automation, language servers, and IDE plugins, `radc` emits line-delimited JSON objects:

```bash
radc src/main.rad --check --error-format=json
```

```json
{"code":"E0020","severity":"error","message":"cannot assign to undeclared variable 'a' (declare with 'let' or 'var' first)","file":"src/main.rad","line":2,"col":5,"end_line":2,"end_col":6,"source_line":"    a = 10","help":""}
```

### Diagnostic Code Reference

| Code | Severity | Category | Description |
| :--- | :--- | :--- | :--- |
| `E0001` | Error | Syntax | Expected delimiter or token missing |
| `E0002` | Error | Lexical | Unterminated string literal |
| `E0003` | Error | Lexical | Unterminated character literal |
| `E0004` | Error | Lexical | Unterminated block comment |
| `E0005` | Error | Lexical | Invalid escape sequence |
| `E0020` | Error | Semantic | Unresolved identifier or undeclared variable assignment |
| `E0021` | Error | Semantic | Cannot assign to immutable variable (declared with `let`) |
| `E0023` | Error | Semantic | Type mismatch or unknown struct field |
| `W0001` | Warning | Lint | Variable declared with `var` but never mutated (suggests `let`) |

