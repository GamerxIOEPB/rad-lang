# rad-test

Ergonomic unit testing harness with assertions and colored reporting in pure Rad.

## Features

- **Assertion API**: `assert_true`, `assert_false`, `assert_eq_i64`, `assert_ne_i64`, `assert_eq_str`, `assert_ne_str`.
- **TestSuite Runner**: Track total, passed, and failed test cases with formatted terminal output.
- **Colored Terminal Diagnostics**: Green `[PASS]` and red `[FAIL]` indicators with error details.
- **Zero Libc / Zero Dependencies**: Written 100% in native Rad.

## Quick Start

```rad
import "rad-test";

fn main() -> i32 {
    var suite = TestSuite.new("MathSuite");

    suite.check("Addition works", 2 + 2 == 4, "2 + 2 must equal 4");
    suite.check_true("Comparison", 10 > 5);
    suite.check_eq_i64("Values match", 42i64, 42i64);

    return suite.print_summary();
}
```
