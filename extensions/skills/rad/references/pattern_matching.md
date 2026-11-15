# Rad Pattern Matching Specification

Rad supports exhaustive pattern matching over algebraic data types and primitive values via the `match` expression.

## 1. Syntax

```rad
match expr {
    Pattern1 => {
        // statements
    },
    Pattern2 => {
        // statements
    },
    _ => {
        // default fallback
    },
}
```

## 2. Matching Over Enums

```rad
enum Action {
    Stop,
    Move(i32, i32),
    Message(String),
}

fn handle_action(act: Action) {
    match act {
        Action::Stop => {
            println("Stopping...");
        },
        Action::Move(x, y) => {
            println("Moving to ({x}, {y})");
        },
        Action::Message(msg) => {
            println("Message received: {msg}");
        },
    }
}
```

## 3. Matching Over Integers

```rad
fn describe_code(status: i32) -> str {
    match status {
        0 => "Success",
        1 => "General Error",
        127 => "Command Not Found",
        _ => "Unknown Error",
    }
}
```
