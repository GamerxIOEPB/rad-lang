# rad-args

Ergonomic, declarative command-line argument parsing library in **100% pure native Rad**. Zero external dependencies.

## Features
- **Flags**: Boolean command-line toggles (`-v`, `--verbose`).
- **Options**: Parameterized values with defaults (`-o <file>`, `--target <arch>`).
- **Subcommands**: First-class command routing (`build`, `run`, `install`).
- **Positional Arguments**: Safe indexed access to trailing positional args.
- **Auto-Generated Help**: Formatted `--help` and `-h` banner with aligned descriptions.

## Installation
```bash
rad add rad-args
```

## Quick Example
```rad
import "rad-args";

fn main(argc: i32, argv: *raw *raw u8) -> i32 {
    var p = ArgParser.new("my_tool", "High-performance data processor");
    p.add_flag("v", "verbose", "Enable verbose diagnostic logs");
    p.add_opt("o", "output", "Destination file path", "out.bin");
    p.add_subcommand("build", "Compile target artifacts");

    p.parse(argc, argv);

    if p.get_flag("help") {
        p.print_help();
        return 0;
    }

    if p.get_flag("verbose") {
        println("Verbose logging enabled!");
    }

    let out = p.get_opt("output");
    // ...
    return 0;
}
```
