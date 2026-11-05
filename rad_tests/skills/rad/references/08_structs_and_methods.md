# Chapter 8: Structs, Fields & Methods

## 8.1 Defining Structs

Structs in Rad allow you to group related fields into a custom compound data type:

```rad
struct Point {
    x: i64,
    y: i64,
}

struct Player {
    id: i64,
    health: i32,
    score: i64,
}
```

Each field declaration consists of `field_name: Type`, separated by commas.

---

## 8.2 Instantiation & Field Initialization

Create an instance of a struct using struct literal syntax (`StructName { field: value, ... }`):

```rad
fn main() -> i32 {
    let p = Point {
        x: 10,
        y: 20,
    }

    println("Point: x={}, y={}", p.x, p.y)
    return 0
}
```

---

## 8.3 Accessing and Mutating Fields

### Accessing Fields
Access struct fields using the dot operator (`.`):

```rad
let px = p.x
let py = p.y
```

### Mutating Fields
If a struct variable is declared with `var`, its fields can be reassigned:

```rad
fn main() -> i32 {
    var p = Point { x: 5, y: 12 }
    println("Initial: x={}, y={}", p.x, p.y)

    p.x = 100
    p.y = 200
    println("Updated: x={}, y={}", p.x, p.y)
    return 0
}
```

---

## 8.4 Methods on Structs (`self` Receiver)

In Rad, methods are functions that take an explicit `self` pointer receiver as their first parameter:

```rad
struct Rectangle {
    width: i64,
    height: i64,
}

// Method calculating the area of a Rectangle
fn area(self: *raw Rectangle) -> i64 {
    return self.width * self.height
}

// Method calculating the perimeter of a Rectangle
fn perimeter(self: *raw Rectangle) -> i64 {
    return 2 * (self.width + self.height)
}
```

### Invoking Methods with Dot Syntax
Once a function is defined with a `(self: *raw StructName)` receiver, it can be called directly on an instance using dot notation:

```rad
fn main() -> i32 {
    let rect = Rectangle { width: 10, height: 5 }

    // Calling methods via dot notation:
    let a = rect.area()
    let p = rect.perimeter()

    println("Area: {}, Perimeter: {}", a, p)
    return 0
}
```

Output:
```text
Area: 50, Perimeter: 30
```

### Methods That Mutate Fields
To mutate the struct inside a method, declare `self` as a mutable raw pointer (`self: *raw var StructName`):

```rad
fn scale(self: *raw var Rectangle, factor: i64) {
    self.width = self.width * factor
    self.height = self.height * factor
}

fn main() -> i32 {
    var rect = Rectangle { width: 4, height: 6 }
    rect.scale(3)
    println("Scaled rectangle: width={}, height={}", rect.width, rect.height)
    return 0
}
```

---

## 8.5 Constructor Functions

By convention, constructor helper functions are written as factory functions returning a new struct instance:

```rad
fn make_point(x: i64, y: i64) -> Point {
    return Point { x: x, y: y }
}

fn main() -> i32 {
    let pt = make_point(30, 40)
    println("pt = ({}, {})", pt.x, pt.y)
    return 0
}
```

> [!NOTE]
> Do not name user functions simply `new()`, as `@new` is reserved internally by `radc`'s code generator for built-in heap allocations of strings and dynamic vectors. Use descriptive names like `make_point()`, `Point_create()`, or `init()`.
