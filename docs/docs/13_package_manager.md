# Chapter 13: Package Management & `rad` CLI Reference

The `rad` executable is the official package manager, project orchestrator, and developer toolchain utility for the Rad language. It manages packages, dependency resolution, build orchestration, testing, documentation, formatting, and toolchain verification.

---

## 13.1 Commands Overview

```text
Usage: rad <command> [options]

Project Commands:
  new <name>       Create a new Rad package: `rad new <name> [--lib]`
  init             Initialize a new Rad package in the current directory
  build            Compile the current package
  run              Build and execute the current package
  test             Run package unit, integration, and doc tests
  bench            Run package performance benchmarks
  doc              Generate static HTML documentation for current project
  check            Analyze package for errors without compiling
  clean            Remove target build directory

Dependency Commands:
  add <pkg>        Add a library dependency to rad.toml and install it
  remove <pkg>     Remove a dependency from rad.toml
  update [pkg]     Update library dependencies to latest compatible versions
  fetch [pkg]      Fetch dependencies or package from registry and solve SemVer
  package <cmd>    Manage packages and registry: `rad package <cmd>`
                   Subcommands: install, publish, fetch, search, info, list, tree, outdated
  cache [cmd]      Manage package download cache: `rad cache [list|clean]`
  publish          Validate and publish package to the registry

Tooling & Diagnostics:
  fmt              Format Rad source files in-place or check formatting
  lsp              Run Language Server Protocol server over stdio
  verify <file>    Verify contracts and invariants with SMT engine
  repl             Launch interactive Rad REPL
  doctor           Inspect and verify bundled toolchain and target sysroot
  toolchain        Manage Rad toolchain versions and updates
```

---

## 13.2 Project & Build Commands

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
Removes the `target/` directory containing intermediate objects and final binaries across the project or monorepo workspace members:

```bash
rad clean
```

---

## 13.3 Tooling, Formatting & Diagnostics

### 1. `rad doctor`
Verifies all components of the Rad toolchain, ensuring that `radc` (with its embedded LLVM and LLD backend), standard library sources, and the Musl target sysroot are present and correctly configured:

```bash
rad doctor
```

Output:
```text
Rad Toolchain Doctor
====================

Mandatory Core Toolchain:
  [OK] radc compiler:         found (/home/username/.rad/bin/radc)
  [OK] LLVM backend:          embedded in radc (x86 native)
  [OK] Linker:                embedded in radc (LLD ELF)
  [OK] Target sysroot:        verified at /home/username/.rad/lib/targets/x86_64-unknown-linux-musl
  [OK] Rad standard library:  verified (core, alloc, std)

Status: Toolchain is healthy and ready for self-contained native compilation.
```

### 2. `rad fmt [path] [--check] [--stdout]`
Runs the native source formatter. Enforces 4-space indentation, Egyptian braces, operator spacing, and blank line rules:

```bash
# Format in place
rad fmt src/main.rad

# Check if formatted without modifying files (exits 1 if unformatted)
rad fmt --check src/

# Preview formatted output directly to stdout
rad fmt --stdout src/main.rad
```

### 3. `rad lsp`
Starts the stdio Language Server Protocol (JSON-RPC 2.0) server for IDE integration:

```bash
rad lsp
```

Provides live diagnostics, completions, hover docs, go-to-definition, document outline symbols, and document formatting.

### 4. `rad doc [path] [--output <dir>] [--open]`
Generates beautiful, self-contained HTML API documentation from `///` and `//!` doc-comments across functions, methods, structs, enums, traits, constants, and type aliases:

```bash
# Generate documentation for current package (default: target/doc/index.html)
rad doc

# Specify custom output path and open directly in default browser:
rad doc --output public/docs --open

# Generate documentation for a single source file:
rad doc lib/rad/alloc/src/vec.rad
```

Features include responsive dark theme, real-time symbol search filter, category summary counters, and code signature formatting.

### 5. `rad toolchain <subcommand>`
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

## 13.4 The Rad Package Ecosystem & Registry (`rad-lib`)

