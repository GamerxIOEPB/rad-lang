# Rad Ownership & Memory Model

Rad enforces memory safety without a garbage collector through explicit ownership, affine move semantics, and RAII drop scopes.

## 1. Single Ownership & Affine Moves

Every resource in Rad has a unique owner variable. Assigning or passing an owned resource transfers ownership (moves the value).

```rad
let s1 = String.from_str("hello");
let s2 = s1; // s1 is moved to s2; s1 cannot be accessed afterward
```

## 2. Mutability (`let` vs `var`)

Variables declared with `let` are immutable and cannot be rebound or mutated.
Variables declared with `var` are mutable:

```rad
let x = 10;
// x = 20; // Compile-time error: cannot mutate immutable variable 'x'

var y = 10;
y = 20; // Allowed
```

## 3. Method Receivers: `self` vs `var self`

In `impl` blocks:
- `fn method(self)`: Shared read-only receiver. Does not mutate the struct.
- `fn method(var self)`: Mutable receiver. Allows mutating fields of `self`.

```rad
impl Buffer {
    fn size(self) -> usize {
        return self.len;
    }

    fn clear(var self) {
        self.len = 0usize;
    }
}
```

## 4. RAII Drop Semantics

When an owned variable reaches the end of its enclosing scope (`}`), its destructor is invoked deterministically:
- `Vec.drop()` frees allocated backing storage via `free()`.
- `String.drop()` releases internal buffer.
- Open file handles are closed cleanly.
