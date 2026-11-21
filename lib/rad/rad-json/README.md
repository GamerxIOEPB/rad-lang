# rad-json

Pure native Rad JSON DOM, recursive-descent parser, and serialization library. Zero external dependencies.

## Installation

Add to your project's `rad.toml`:

```toml
[dependencies]
rad-json = "^0.1.0"
```

Or install via `rad`:

```bash
rad add rad-json
```

## Quick Example

```rad
import json;

fn main() -> i32 {
    let json_text = "{\"name\": \"rad\", \"version\": \"0.2.4\", \"active\": true}";
    let parsed = JsonParser.parse(json_text);

    let val = parsed.get("version");
    println(val.as_str()); // "0.2.4"
    0
}
```

## License

MIT © 2026 GamerxIOEPB
