# Chapter 7: Functions & Program Entry

## 7.1 Declaring Functions

Functions in Rad are declared using the `fn` keyword, followed by the function name, a comma-separated parameter list enclosed in parentheses, an optional return type arrow (`-> Type`), and a mandatory body block enclosed in `{ ... }`:

```rad
fn add(a: i64, b: i64) -> i64 {
    return a + b
}

fn greet(name: str) {
    println("Hello, {}!", name)
}
```

If a function does not return a value, the `-> Type` annotation can be omitted (implicitly returning `void`).

---

## 7.2 The `return` Statement

In Rad, functions that return a value must explicitly use the `return` statement:

```rad
fn max_val(a: i64, b: i64) -> i64 {
    if a > b {
        return a
    } else {
        return b
    }
}
```

Functions can also use early returns for guard clauses:

```rad
fn compute_ratio(numerator: i64, denominator: i64) -> i64 {
    if denominator == 0 {
        println("Error: division by zero!")
        return 0
    }
    return numerator / denominator
}
```

---

## 7.3 Mutable Parameters (`var`)

Function arguments are immutable by default within the function body. If a parameter's local copy needs to be mutated, prefix the parameter name with `var`:

```rad
fn countdown(var count: i64) {
    while count > 0 {
        println("T-minus {count}...")
        count = count - 1
    }
    println("Liftoff!")
}
```

Notice that parameters in Rad are passed by value: modifying `var count` modifies the local parameter variable and does not affect the caller's variable.

---

## 7.4 Public Visibility (`pub`)

When authoring multi-file projects or reusable libraries, items that should be accessible outside their defining module are marked with `pub`:

```rad
pub fn calculate_hash(data: *raw u8, len: usize) -> u64 {
    // Implementation
    return 0u64
}
```

---

## 7.5 The `main` Entry Point

Every executable Rad program begins execution at the `main` function. Rad supports two valid signatures for `main`:

### 1. Simple Zero-Argument Entry:
```rad
fn main() -> i32 {
    println("Application running")
    return 0 // Process exit code 0 (success)
}
```

Or omitting the explicit return type:
```rad
fn main() {
    println("Exits with code 0 by default")
}
```

### 2. Command-Line Arguments Entry:
To receive command-line arguments passed from the operating system shell:

```rad
fn main(argc: i32, argv: *raw *raw u8) -> i32 {
    println("Program name: {}", argv[0usize] as str)
    println("Argument count: {}", argc)

    var i: usize = 1usize
    while i < (argc as usize) {
        let arg_str: str = argv[i] as str
        println("Arg #{}: {}", i, arg_str)
        i = i + 1usize
    }

    return 0
}
```

Here:
- `argc`: Number of arguments (including program name at index 0).
- `argv`: Raw pointer to an array of null-terminated C string pointers (`*raw *raw u8`).
- Returning an integer value sets the Linux process exit status (returned to the calling shell via `$?`).
