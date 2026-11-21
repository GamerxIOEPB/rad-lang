# Rad Package Manager (`rad`) Specification

The `rad` executable is the official package manager, build orchestrator, formatter, language server daemon, and verification tool for the Rad language.

---

## 1. CLI Commands & Subcommands

### Project Commands
| Command | Description | Example |
|---|---|---|
| `rad new <name>` | Create a new Rad application package | `rad new my_app` |
| `rad new <name> --lib` | Create a new Rad library package | `rad new my_lib --lib` |
| `rad init` | Initialize a Rad package in the current directory | `rad init` |
| `rad build` | Compile the current package (outputs to `bin/` or `target/`) | `rad build --release` |
| `rad run [args]` | Build and execute the binary in one step | `rad run -- --port 8080` |
| `rad test` | Run unit, integration, and doctests | `rad test` |
| `rad bench` | Run package performance benchmarks | `rad bench` |
| `rad doc` | Generate static HTML documentation | `rad doc` |
| `rad check` | Fast syntax and type analysis without binary emission | `rad check` |
| `rad clean` | Remove build artifacts | `rad clean` |

### Dependency & Registry Commands
| Command | Description | Example |
|---|---|---|
| `rad add <pkg>` | Add dependency to `rad.toml` and install it | `rad add rad-tui` |
| `rad remove <pkg>` | Remove a dependency from `rad.toml` | `rad remove rad-tui` |
| `rad update [pkg]` | Update dependencies to latest compatible SemVer | `rad update` |
| `rad fetch [pkg]` | Fetch dependencies and resolve SAT SemVer constraints | `rad fetch` |
| `rad publish [--confirm]` | Sign package with Ed25519 and publish to registry | `rad publish --confirm` |
| `rad package <cmd>` | Manage registry (`install`, `publish`, `search`, `info`, `tree`, `outdated`) | `rad package search http` |
| `rad cache [list\|clean]`| Manage package download cache (`~/.rad/cache/`) | `rad cache clean` |

### Tooling & Diagnostic Commands
| Command | Description | Example |
|---|---|---|
| `rad fmt` | Format Rad source files in-place or check formatting | `rad fmt --check` |
| `rad lsp` | Run Language Server Protocol daemon over stdio | `rad lsp` |
| `rad verify <file>` | Formally prove memory safety & invariants via SMT | `rad verify src/main.rad` |
| `rad repl` | Launch interactive Rad REPL | `rad repl` |
| `rad doctor` | Audit toolchain, LLVM launchers, and musl sysroots | `rad doctor` |
| `rad toolchain` | Manage Rad compiler versions and updates | `rad toolchain update` |

---

## 2. Package Manifest (`rad.toml`)

```toml
[package]
name = "my_app"
version = "0.2.4"
description = "High-performance native networking service"
license = "MIT"
authors = ["Rad Developer <developer@rad-lang.org>"]
min_rad_version = "0.2.4"

[dependencies]
rad-tui = "^0.1.0"
rad-http = "~1.2.0"

[dev-dependencies]
rad-test = "^0.1.0"
```

---

## 3. Lockfile (`rad.lock`) & SAT Dependency Resolution

Rad generates reproducible `rad.lock` manifests using a Boolean SAT-based SemVer constraint solver:
- Solves transitive dependencies without version oscillation.
- Validates SHA-256 package checksums against the content-addressable registry.
- Verifies Ed25519 cryptographic publisher signatures.

---

## 4. Formal Contract Verification (`rad verify`)

When running `rad verify <file.rad>`:
1. Preconditions (`requires`) and postconditions (`ensures`) are parsed.
2. Invariants are lowered to SMT-LIB2 queries checked against the Z3/CVC5 theory solver.
3. Flow-sensitive escape analysis automatically promotes non-escaping heaps to zero-cost stack frames.

---

## 5. Consolidated Library & Package Layout (`lib/rad`)

All official standard libraries and registry packages are consolidated directly under `lib/rad/` (`~/.rad/lib/rad/` and `./lib/rad/`):
- Both canonical package names (`rad-tui`, `rad-json`, `rad-args`, etc.) and shorthand aliases (`tui`, `json`, `args`, etc.) reside in `lib/rad/`.
- Both `import tui;` and `import rad_tui;` resolve automatically with zero external compiler link flags.
- `rad install` installs packages directly to `~/.rad/lib/rad/<pkg>/` and creates shorthand alias symlinks.
- `~/.rad/packages` is maintained as a backward-compatible symlink to `~/.rad/lib/rad/`.
3. Flow-sensitive escape analysis checks that dynamic structures do not escape local frames.
4. Array bounds safety and 64-bit arithmetic overflow freedom are proven before execution.