Rad packages (libraries) are distributed through the official Git-backed central registry: [**GamerxIOEPB/rad-lib**](https://github.com/GamerxIOEPB/rad-lib).

### Key Architectural Pillars:
1. **Self-Contained Storage**: Downloaded libraries reside in `~/.rad/packages/<name>/` and are directly importable across projects without root permissions or global package managers.
2. **Cryptographic Integrity**: Every published library version contains a SHA-256 integrity checksum recorded in `registry/index.json`. The package manager verifies archives before unpacking.
3. **Pure Rad First**: Ecosystem libraries are written in 100% pure Rad, ensuring zero external toolchain requirements (no C compiler, Python, or npm needed at compile time).

### Package Query & Discovery Commands

The `rad package` command namespace provides end-to-end registry search, metadata inspection, and package installation:

```bash
rad package <subcommand> [options]
# Alias:
rad pkg <subcommand>
```

| Subcommand | Description | Example |
| :--- | :--- | :--- |
| `search <query>` | Search the central registry for packages matching name or description | `rad package search tui` |
| `info <package>` | Display detailed metadata, license, latest release, and repository | `rad package info rad-tui` |
| `install <package>` | Download and install a library globally into `~/.rad/packages/` | `rad package install rad-tui` |
| `list` | List all dependencies declared in the local project's `rad.toml` | `rad package list` |
| `tree` | Render a visual ASCII dependency tree of all resolved libraries | `rad package tree` |
| `outdated` | Compare project dependencies against the registry for newer versions | `rad package outdated` |

### Search Example:
```bash
rad package search tui
```
Output:
```text
Searching Rad Package Registry (GamerxIOEPB/rad-lib):
  rad-tui (v0.1.0)
    Modern, high-performance, double-buffered Terminal User Interface (TUI) framework in pure Rad

Found 1 matching package(s).
```

### Info Example:
```bash
rad package info rad-tui
```
Output:
```text
Package Information:
  Name:        rad-tui
  Latest:      v0.1.0
  License:     MIT
  Registry:    https://github.com/GamerxIOEPB/rad-lib
  Repository:  https://github.com/GamerxIOEPB/rad-lib
  Description: Modern, high-performance, double-buffered Terminal User Interface (TUI) framework in pure Rad

To install this library for system-wide or project use, run:
  rad add rad-tui
```

---

## 13.5 Project Dependency Workflow

For everyday project development, Rad provides ergonomic top-level command shortcuts that modify your project's `rad.toml` directly:

### 1. Adding a Dependency (`rad add`)
Adds the library to `rad.toml` and installs it to `~/.rad/packages/`:

```bash
rad add rad-tui
rad add rad-json
```

This updates your `rad.toml` automatically:
```toml
[dependencies]
rad-tui = "0.1.0"
rad-json = "0.1.0"
```

### 2. Removing a Dependency (`rad remove`)
Removes the library entry from `rad.toml`:

```bash
rad remove rad-json
```

### 3. Updating Dependencies (`rad update`)
Scans `rad.toml` and checks the central registry for the latest semver-compatible updates:

```bash
# Update all dependencies:
rad update

# Update a specific dependency:
rad update rad-tui
```

### 4. Cache Management (`rad cache`)
Downloaded package archives are cached locally to accelerate offline builds:

```bash
# View cached archives:
rad cache list

# Purge downloaded tarballs:
rad cache clean
```

---

## 13.6 Manifest Specification (`rad.toml`)

Every Rad project and library contains a `rad.toml` manifest at its root:

```toml
[package]
name = "my_game"
version = "0.1.0"
edition = "2026"
description = "A terminal adventure game written in pure Rad"
license = "MIT"
authors = ["Your Name <you@example.com>"]
repository = "https://github.com/username/my_game"
min_rad_version = "0.2.5"

[dependencies]
rad-tui = "0.1.0"
rad-math = "0.1.0"
rad-http = "0.1.0"
```

### Manifest Fields:
- **`name`**: The package identifier (lowercase, alphanumeric, hyphens/underscores).
- **`version`**: Semantic versioning string (`MAJOR.MINOR.PATCH`).
- **`edition`**: Rad language edition (currently `"2026"`).
- **`min_rad_version`**: Minimum `radc` compiler version required to build this library.
- **`dependencies`**: Map of required package names to version constraint strings.

---

## 13.7 Zero-Dependency Static SQLite (`rad-sqlite`)

Rad bundles a hermetic static archive `libsqlite3.a` inside its Musl target sysroots (`lib/targets/x86_64-unknown-linux-musl/lib/libsqlite3.a`). When using `rad-sqlite`:

```bash
rad add rad-sqlite
```

Programs linking against `rad-sqlite` produce standalone static PIE executables with zero host C runtime library dependencies.

---

## 13.8 Creating & Publishing a Library

Creating and publishing a reusable library to the Rad community is simple:

### Step 1: Create a Library Skeleton
```bash
rad new my-utils --lib
cd my-utils
```
This generates:
```text
my-utils/
├── rad.toml
├── README.md
└── src/
    └── lib.rad
```

### Step 2: Implement Your Public API
In `src/lib.rad`, declare your public structs and functions using `pub`:

```rad
// src/lib.rad
pub struct Calculator {}

impl Calculator {
    pub fn add(a: i64, b: i64) -> i64 {
        a + b
    }
}
```

### Step 3: Validate and Publish (`rad publish`)
Run `rad publish` to validate project structure, check `rad.toml` metadata, and compute release checksums:

```bash
# Dry run verification:
rad publish

# Submit release to registry:
rad publish --confirm
```

The package is packaged into an archive, assigned a cryptographic SHA-256 hash, and prepared for indexing in the central `rad-lib` registry.
