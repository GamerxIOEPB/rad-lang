# Chapter 1: What is Rad?

## 1.1 Philosophy & Design Goals

The **Rad programming language** is a modern, statically typed systems programming language designed for writing high-performance, predictable, and robust native software. Rad was created to offer the mechanical sympathy, raw performance, and low-level hardware control of C, paired with the safety, ergonomics, and clarity of modern languages—without requiring a heavy runtime garbage collector or overly complex compile-time lifetime annotations.

### Core Tenets

1. **Self-Contained Static Executables**: Every binary produced by the Rad compiler (`radc`) is linked as a static Position-Independent Executable (`static-pie`) against a canonical Musl libc sysroot. Executables have zero dynamic library dependencies (`no PT_INTERP`, `no DT_NEEDED`), running reliably across any Linux kernel without distribution-specific runtime issues or glibc version mismatches.
2. **Embedded In-Process LLVM & LLD Engine**: Starting in version 0.2.0, `radc` embeds the LLVM code generation engine and LLD ELF linker directly in-process via a high-performance C++ backend bridge. This eliminates the latency and file I/O overhead of spawning external assembler and linker subprocesses (`rad-llc`, `rad-lld`), enabling near-instant compilation directly from source to optimized native machine code.
3. **Zero-Overhead C & C++ Interoperability**: Rad speaks the C ABI natively. Standard C library functions (`malloc`, `free`, `puts`, `printf`, `system`, POSIX file I/O) are direct zero-cost calls without wrapper bloat, marshaling, or FFI barriers. Multi-language projects compile smoothly using bundled `rad-clang` and `rad-clang++`.
4. **Pure Native Standard Library & Syscalls**: Rad's standard library (`std`) provides rich subsystems—including raw terminal manipulation, ANSI color styling, Kitty keyboard protocol event parsing, double-buffered console rendering, and nanosecond monotonic timing—implemented purely in Rad using direct compiler system-call intrinsics, completely independent of libc wrappers, ncurses, or external C libraries.
5. **Predictable Memory Semantics**: Rad uses explicit value semantics, direct heap allocations via built-in dynamic collections (`String`, `Vec<T>`), and transparent raw pointer manipulation (`*raw T`) when interfacing with hardware or legacy systems. There is no hidden runtime overhead, tracing garbage collection pauses, or hidden stop-the-world phases.
6. **Self-Hosted, Single-Pass/Two-Pass Speed**: The production Rad compiler (`radc`) is written entirely in Rad. It compiles directly into SSA (Static Single Assignment) LLVM IR, pairing blazing compile times with LLVM's world-class optimization pipeline (`-O2`, `-O3`).
7. **Batteries-Included Unified Toolchain**: Rad ships as a complete, hermetic toolchain comprising the compiler (`radc`), the package manager and build orchestrator (`rad`), the embedded LLVM/LLD engine, and full C/C++ compilers (`rad-clang`, `rad-clang++`).

---

## 1.2 Architectural Overview

The Rad ecosystem is structured into four tightly integrated layers:

```
┌─────────────────────────────────────────────────────────────┐
│                 Rad Developer Applications                  │
│       src/*.rad, rad.toml, packages, terminal games         │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               Rad Toolchain & Package Manager               │
│                 rad (Package Manager & CLI)                 │
│   • rad new / rad init            • rad run / rad test      │
│   • rad build [--release]         • rad doctor / rad check  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│            radc (Self-Hosted Compiler & Backend)            │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Frontend: Lexer, Pratt AST Parser, SSA Generator   │   │
│   └──────────────────────────┬──────────────────────────┘   │
│                              ▼                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  Embedded Backend Bridge (LLVM & LLD In-Process)    │   │
│   │  • LLVM TargetMachine: In-memory IR to Object (.o)  │   │
│   │  • LLD ELF Driver: Direct in-process static linking │   │
│   └─────────────────────────────────────────────────────┘   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              Canonical Musl Target Sysroot                  │
│   Target: x86_64-unknown-linux-musl                         │
│   Assets: rcrt1.o, crti.o, libc.a, libclang_rt.builtins     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Standalone Static PIE Binary                │
│             Zero shared library dependencies                │
│         Runs anywhere on Linux: Alpine, Ubuntu, Arch        │
└─────────────────────────────────────────────────────────────┘
```

