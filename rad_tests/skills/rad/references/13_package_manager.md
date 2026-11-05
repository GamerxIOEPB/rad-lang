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
  doctor       Inspect and verify bundled toolchain and target sysroot
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
Checks all source files in the project for lexical, syntactic, and structural errors using `radc --check`. Does not invoke code generation or linking, making it instant:

```bash
rad check
```

### 4. `rad build`
Compiles the project into an executable or library artifact:

```bash
# Debug build (LLVM -O0, places output in target/debug/main)
rad build

# Production release build (LLVM -O3, places output in target/release/main)
rad build --release

# Cross-compilation target override:
rad build --target x86_64-unknown-linux-musl
```

### 5. `rad run`
Builds and executes the project's primary binary in one step:

```bash
rad run

# Run with arguments:
rad run -- --port 8080 --verbose
```

### 6. `rad clean`
Removes the `target/` directory containing intermediate objects, bitcode, and final binaries:

```bash
rad clean
```

### 7. `rad doctor`
Verifies all components of the Rad toolchain, ensuring that `radc`, `rad-llc`, `rad-lld`, and the Musl target sysroot are present and correctly configured:

```bash
rad doctor
```

---

## 13.3 Manifest Specification (`rad.toml`)

Every Rad package root contains a `rad.toml` manifest file:

```toml
[package]
name = "my_app"
version = "0.1.0"
edition = "2026"

[dependencies]
# Dependencies declaration
```
