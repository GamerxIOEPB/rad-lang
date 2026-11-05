# Chapter 3: Getting Started

## 3.1 Your First Rad Program ("Hello, World!")

Let's start by writing and compiling a standalone Rad program from scratch.

### 1. Create a Source File
Create a new file named `hello.rad`:

```rad
// hello.rad — My first Rad program
fn main() -> i32 {
    let message: str = "Hello, World from Rad!"
    let year: i32 = 2026

    println("{} - Welcome to {}", message, year)
    return 0
}
```

### 2. Compile with `radc`
Invoke the self-hosted Rad compiler directly:

```bash
radc hello.rad -o hello
```

### 3. Run the Native Executable
```bash
./hello
```

Output:
```text
Hello, World from Rad! - Welcome to 2026
```

### 4. Inspect the Executable
Check the properties of the resulting binary using standard Linux tools:

```bash
file hello
ldd hello
```

Output:
```text
hello: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), statically linked, stripped
not a dynamic executable
```

Notice that `hello` is **statically linked** and **not a dynamic executable**! It has zero dependencies on host glibc versions and will run on any 64-bit Linux machine.

---

## 3.2 Using the Rad Package Manager (`rad`)

For anything beyond single-file scripts, use the `rad` package manager to initialize, build, and organize your projects.

### Creating a New Application Package
Run `rad new` followed by the project name:

```bash
rad new my_project
cd my_project
```

Output:
```text
Creating new Rad package...
Created binary (application) package successfully!
```

### Project Directory Layout
`rad new` creates a standard directory layout:

```
my_project/
├── rad.toml        # Package manifest & configuration
├── .gitignore      # Ignores target/ build output and temporary files
└── src/
    └── main.rad    # Main application entry point
```

### The Manifest (`rad.toml`)
The `rad.toml` file defines package metadata:

```toml
[package]
name = "my_project"
version = "0.1.0"
edition = "2026"

[dependencies]
```

### The Generated Code (`src/main.rad`)
```rad
fn main() -> i32 {
    println("Hello from Rad Package!")
    return 0
}
```

---

## 3.3 Building and Running Packages

### Checking Syntax without Compiling
To rapidly check your code for syntax errors and structural validity without performing full LLVM compilation:

```bash
rad check
```

Output:
```text
Checking Rad package syntax and types...
Check complete: 0 errors.
Check passed: 0 errors.
```

### Compiling with `rad build`
Compile the package into a debug executable:

```bash
rad build
```

This compiles `src/main.rad` into `target/debug/main`.

To build an optimized release binary with LLVM `-O3` optimizations:

```bash
rad build --release
```

This places the optimized binary in `target/release/main`.

### Running with `rad run`
Build and immediately execute your application in one step:

```bash
rad run
```

Output:
```text
Compiling project with radc...
Finished build successfully.
Running...
Hello from Rad Package!
```

You can pass command-line arguments to your application by separating them after `--`:

```bash
rad run -- arg1 arg2
```

### Cleaning Build Artifacts
To wipe generated binaries and object files:

```bash
rad clean
```

---

## 3.4 Creating a Library Package

If you are developing a reusable library rather than an executable application, pass the `--lib` flag:

```bash
rad new my_library --lib
```

This generates `src/lib.rad` instead of `src/main.rad`.
