# Chapter 13: Package Manager (`rad`) CLI Reference

The `rad` executable is the official package manager, project orchestrator, and developer toolchain utility for the Rad language.

## 13.1 Commands Overview

```text
Usage: rad <command> [options]

Commands:
  new <name>   Create a new Rad package: `rad new <name> [--lib]`
  init         Initialize a new Rad package in the current directory
  build        Compile the current package
  run          Build and execute the current package
  test         Run tests for the package
  check        Analyze package for errors without compiling
  clean        Remove target build directory
  fmt          Format Rad source files adhering to standard style
  lsp          Run embedded Language Server Protocol engine (JSON-RPC 2.0)
  toolchain    Manage and update the Rad toolchain installation
  doctor       Inspect and verify compiler, embedded backend, and sysroot
```

---

## 13.2 Command Details

### 1. `rad new <name>`
Creates a new directory with a complete Rad project skeleton:

```bash
# Create an application project (src/main.rad)
rad new my_app

# Create a library project (src/lib.rad)
rad new my_lib --lib
```

### 2. `rad init`
Initializes a new Rad package in the current working directory without creating a new parent directory:

```bash
mkdir my_project && cd my_project
rad init
```

### 3. `rad check`
Checks all source files in the project for lexical, syntactic, and structural errors using `radc --check`. Does not invoke code generation or linking, making it near-instant:

```bash
rad check
```

### 4. `rad build`
Compiles the project into an executable or library artifact using `radc`'s embedded LLVM and LLD engine:

```bash
# Debug build (places output in target/debug/main)
rad build

# Production release build (LLVM -O3, places output in target/release/main)
rad build --release

# Explicit target override:
rad build --target x86_64-unknown-linux-musl
```

### 5. `rad run`
Builds and executes the project's primary binary in one step:

```bash
rad run

# Run with arguments passed to the application:
rad run -- --port 8080 --verbose
```

### 6. `rad test`
Executes test functions and verification suites defined in the package:

```bash
rad test
```

### 7. `rad clean`
Removes the `target/` directory containing intermediate objects and final binaries:

```bash
rad clean
```

### 8. `rad doctor`
Verifies all components of the Rad toolchain, ensuring that `radc` (with its embedded LLVM and LLD backend), standard library sources, and the Musl target sysroot are present and correctly configured:

```bash
rad doctor
```

Output:
```text
Rad Toolchain Doctor
====================

  [OK] radc compiler: found (/home/username/.rad/bin/radc)
  [OK] Embedded LLVM & LLD backend: integrated in-process
  [OK] Standard library sources: verified at /home/username/.rad/lib/rad
  [OK] Target sysroot (x86_64-unknown-linux-musl): verified at /home/username/.rad/lib/targets/x86_64-unknown-linux-musl

Status: Toolchain is healthy and ready for self-contained native compilation.
```

### 9. `rad fmt [path] [--check] [--stdout]`
Runs the native source formatter. Enforces 4-space indentation, Egyptian braces, operator spacing, and blank line rules:

```bash
# Format in place
rad fmt src/main.rad

# Check if formatted without modifying files (exits 1 if unformatted)
rad fmt --check src/

# Preview formatted output directly to stdout
rad fmt --stdout src/main.rad
```

### 10. `rad lsp`
Starts the stdio Language Server Protocol (JSON-RPC 2.0) server for IDE integration:

```bash
rad lsp
```

Provides live diagnostics, completions, hover docs, go-to-definition, document outline symbols, and document formatting.

### 11. `rad toolchain <subcommand>`
Manages and verifies toolchain installations:

```bash
# Inspect current toolchain details
rad toolchain info

# Check available toolchain channels
rad toolchain list

# Check for updates or update to the latest release
rad toolchain update --check
rad toolchain update
```

---

## 13.3 Manifest Specification (`rad.toml`)

Every Rad package root contains a `rad.toml` manifest file:

```toml
[package]
name = "my_app"
version = "0.2.0"
edition = "2026"

[dependencies]
# Dependencies declaration
```
