# Chapter 2: Installation & Toolchain Setup

## 2.1 Quick Installation (Automated)

The quickest way to install the complete, production-ready Rad toolchain on Linux is using the official installer script via `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/GamerxIOEPB/rad-lang/main/scripts/install.sh | sh
```

### What the Installer Does:
1. Detects your host architecture (`x86_64`) and operating system (`Linux`).
2. Downloads the official release archive (`rad-0.2.0-x86_64-unknown-linux-gnu.tar.gz`) from GitHub Releases.
3. Verifies the cryptographic SHA-256 integrity hash against `SHA256SUMS`.
4. Extracts all binaries, libraries, standard library modules, target sysroots, and embedded LLVM runtime components to `~/.rad`.
5. Automatically configures your shell environment (`~/.bashrc`, `~/.zshrc`, or `~/.profile`) to ensure `~/.rad/bin` is exported in your `PATH`.

To activate your installation in the current terminal, source your shell profile or open a new terminal session:

```bash
source ~/.bashrc
rad --version
radc --version
```

Expected output:
```text
rad 0.2.0 (x86_64-unknown-linux-gnu)
radc 0.2.0 (self-hosted x86_64-unknown-linux-gnu)
```

---

## 2.2 Verifying with `rad doctor`

Rad provides an integrated diagnostic doctor command that verifies every component of your installed toolchain:

```bash
rad doctor
```

Expected diagnostic output:
```text
Rad Toolchain Doctor
====================

  [OK] radc compiler: found (/home/username/.rad/bin/radc)
  [OK] Embedded LLVM & LLD backend: integrated in-process
  [OK] Standard library sources: verified at /home/username/.rad/lib/rad
  [OK] Target sysroot (x86_64-unknown-linux-musl): verified at /home/username/.rad/lib/targets/x86_64-unknown-linux-musl

Status: Toolchain is healthy and ready for self-contained native compilation.
```

---

## 2.3 Non-Interactive & Custom Prefix Installation

For continuous integration (CI) workflows, Docker containers, or system-wide deployments, you can pass arguments to the installer:

```bash
# Non-interactive install without shell prompts:
curl -fsSL https://raw.githubusercontent.com/GamerxIOEPB/rad-lang/main/scripts/install.sh | sh -s -- -y

# Install to a custom directory prefix (e.g., /opt/rad):
curl -fsSL https://raw.githubusercontent.com/GamerxIOEPB/rad-lang/main/scripts/install.sh | sh -s -- --prefix /opt/rad -y

# Install without modifying shell configuration files:
curl -fsSL https://raw.githubusercontent.com/GamerxIOEPB/rad-lang/main/scripts/install.sh | sh -s -- --no-modify-path -y
```

---

## 2.4 Building from Source

If you prefer building the toolchain directly from source:

### Prerequisites:
- Git
- GNU Make (`make`)
- Host Clang & LLVM development libraries (LLVM 18+ or 23+)
- Existing `radc` compiler or prebuilt bootstrap

### Build Steps:
```bash
# Clone the official repository
git clone https://github.com/GamerxIOEPB/rad-lang.git
cd rad-lang

# Build all binaries (compiler with embedded backend, package manager, launchers)
make all

# Verify the freshly built binaries in bin/
./bin/radc --version
./bin/rad doctor

# Run regression test suite (152 tests)
bash rad_tests/radtest/runner/run_tests.sh

# Install into default prefix (~/.rad)
make install
```

---

## 2.5 Toolchain Directory Layout

When installed into `~/.rad`, the directory structure is organized as follows:

```
~/.rad/
├── bin/
│   ├── rad           # Rad package manager & build orchestrator
│   ├── radc          # Self-hosted native compiler with embedded LLVM & LLD
│   ├── rad-clang     # Static PIE C compiler launcher
│   └── rad-clang++   # Static PIE C++ compiler launcher
├── lib/
│   ├── llvm/         # Embedded LLVM runtime libraries and headers
│   ├── clang/        # Clang resource headers (stddef.h, stdarg.h, etc.)
│   ├── rad/          # Rad standard library sources
│   │   ├── core/     # Fundamental types, options, results, math
│   │   ├── alloc/    # Dynamic collections (String, Vec)
│   │   └── std/      # Terminal, keyboard, console, time, io, fs, process
│   └── targets/
│       └── x86_64-unknown-linux-musl/
│           ├── crt/  # C runtime startup objects (rcrt1.o, crti.o, crtn.o)
│           ├── include/ # C headers
│           └── lib/  # Static libraries (libc.a, libclang_rt.builtins-x86_64.a)
└── share/
    └── rad/          # License manifests, release metadata, and targets.toml
```

---

## 2.6 Environment Variables

The toolchain respects the following environment variables:

- **`RAD_HOME`**: Overrides the installation directory prefix (default: `~/.rad`).
- **`PATH`**: Ensure `$RAD_HOME/bin` is in your `PATH`.
- **`RADC`**: Explicit path to the `radc` binary used when executing `make` or build scripts.
- **`RAD_LIB_DIR`**: Explicit path override for the standard library sources.
