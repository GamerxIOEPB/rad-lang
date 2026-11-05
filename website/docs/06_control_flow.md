# Chapter 6: Control Flow

## 6.1 Conditional Branching (`if`, `else if`, `else`)

Rad uses `if` expressions to execute blocks of code based on a Boolean condition:

```rad
fn main() -> i32 {
    let temperature: i64 = 28

    if temperature > 35 {
        println("Heat warning!")
    } else if temperature > 20 {
        println("Pleasant warm weather.")
    } else if temperature > 10 {
        println("Cool weather.")
    } else {
        println("Cold weather alert!")
    }

    return 0
}
```

### Key Rules:
- The condition expression must evaluate to a `bool`.
- Parentheses around the condition are optional (`if x > 0` vs `if (x > 0)`).
- The curly braces `{ ... }` around the then-block and else-block are **mandatory**, eliminating classic C "dangling else" vulnerabilities.

---

## 6.2 While Loops (`while`)

Rad provides the `while` loop for repeated execution while a Boolean condition remains `true`:

```rad
fn main() -> i32 {
    var counter: i64 = 0

    while counter < 5 {
        println("Iteration: {counter}")
        counter = counter + 1
    }

    println("Loop completed.")
    return 0
}
```

Output:
```text
Iteration: 0
Iteration: 1
Iteration: 2
Iteration: 3
Iteration: 4
Loop completed.
```

---

## 6.3 Loop Control (`break` & `continue`)

### The `break` Statement
`break` immediately exits the enclosing loop:

```rad
fn main() -> i32 {
    var i: i64 = 0

    while true {
        if i >= 4 {
            break // Exits the loop when i reaches 4
        }
        println("i = {i}")
        i = i + 1
    }

    println("Broke out of loop.")
    return 0
}
```

### The `continue` Statement
`continue` skips the remainder of the current loop iteration and proceeds immediately to the next condition evaluation:

```rad
fn main() -> i32 {
    var i: i64 = 0

    while i < 10 {
        i = i + 1
        if i % 2 == 0 {
            continue // Skip even numbers
        }
        println("Odd number: {i}")
    }

    return 0
}
```

Output:
```text
Odd number: 1
Odd number: 3
Odd number: 5
Odd number: 7
Odd number: 9
```

---

## 6.4 Infinite Loops

You can write infinite service loops or polling loops using `while true`:

```rad
fn poll_events() {
    var running: bool = true
    while running {
        // Poll event queue
        let should_exit = check_exit_signal()
        if should_exit {
            running = false
            break
        }
    }
}
```
