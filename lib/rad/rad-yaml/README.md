# rad-yaml

Pure-Rad YAML parser, DOM document tree, and serializer with zero external dependencies.

## Features
- **Zero External Dependencies**: 100% pure Rad code.
- **Full YAML Types**: Null, Booleans, Integers, Floats, Strings (quoted/unquoted), Sequences (lists), and Mappings (dictionaries).
- **Nested Block Parsing**: Indentation-based hierarchical document model.
- **Dot-Path Querying**: Effortlessly query nested values with `doc.get_str("server.host")`.
- **Serialization**: Format native DOM data back into clean, 2-space indented YAML.

## Usage

```rad
import yaml;

let content = "
name: rad-server
version: 1
settings:
  port: 8080
  debug: true
";

let res = YamlValue.parse(content);
match res {
    Result.Ok(doc) => {
        let name = doc.get_str("name");
        let port = doc.get_int("settings.port");
        let is_debug = doc.get_bool("settings.debug");
    },
    Result.Err(e) => {
        println("Parse error: " + e);
    }
}
```
