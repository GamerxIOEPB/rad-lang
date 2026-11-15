# Rad Migration Guide (from C, C++, Rust, and Python)

This guide helps engineers translate idioms from common languages into Rad.

## 1. Migrating from C

| Concept | C | Rad |
|---|---|---|
| Main entry | `int main(int argc, char **argv)` | `fn main()` or `fn main(argc: i32, argv: *raw *raw u8) -> i32` |
| Printing | `printf("Val: %d\n", x);` | `println("Val: {x}");` or `printf("Val: %d\n", x);` |
| Variable | `int x = 10;` | `let x = 10;` (immutable) or `var x = 10;` (mutable) |
| Dynamic array | `int *arr = malloc(n * sizeof(int));` | `var arr = Vec.new(); arr.push(10);` |
| Strings | `char *str = "hello";` | `let s = "hello";` (`str`) or `let s = String.from_str("hello");` |

## 2. Migrating from Rust

| Concept | Rust | Rad |
|---|---|---|
| Mutability | `let mut x = 10;` | `var x = 10;` |
| Immutability | `let x = 10;` | `let x = 10;` |
| Printing | `println!("Val: {}", x);` | `println("Val: {x}");` |
| Struct | `struct Point { x: i32, y: i32 }` | `struct Point { x: i32, y: i32 }` |
| Methods | `impl Point { fn new(...) -> Self }` | `impl Point { fn new(...) -> Point }` |
| Receiver | `&self`, `&mut self` | `self`, `var self` |

## 3. Migrating from Python

| Concept | Python | Rad |
|---|---|---|
| Printing with f-strings | `print(f"Val: {x}")` | `println("Val: {x}");` |
| Function definition | `def compute(x: int) -> int:` | `fn compute(x: i32) -> i32 { ... }` |
| Loops | `while condition:` | `while condition { ... }` |
| Lists | `items = [] ; items.append(1)` | `var items = Vec.new(); items.push(1);` |
| Dictionaries | `d = {} ; d["k"] = 1` | `var d = HashMap.new(); d.insert("k", 1);` |
