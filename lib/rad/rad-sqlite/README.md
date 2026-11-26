# rad-sqlite

High-performance, idiomatic SQLite3 C FFI bindings for the Rad programming language.

## Features
- **In-Memory & On-Disk Databases**: Support for `:memory:` as well as file-backed SQLite databases.
- **Prepared Statements**: Safe execution, column inspection, and typed data extraction (`column_text`, `column_i64`, `column_f64`).
- **Direct Queries**: Quick single-value and scalar queries (`query_value`).

## Usage
```rad
import rad_sqlite

fn main() -> i32 {
    let db_opt = SqliteDb.open_memory()
    match db_opt {
        Option.Some(var db) => {
            db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT);")
            db.execute("INSERT INTO users (name) VALUES ('Alice');")
            
            let val = db.query_value("SELECT name FROM users WHERE id = 1;")
            match val {
                Option.Some(name) => printf("User: %s\n", name.as_ptr() as str),
                _ => printf("User not found\n")
            }
            db.close()
        },
        _ => printf("Failed to open database\n")
    }
    return 0
}
```
Compile with:
```bash
radc main.rad -lsqlite3 -o main
```
