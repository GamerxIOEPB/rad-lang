# Chapter 7: Functions & Program Entry

## 7.1 Declaring Functions

Functions in Rad are declared using the `fn` keyword, followed by the function name, a comma-separated parameter list enclosed in parentheses, an optional return type arrow (`-> Type`), and a mandatory body block enclosed in `{ ... }`:

```rad
fn add(a: i64, b: i64) -> i64 {
    return a + b
}

fn greet(name: str) {
    print("Hello, ")
    println(name)
}
```

If a function does not return a value, the `-> Type` annotation can be omitted (implicitly returning `void`).

---

## 7.2 The `return` Statement

In Rad, functions that produce a result value must explicitly use the `return` statement:

```rad
fn max_val(a: i64, b: i64) -> i64 {
    if a > b {
        return a
    } else {
        return b
    }
}
```

Functions can also use early returns for defensive guard clauses:

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
        print("T-minus: ")
        println(count)
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
    var hash = 14695981039346656037u64
    var i = 0usize
    while i < len {
        hash = (hash ^ (data[i] as u64)) * 1099511628211u64
        i = i + 1
    }
    return hash
}
```

---

## 7.5 Recursion

Rad functions fully support recursion:

```rad
pub fn fibonacci(n: i64) -> i64 {
    if n <= 0 {
        return 0
    }
    if n == 1 {
        return 1
    }
    return fibonacci(n - 1) + fibonacci(n - 2)
}
```

---

## 7.6 The `main` Entry Point

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
    print("Program name: ")
    println(argv[0usize] as str)

    print("Argument count: ")
    println(argc)

    var i: usize = 1usize
    while i < (argc as usize) {
        let arg_str: str = argv[i] as str
        print("Arg: ")
        println(arg_str)
        i = i + 1usize
    }

    return 0
}
```

Here:
- `argc`: Number of arguments (including program name at index 0).
- `argv`: Raw pointer to an array of null-terminated C string pointers (`*raw *raw u8`).
- Returning an integer value sets the Linux process exit status (inspectable via `$?` in bash).

---

## 7.7 Built-In I/O Functions

Rad provides essential I/O functions built directly into the language runtime without requiring imports:

| Function | Signature | Description |
| :--- | :--- | :--- |
| `println` | `fn println(fmt: str, ...)` | Prints formatted output to `stdout` with a trailing newline (`\n`). |
| `print` | `fn print(fmt: str, ...)` | Prints formatted output to `stdout` **without** a trailing newline and flushes `stdout`. |
| `input` | `fn input(prompt: str = "") -> String` | Reads a line from `stdin` (blocking) and returns a dynamic heap `String` without trailing newline. |
| `eprintln` | `fn eprintln(msg: str)` | Prints error message directly to `stderr` (file descriptor 2) with a trailing newline. |

### Example: Interactive Console Dialog
```rad
fn main() {
    print("Username: ")
    let user = input()
    let pass = input("Password: ")

    if str_eq(user.as_ptr(), "admin") {
        println(f"Access granted. Welcome, {user}!")
    } else {
        eprintln("Access denied: invalid credentials")
    }
}
```

---

## 7.8 Multi-Return Functions (Tuples)

Functions can return multiple values cleanly by returning a tuple type `(T1, T2, ...)`:

```rad
// Multi-return function returning quotient and remainder
fn divmod(dividend: i64, divisor: i64) -> (i64, i64) {
    let q = dividend / divisor;
    let r = dividend % divisor;
    return (q, r);
}

// Function returning statistics: (min, max, average)
fn compute_stats(a: i64, b: i64, c: i64) -> (i64, i64, i64) {
    var min = a;
    if b < min { min = b; }
    if c < min { min = c; }

    var max = a;
    if b > max { max = b; }
    if c > max { max = c; }

    let avg = (a + b + c) / 3i64;
    return (min, max, avg);
}

fn main() {
    // Destructuring function call returns
    let (q, r) = divmod(10, 3);
    println(f"10 / 3 = {q} remainder {r}");

    // Ignoring return components with wildcard `_`
    let (min, max, _) = compute_stats(42, 10, 88);
    println(f"Range: {min} to {max}");
}
```


---

## 7.8 Multi-Return Functions & Tuples

Functions can return multiple values bundled in a lightweight tuple type `(T1, T2, ...)`:

```rad
fn divmod(a: i64, b: i64) -> (i64, i64) {
    return (a / b, a % b);
}

fn stats(x: f64) -> (f64, str) {
    return (x * 2.5, "metric");
}

fn main() -> i32 {
    let (q, r) = divmod(10, 3);
    println(f"Quotient: {q}, Remainder: {r}");

    let (score, label): (f64, str) = stats(4.0);
    println(f"Score: {score}, Label: {label}");
    return 0;
}
```

---

## 7.9 Lambdas & Closures

Rad supports concise anonymous functions (lambdas) and capturing closures:

### Syntax
- `|arg1, arg2| expr`
- `|arg1: Type, arg2: Type| -> RetType { stmts }`
- `|| expr` (zero-argument lambda)

### Non-Capturing Lambdas
Lambdas that do not capture enclosing scope variables compile directly to standard C-compatible function pointers (`fn(...) -> Ret`):

```rad
let double = |x: i64| x * 2;
let add = |a: i64, b: i64| a + b;

println(double(21)); // 42
println(add(10, 32)); // 42
```

### Capturing Closures (Fat Function Values)
Closures that capture variables from outer lexical scopes are represented as `{ fn_ptr, env_ptr }` fat pairs, allowing passing stateful callbacks cleanly to higher-order functions:

```rad
var base = 100;
let add_base = |x: i64| base + x;

println(add_base(25)); // 125
```
