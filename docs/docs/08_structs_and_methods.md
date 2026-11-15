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
    active: bool,
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

    print("Point x: ")
    println(p.x)
    print("Point y: ")
    println(p.y)
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
If a struct variable is declared with `var`, its fields can be mutated directly:

```rad
fn main() -> i32 {
    var p = Point { x: 5, y: 12 }
    p.x = 100
    p.y = 200

    print("Updated x: ")
    println(p.x)
    print("Updated y: ")
    println(p.y)
    return 0
}
```

---

## 8.4 Implementation Blocks (`impl`) & Methods

Methods in Rad are organized inside `impl` blocks associated with the struct:

```rad
struct Rectangle {
    width: i64,
    height: i64,
}

impl Rectangle {
    // Factory constructor function
    fn create(w: i64, h: i64) -> Rectangle {
        return Rectangle { width: w, height: h }
    }

    // Read-only method (immutable self)
    fn area(self) -> i64 {
        return self.width * self.height
    }

    fn perimeter(self) -> i64 {
        return 2 * (self.width + self.height)
    }

    // Mutating method (declared with 'var self')
    fn scale(var self, factor: i64) {
        self.width = self.width * factor
        self.height = self.height * factor
    }
}
```

### Invoking Methods with Dot Notation

Once declared inside the `impl` block, methods can be invoked cleanly using dot syntax:

```rad
fn main() -> i32 {
    var rect = Rectangle::create(10, 5)

    let a = rect.area()
    let p = rect.perimeter()

    print("Area: ")
    println(a)
    print("Perimeter: ")
    println(p)

    // Mutate via method call
    rect.scale(2)
    print("Scaled Area: ")
    println(rect.area())
    return 0
}
```

Output:
```text
Area: 50
Perimeter: 30
Scaled Area: 200
```

---

## 8.5 Mutating Methods with `var self`

When a method modifies the receiver's fields, declare the first parameter as `var self`:

```rad
struct Counter {
    value: i32,
}

impl Counter {
    fn create() -> Counter {
        return Counter { value: 0 }
    }

    fn increment(var self) {
        self.value = self.value + 1
    }

    fn add(var self, amount: i32) {
        self.value = self.value + amount
    }

    fn get(self) -> i32 {
        return self.value
    }
}

fn main() -> i32 {
    var c = Counter::create()
    c.increment()
    c.add(10)
    print("Counter value: ")
    println(c.get())
    return 0
}
```
