# Rad Error Handling Specification

Rad avoids untyped runtime exceptions in favor of explicit, type-safe error handling using `Result<T, E>` and `Option<T>`.

## 1. The `Option<T>` Type

Represents an optional value that may or may not be present:

```rad
enum Option<T> {
    Some(T),
    None,
}
```

Usage:
```rad
fn find_index(arr: Vec<i32>, target: i32) -> Option<usize> {
    var i = 0usize;
    while i < arr.len {
        if arr.ptr[i] == target {
            return Option::Some(i);
        }
        i = i + 1usize;
    }
    return Option::None;
}
```

## 2. The `Result<T, E>` Type

Represents either a success value `Ok(T)` or an error value `Err(E)`:

```rad
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

Usage:
```rad
fn parse_port(s: str) -> Result<i32, str> {
    let port = parse_int(s);
    if port < 1 || port > 65535 {
        return Result::Err("Port out of range (1-65535)");
    }
    return Result::Ok(port as i32);
}
```

## 3. Compiler Diagnostics

When compilation fails, `radc` emits standard Rust-like diagnostic messages:
- Format: `error[E000X]: <description>`
- Source location: `  --> path/to/file.rad:line:col`
- Source excerpt:
  ```text
     |
  12 |     let x = 10;
     |               ^
  ```
- Exit code: `1` on error, `0` on clean compilation.
