# rad-toml

A pure-Rad TOML parser, DOM document tree, and serializer with zero external dependencies.

## Features
- **Data Types**: Full DOM support for Strings, Integers (decimal, hex, binary), Floats, Booleans, Arrays, Inline Tables, and Section Tables (`[section]`).
- **Query & Navigation**: Ergonomic accessor methods (`get`, `get_str`, `get_int`, `get_bool`, `get_table`, `get_array`) with dot-path lookup (`package.name`).
- **Serialization**: Formats DOM trees into clean, standard TOML strings.
- **Pure Rad**: Zero C, zero libc, zero external dependencies.

## Usage

```rad
import toml;

fn main() -> i32 {
    let content = "[package]\nname = \"my_app\"\nversion = \"0.1.0\"\n";
    let doc = TomlValue.parse(content);
    
    let name = doc.get_str("package.name");
    printf("Package: %s\n", name);
    return 0;
}
```