### The Component Pipeline

- **`rad`**: The user-facing command-line interface and package orchestrator. It manages project layout, initializes packages (`rad new`, `rad init`), coordinates compilation modes (`rad build`), runs test suites (`rad test`), and performs comprehensive toolchain diagnostics (`rad doctor`).
- **`radc`**: The self-hosted compiler. Written in pure Rad, it tokenizes source files with a high-speed lexer, constructs an arena-based Abstract Syntax Tree using a Pratt recursive descent parser, validates types and scopes, and directly generates optimized textual SSA LLVM IR.
- **Embedded LLVM & LLD Engine**: Rather than invoking external command-line tools across multiple disk read/write cycles, `radc` links directly with LLVM's TargetMachine C API and LLD's `lld::elf::link` entry point. Intermediate bitcode is compiled to object machine code in memory, and the executable is linked into a static PIE binary in a single unified compiler invocation.
- **`rad-clang` & `rad-clang++`**: Hermetic C and C++ compiler launchers configured with Rad's static Musl sysroot, enabling seamless mixed-language projects and native C/C++ static library compilation.

---

## 1.3 Practical Code Examples

To get a concrete sense of Rad's syntax and ergonomics, review the following real-world examples:

### Example 1: Hello World & Dynamic Collections

```rad
// main.rad — Basic syntax, String, and Vec dynamic collections
fn main() -> i32 {
    let greeting = "Hello from Rad!"
    println(greeting)

    // Dynamic contiguous vector
    var numbers: Vec<i32> = Vec::new()
    var i = 1
    while i <= 5 {
        numbers.push(i * 10)
        i = i + 1
    }

    print("Collected numbers: ")
    var j = 0usize
    while j < numbers.len {
        print(numbers.get(j))
        print(" ")
        j = j + 1
    }
    println("")
    return 0
}
```

### Example 2: Structs, Methods & Value Semantics

```rad
// Point struct with methods and value transformations
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(x: i32, y: i32) -> Point {
        return Point { x: x, y: y }
    }

    fn translate(var self, dx: i32, dy: i32) {
        self.x = self.x + dx
        self.y = self.y + dy
    }

    fn distance_squared(self, other: Point) -> i32 {
        let dx = self.x - other.x
        let dy = self.y - other.y
        return dx * dx + dy * dy
    }
}

fn main() -> i32 {
    var p1 = Point::new(10, 20)
    let p2 = Point::new(13, 24)

    p1.translate(3, 4)
    println("Distance squared: ")
    println(p1.distance_squared(p2))
    return 0
}
```

### Example 3: Zero-Overhead C ABI Interoperability

Calling standard C library functions or POSIX system APIs requires zero wrappers or marshaling code:

```rad
// Direct C ABI declarations
extern "C" {
    fn puts(s: str) -> i32;
    fn getpid() -> i32;
    fn malloc(size: usize) -> *raw u8;
    fn free(ptr: *raw u8) -> void;
}

fn main() -> i32 {
    puts("Direct call to C puts() with zero overhead!")
    let pid = getpid()
    println(pid)

    // Raw memory allocation
    let buf = malloc(1024usize)
    if (buf as usize) != 0usize {
        buf[0] = 65u8 // 'A'
        free(buf)
    }
    return 0
}
```

### Example 4: Pure-Rad System Call & Monotonic Timing

Rad standard library features do not require libc wrappers:

