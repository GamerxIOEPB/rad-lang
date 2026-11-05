# Rad Best Practices & Idiomatic Patterns

Guidelines for writing clean, efficient, and robust Rad codebases.

## 1. Immutability by Default

Prefer `let` over `var`. Only declare `var` when a variable must change state across iterations or operations:

```rad
// Good
let base_url = "https://api.rad-lang.org";
var retry_count = 0;
```

## 2. Explicit Integer Widths for Interop

When interacting with C, musl, or hardware MMIO, always specify integer types explicitly:

```rad
let size: usize = 1024usize;
let descriptor: i32 = -1;
let mask: u64 = 0xFFFFFFFF00000000u64;
```

## 3. String Interpolation

Use `{variable}` format strings inside `println()` for readable output without verbose manual string concatenation:

```rad
let name = "Rad";
let version = 1;
println("Welcome to {name} version {version}!");
```

## 4. Struct Alignment in Self-Hosted Code

In code compiled with self-hosted `radc`:
- Struct fields use 64-bit alignment (`i64`, `usize`, pointers).
- Avoid mixing 32-bit and 64-bit fields without matching alignment annotations.

## 5. Clean Error Propagation

Prefer returning `Result<T, E>` over panicking or printing errors directly from library functions:

```rad
fn compute(input: i32) -> Result<i32, str> {
    if input < 0 {
        return Result::Err("Input must be non-negative");
    }
    return Result::Ok(input * 2);
}
```
