# Chapter 1: What is Rad?

## 1.1 Philosophy & Design Goals

The **Rad programming language** is a modern, statically typed systems programming language designed for writing high-performance, predictable, and robust native software. Rad was created to offer the mechanical sympathy, raw performance, and low-level hardware control of C, paired with the safety, ergonomics, and clarity of modern languages—without requiring a heavy runtime garbage collector or overly complex compile-time lifetime annotations.

### Core Tenets

1. **Self-Contained Static Executables**: Every binary produced by the Rad compiler (`radc`) is linked as a static Position-Independent Executable (`static-pie`) against a bundled Musl libc sysroot. Executables have zero dynamic library dependencies (`no PT_INTERP`, `no DT_NEEDED`), running reliably across any Linux kernel without distribution-specific runtime issues.
2. **Zero-Overhead C & C++ Interoperability**: Rad speaks the C ABI natively. Standard C library functions (`malloc`, `free`, `puts`, `printf`, `system`, file I/O) are direct zero-cost calls without wrapper bloat, marshaling, or FFI barriers. Multi-language projects compile smoothly using bundled `rad-clang` and `rad-clang++`.
3. **Predictable Memory Semantics**: Rad uses explicit value semantics, direct heap allocations via built-in dynamic collections (`String`, `Vec`), and transparent raw pointer manipulation when interfacing with hardware or legacy systems. There is no hidden runtime overhead, tracing garbage collection pauses, or hidden stop-the-world phases.
4. **Self-Hosted, Single-Pass/Two-Pass Speed**: The production Rad compiler (`radc`) is written entirely in Rad. It compiles directly into SSA (Static Single Assignment) LLVM IR, pairing blazing compile times with LLVM's world-class optimization pipeline (`-O2`, `-O3`).
5. **Batteries-Included Toolchain**: Rad ships as a unified toolchain comprising the compiler (`radc`), the package manager and build orchestrator (`rad`), the assembler/code generator (`rad-llc`), the linker (`rad-lld`), and full C/C++ compilers (`rad-clang`, `rad-clang++`).

---

## 1.2 Architectural Overview

The Rad ecosystem consists of three major layers working together:

```
┌─────────────────────────────────────────────────────────────┐
│                 Rad Developer Applications                  │
│             (src/*.rad, rad.toml, packages)                 │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│         Rad Toolchain Orchestrator & Compiler Engine        │
│   rad (Package Manager)       radc (Self-Hosted Compiler)   │
│   - new, build, run, test     - Lexer & Pratt AST Parser    │
│   - doctor, check, clean      - SSA LLVM IR Generator       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│             Bundled LLVM & Static Target Sysroot            │
│   rad-llc (Code Generator)    rad-lld (Static Linker)       │
│   Target: x86_64-unknown-linux-musl (rcrt1.o, libc.a)       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              Standalone Native Executable                   │
│           (Static PIE, Zero Shared Dependencies)            │
└─────────────────────────────────────────────────────────────┘
```

### The Component Pipeline

- **`rad`**: The user-facing command-line interface. It manages project layout, creates packages (`rad new`), orchestrates builds (`rad build`), runs test suites (`rad test`), and checks system health (`rad doctor`).
- **`radc`**: The self-hosted compiler. It tokenizes source files with a high-speed lexer, constructs an arena-based Abstract Syntax Tree using a Pratt recursive descent parser, and directly generates optimized textual LLVM IR (`.tmp.ll`).
- **`rad-llc` & `rad-lld`**: Hermetic LLVM wrappers. `rad-llc` compiles LLVM IR into position-independent machine object files (`.o`), and `rad-lld` links them against Musl `rcrt1.o`, `libc.a`, and `libclang_rt.builtins` into a final static PIE binary.
- **`rad-clang` & `rad-clang++`**: Integrated host C and C++ compilers configured with the same sysroot for zero-friction mixed-language software development.

---

## 1.3 How Rad Compares to Other Languages

| Feature | Rad | C | C++ | Rust | Zig | Go |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Garbage Collection** | **None** | None | None | None | None | Concurrent Tracing GC |
| **Runtime Overhead** | **Zero** | Zero | Minimal | Zero | Zero | Moderate (Scheduler, GC) |
| **Default Binary Format** | **Static PIE** | Dynamic ELF | Dynamic ELF | Dynamic / Static | Static PIE | Static ELF |
| **C Interoperability** | **Direct C ABI** | Native | Native | Via FFI bindings | Direct | Via Cgo (High Overhead) |
| **Package Manager** | **Built-in (`rad`)** | None | CMake/Conan | Built-in (`cargo`) | Built-in | Built-in (`go`) |
| **Type Safety** | **Strong, Static** | Weak | Strong | Strict Lifetime Borrowing | Strong | Strong |
| **Compilation Speed** | **Fast (Direct SSA IR)** | Very Fast | Slow | Slow to Moderate | Fast | Very Fast |
| **Toolchain Self-Containment** | **Full (Sysroot Included)** | External | External | External Linkers | Self-Contained | Self-Contained |

---

## 1.4 When to Choose Rad

Choose Rad when you need:
- High-performance systems software (network daemons, CLI utilities, games, operating system tools, database engines).
- Executables that must run predictably across all Linux distributions without "missing glibc version" errors.
- A clean, modern syntax that eliminates C's header duplication and macro pitfalls while avoiding extreme compiler complexity.
- Direct, frictionless calls into legacy C codebases and standard Unix APIs.
