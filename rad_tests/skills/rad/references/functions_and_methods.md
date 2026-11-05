# Rad Functions & Methods Specification

Functions and methods in Rad are declared with `fn`.

## 1. Top-Level Functions

```rad
// Function with parameters and return type
fn add(a: i32, b: i32) -> i32 {
    return a + b;
}

// Function with void return
fn log_message(msg: str) {
    println(msg);
}
```

## 2. Default Entry Point

```rad
// Void entry point returns 0 to the OS
fn main() {
    println("Hello");
}

// Explicit exit code entry point
fn main() -> i32 {
    return 0;
}
```

## 3. Parameter Mutability

Parameters are immutable unless prefixed with `var`:

```rad
fn increment(var counter: i32) -> i32 {
    counter = counter + 1;
    return counter;
}
```

## 4. Struct Methods (`impl` Blocks)

Methods associated with a struct are declared in an `impl <StructName>` block:

```rad
struct Rectangle {
    width: i64,
    height: i64,
}

impl Rectangle {
    // Static constructor method
    fn new(w: i64, h: i64) -> Rectangle {
        return Rectangle { width: w, height: h };
    }

    // Read-only method
    fn area(self) -> i64 {
        return self.width * self.height;
    }

    // Mutating method
    fn scale(var self, factor: i64) {
        self.width = self.width * factor;
        self.height = self.height * factor;
    }
}
```
