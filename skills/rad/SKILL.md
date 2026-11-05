---
name: rad
description: Comprehensive development, authoring, and debugging guide for the Rad systems programming language and its self-contained toolchain.
---

# Rad Programming Language — AI Coding Skill

The **Rad programming language** is a modern, statically-typed systems programming language combining high performance, predictable memory semantics, seamless C/C++ interoperability, and self-contained static PIE compilation.

This skill equips AI models with complete, accurate knowledge for writing, refactoring, building, and debugging Rad codebases using the native `rad` package manager and `radc` compiler.

---

## Toolchain Architecture

The Rad toolchain is fully self-contained and operates across three primary components:

1. **`rad`**: Native Package Manager & Build Orchestrator
   - Location: `~/.rad/bin/rad`
   - Commands: `rad new <name>`, `rad build`, `rad run`, `rad test`, `rad doctor`, `rad check`, `rad clean`.
   - Manifest: `rad.toml` in project root.

2. **`radc`**: Self-Hosted Compiler
   - Location: `~/.rad/bin/radc`
   - Direct SSA LLVM IR code generator with Pratt recursive descent parser.
   - Flags: `-o <out>`, `-O<0|1|2|3>`, `--emit-llvm`, `--check`, `--target <triple>`, `--linker <cmd>`, `-V`/`--version`.

3. **Bundled Static PIE Backend (`rad-llc` & `rad-lld`)**:
   - Location: `~/.rad/bin/rad-llc`, `~/.rad/bin/rad-lld`
   - Target sysroot: `~/.rad/lib/targets/x86_64-unknown-linux-musl/`
   - Default emission: Static Position-Independent Executable (`static-pie`) with zero external shared library dependencies (`no PT_INTERP`, `no DT_NEEDED`).

---

## Core Language Syntax & Idioms

### 1. Program Structure & Entry Point

```rad
// Hello World in Rad
fn main() {
    println("Hello, Rad!");
}
```

Void-returning `main` defaults to exit code `0`. A function returning an explicit exit code can declare `fn main() -> i32 { return 0; }`.

### 2. Variables & Mutability

Variables are immutable by default using `let`. Mutable variables require `var`:

```rad
let immutable_val = 42;
var counter = 0;
counter = counter + 1;
```

### 3. Primitive Types

- **Signed Integers**: `i8`, `i16`, `i32`, `i64`, `isize` (literals default to `i32` or typed suffix like `42i64`)
- **Unsigned Integers**: `u8`, `u16`, `u32`, `u64`, `usize` (literals like `10usize`, `0u8`)
- **Floating Point**: `f32`, `f64`
- **Boolean**: `bool` (`true`, `false`)
- **Character**: `char` (`'a'`)
- **String Literals**: `str` (null-terminated pointer to immutable string slice)
- **Raw Pointers**: `*raw u8`, `*raw var u8`

### 4. Compound Types

```rad
// Struct declaration
struct Point {
    x: i64,
    y: i64,
}

// Struct instantiation
let pt = Point {
    x: 10i64,
    y: 20i64,
};

// Accessing fields
let px = pt.x;
```

### 5. String Interpolation & Printing

Rad supports `{variable}` format interpolation inside `println()`:

```rad
let a = 10;
println("The value of variable a is: {a}");
```

Formatted printing with C-style format specifiers is also supported:

```rad
printf("The value is: %d\n", a);
```

### 6. Control Flow

```rad
// If-else
if x > 10 {
    println("greater");
} else if x == 10 {
    println("equal");
} else {
    println("less");
}

// While loop
var i = 0usize;
while i < 10usize {
    println("i = {i}");
    i = i + 1usize;
}

// Loop with break/continue
loop {
    if condition {
        break;
    }
}
```

### 7. Methods and Implementation Blocks

```rad
struct Counter {
    val: i64,
}

impl Counter {
    fn new(start: i64) -> Counter {
        return Counter { val: start };
    }

    fn increment(var self) {
        self.val = self.val + 1i64;
    }

    fn get(self) -> i64 {
        return self.val;
    }
}
```

### 8. C & C++ Interoperability

Rad links directly with C and C++ code:

```rad
// C standard library interop
extern "C" {
    fn puts(s: str) -> i32;
    fn malloc(size: usize) -> *raw u8;
    fn free(ptr: *raw u8);
}
```

---

## Detailed Topic References

For exhaustive language, compiler, and stdlib specifications, consult the reference documents in `skills/rad/references/`:

1. [Grammar & EBNF](file:///home/abhinav/Projects/rad/skills/rad/references/grammar.md)
2. [Type System](file:///home/abhinav/Projects/rad/skills/rad/references/type_system.md)
3. [Ownership & Memory Model](file:///home/abhinav/Projects/rad/skills/rad/references/ownership_and_borrowing.md)
4. [Error Handling & Options](file:///home/abhinav/Projects/rad/skills/rad/references/error_handling.md)
5. [Pattern Matching & Enums](file:///home/abhinav/Projects/rad/skills/rad/references/pattern_matching.md)
6. [Control Flow](file:///home/abhinav/Projects/rad/skills/rad/references/control_flow.md)
7. [Functions & Methods](file:///home/abhinav/Projects/rad/skills/rad/references/functions_and_methods.md)
8. [Structs & Custom Types](file:///home/abhinav/Projects/rad/skills/rad/references/structs_and_enums.md)
9. [C Interoperability](file:///home/abhinav/Projects/rad/skills/rad/references/c_interop.md)
10. [C++ Interoperability](file:///home/abhinav/Projects/rad/skills/rad/references/cpp_interop.md)
11. [Standard Library](file:///home/abhinav/Projects/rad/skills/rad/references/standard_library.md)
12. [Package Manager (`rad`)](file:///home/abhinav/Projects/rad/skills/rad/references/package_manager.md)
13. [Compiler Internals (`radc`)](file:///home/abhinav/Projects/rad/skills/rad/references/compiler_internals.md)
14. [Best Practices & Idioms](file:///home/abhinav/Projects/rad/skills/rad/references/best_practices.md)
15. [Diagnostics & Errors](file:///home/abhinav/Projects/rad/skills/rad/references/diagnostics_and_errors.md)
16. [Migration Guide (C/C++/Rust/Python)](file:///home/abhinav/Projects/rad/skills/rad/references/migration_guide.md)
