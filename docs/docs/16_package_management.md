# Chapter 16: Package Registry, Dependency Management & Creating Libraries

Rad provides an integrated, zero-dependency native package management ecosystem built directly into the `rad` CLI. Starting with Rad v0.2.4, package operations are structured cleanly under the `rad package` namespace alongside top-level developer shortcuts (`rad add`, `rad remove`, `rad update`).

---

## 16.1 The Rad Package Ecosystem (`rad-lib`)

Rad packages (libraries) are distributed through the official Git-backed central registry: [**GamerxIOEPB/rad-lib**](https://github.com/GamerxIOEPB/rad-lib).

### Key Architectural Pillars:
1. **Self-Contained Storage**: Downloaded libraries reside in `~/.rad/packages/<name>/` and are directly importable across projects without root permissions or global package managers.
2. **Cryptographic Integrity**: Every published library version contains a SHA-256 integrity checksum recorded in `registry/index.json`. The package manager verifies archives before unpacking.
3. **Pure Rad First**: Ecosystem libraries are written in 100% pure Rad, ensuring zero external toolchain requirements (no C compiler, Python, or npm needed at compile time).

---

## 16.2 Package Query & Discovery Commands

The `rad package` command namespace provides end-to-end registry search, metadata inspection, and package installation:

```bash
rad package <subcommand> [options]
# Alias:
rad pkg <subcommand>
```

### Available Subcommands:

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

## 16.3 Project Dependency Workflow

For everyday project development, Rad retains ergonomic top-level command shortcuts that modify your project's `rad.toml` directly:

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

## 16.4 Anatomy of `rad.toml`

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
min_rad_version = "0.2.4"

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

## 16.5 Importing Libraries in Your Code

Once a package is installed in `~/.rad/packages/<name>/` or declared in `rad.toml`, you import it directly by package name. The compiler seamlessly resolves symbols from the library's `src/lib.rad`:

```rad
// main.rad
import "rad-tui";
import "rad-math";

fn main() -> i32 {
    let screen = Screen.new();
    let vec = Vec2.new(10.0, 20.0);
    println("Initialized game screen with vector coordinates!");
    return 0;
}
```

---

## 16.6 Creating & Publishing a Library

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
