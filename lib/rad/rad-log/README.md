# rad-log

Structured, zero-dependency logging library for the Rad programming language.

## Features
- **5 Log Levels**: TRACE, DEBUG, INFO, WARN, ERROR.
- **ANSI Terminal Colors**: Highlights tags and severity levels.
- **Custom Loggers**: Configurable min-level, tags, and formatting.
- **Convenience Functions**: `log_info`, `log_warn`, `log_error`, `log_debug`, `log_trace`.

## Usage
```rad
import rad_log

fn main() -> i32 {
    log_info("SERVER", "Listening on port 8080...")
    log_warn("CACHE", "Cache miss for key user_101")
    log_error("DATABASE", "Connection timeout")
    return 0
}
```
