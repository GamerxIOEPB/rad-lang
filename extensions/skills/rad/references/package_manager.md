# Rad Package Manager (`rad`) Specification

The `rad` executable is the official build tool and package manager for the Rad language, implemented in self-hosted Rad.

## 1. CLI Commands

| Command | Description | Example |
|---|---|---|
| `rad new <name>` | Create a new Rad project with default structure | `rad new my_app` |
| `rad init` | Initialize a Rad project in current directory | `rad init` |
| `rad build` | Compile the project into `target/` | `rad build --release` |
| `rad run` | Build and immediately execute the project binary | `rad run` |
| `rad test` | Run project unit and integration test suites | `rad test` |
| `rad check` | Fast syntax and type verification without binary emission | `rad check` |
| `rad clean` | Remove `target/` build artifacts | `rad clean` |
| `rad doctor` | Inspect environment, sysroots, and compilers | `rad doctor` |
| `rad --version` | Print package manager version | `rad -V` |

## 2. Project Layout

```text
my_app/
├── rad.toml           # Project manifest
└── src/
    └── main.rad       # Application entry point
```

## 3. Project Manifest (`rad.toml`)

```toml
[package]
name = "my_app"
version = "0.1.0"
edition = "2024"
authors = ["Author <author@example.com>"]

[dependencies]
# Future package repository registry dependencies
```

## 4. `rad doctor` Environment Diagnostics

`rad doctor` inspects:
- `radc` compiler presence in `PATH` or `~/.rad/bin`.
- Bundled static PIE launchers (`rad-llc`, `rad-lld`).
- Canonical target sysroot (`lib/targets/x86_64-unknown-linux-musl`).
- Host fallback toolchains (`llc`, `ld.lld`, `clang`).
