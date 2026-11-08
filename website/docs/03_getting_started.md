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

    println(message)
    print("Welcome to Rad in year: ")
    println(year)
    return 0
}
```

### 2. Compile with `radc`
Invoke the self-hosted Rad compiler directly:

```bash
radc hello.rad -o hello
```

The compiler directly emits optimized machine code and links the static PIE executable in-process.

### 3. Run the Native Executable
```bash
./hello
```

Output:
```text
Hello, World from Rad!
Welcome to Rad in year: 2026
```

### 4. Inspect the Executable
Check the properties of the resulting binary using standard Linux utilities:

```bash
file hello
ldd hello
```

Output:
```text
hello: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), statically linked, stripped
not a dynamic executable
```

Notice that `hello` is **statically linked** and **not a dynamic executable**! It has zero dependencies on host glibc versions and will run identically on Ubuntu, Debian, Alpine Linux, Arch Linux, or container environments.

---

## 3.2 Multi-File Projects & Modular Imports

Rad supports modular development across multiple files using intuitive file-relative imports.

### 1. Create a Helper Module (`math_ops.rad`)
```rad
// math_ops.rad — Reusable math utilities
pub fn add(a: i32, b: i32) -> i32 {
    return a + b
}

pub fn factorial(n: i32) -> i32 {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}
```

### 2. Import into `main.rad`
Use the `./` syntax to import local sibling files:

```rad
// main.rad — Modular application entry point
import ./math_ops.rad

fn main() -> i32 {
    let sum = math_ops::add(15, 27)
    let fact = math_ops::factorial(5)

    print("Sum: ")
    println(sum)

    print("Factorial of 5: ")
    println(fact)
    return 0
}
```

### 3. Compile Directly
```bash
radc main.rad -o math_app
./math_app
```

Output:
```text
Sum: 42
Factorial of 5: 120
```

---

## 3.3 Using the Rad Package Manager (`rad`)

For production projects and libraries, use the `rad` package manager to initialize, build, and organize your software.

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
`rad new` creates a standard project layout:

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
version = "0.2.0"
edition = "2026"

[dependencies]
# External dependencies
```

### The Generated Entry Point (`src/main.rad`)
```rad
fn main() -> i32 {
    println("Hello from Rad Package!")
    return 0
}
```

---

## 3.4 Building and Running Packages

### Checking Syntax without Compiling
To rapidly check your code for syntax errors and structural validity without invoking backend code generation:

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

Pass command-line arguments to your application by separating them with `--`:

```bash
rad run -- --port 8080 --verbose
```

### Cleaning Build Artifacts
To wipe generated binaries and object files:

```bash
rad clean
```

---

## 3.5 Creating a Library Package

If you are developing a reusable library rather than an executable application, pass the `--lib` flag:

```bash
rad new my_library --lib
```

This creates a library skeleton with `src/lib.rad`:

```rad
// src/lib.rad — Reusable library interface
pub fn compute_hash(seed: u64, input: str) -> u64 {
    var hash = seed
    let len = str_len(input)
    var i = 0usize
    while i < len {
        hash = (hash ^ (input[i] as u64)) * 1099511628211u64
        i = i + 1
    }
    return hash
}
```