```rad
import std::time
import std::terminal

fn main() -> i32 {
    // High-resolution monotonic timing via Linux clock_gettime syscall intrinsic
    let start = time::now_ms()

    // Pure native ANSI terminal styling
    terminal::enable_raw_mode()
    terminal::set_fg(terminal::Color::Cyan)
    print("Welcome to native Rad systems programming!\n")
    terminal::reset_color()

    time::sleep_ms(250) // Microsecond-accurate nanosleep syscall

    let elapsed = time::now_ms() - start
    terminal::disable_raw_mode()

    println("Elapsed ms: ")
    println(elapsed)
    return 0
}
```

### Statement Separation Rules

Rad recognizes both newlines and semicolons as statement separators:
- **Newline-separated statements**: Statements placed on separate lines do not require terminating semicolons:
  ```rad
  println("Hello")
  println("World")

  let x = 10
  let y = 20
  ```
- **Same-line statements**: Multiple statements placed on the same line must be explicitly separated by semicolons:
  ```rad
  println("Hello"); println("World")
  let x = 10; let y = 20
  ```
- **Same-line rejection without separators**: Adjacent statements on the same line without a semicolon are rejected at compile time with a clear syntax error (`error[E0001]`):
  ```rad
  println("Hello") println("World") // Error: expected ';' or newline between statements on the same line
  ```
- **Optional trailing semicolons & empty statements**: Trailing semicolons before closing braces (`let x = 10; }`) and consecutive semicolons (`x = 1;; y = 2;`) representing empty statements are fully accepted.
- **Multiline expressions**: Expressions spanning across lines (parentheses, binary operators, method chains) preserve their natural continuation without requiring semicolons.
- **Struct fields**: Fields can be separated by commas (`,`), semicolons (`;`), or newlines. Same-line struct fields require an explicit separator (`struct Point { x: i32, y: i32 }` or `struct Point { x: i32; y: i32 }`).

---

## 1.4 How Rad Compares to Other Languages

| Feature | Rad | C | C++ | Rust | Zig | Go |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Garbage Collection** | **None** | None | None | None | None | Concurrent Tracing GC |
| **Runtime Overhead** | **Zero** | Zero | Minimal | Zero | Zero | Moderate (Scheduler, GC) |
| **Default Binary Format** | **Static PIE** | Dynamic ELF | Dynamic ELF | Dynamic / Static | Static PIE | Static ELF |
| **Compiler Backend** | **Embedded LLVM+LLD** | External | External | External LLVM | Bundled / LLVM | Custom / Internal |
| **C Interoperability** | **Direct C ABI** | Native | Native | Via FFI bindings | Direct | Via Cgo (High Overhead) |
| **Package Manager** | **Built-in (`rad`)** | None | CMake/Conan | Built-in (`cargo`) | Built-in | Built-in (`go`) |
| **Type Safety** | **Strong, Static** | Weak | Strong | Strict Lifetime Borrowing | Strong | Strong |
| **Compilation Speed** | **Fast (In-Process)** | Very Fast | Slow | Slow to Moderate | Fast | Very Fast |
| **Standard Library** | **Pure Native (Syscall)**| Libc | Libc/Libstdc++| Libc / Core | Syscall | Syscall |
| **Toolchain Self-Containment** | **Full (Sysroot Included)** | External | External | External Linkers | Self-Contained | Self-Contained |

---

## 1.5 When to Choose Rad

Choose Rad when your project demands:
- **Zero-Dependency Portability**: Standalone binaries that deploy effortlessly to any Linux environment (minimal containers, Alpine, Debian, Arch, embedded appliances) without shared library conflicts or libc incompatibility.
- **Embedded Compiler Performance**: Rapid build cycles powered by in-process LLVM code generation and LLD static linking without subprocess overhead.
- **Low-Level Control with High Ergonomics**: Explicit pointer management, predictable value semantics, dynamic vectors, strings, and pattern matching without GC pauses or complex lifetime puzzles.
- **Pure Native Systems Development**: Terminal user interfaces, arcade engines, game loops, system daemons, and operating system utilities built directly against kernel syscalls.
- **Frictionless C/C++ Integration**: Zero-cost calling into existing C/C++ libraries and header ecosystems without complicated binding generators.
