# rad-kv

Lightweight, persistent, append-only Key-Value store for the Rad programming language.

## Architecture
- **Bitcask Log Design**: Writes are strictly sequential append-only operations, maximizing NVMe and SSD throughput.
- **In-Memory Keydir Index**: Lookups query an in-memory index pointing to exact file offsets, achieving constant-time $O(1)$ random reads with a single disk seek.
- **Crash Resilience**: Atomic writes with checksum headers and tombstone records ensure durability across unexpected crashes.

## Usage
```rad
import rad_kv

fn main() -> i32 {
    var db = KvStore.open("app_data.kv")
    db.set("user:101", "{\"name\": \"Alice\", \"role\": \"admin\"}")
    
    let user = db.get("user:101")
    match user {
        Option.Some(val) => printf("User found: %s\n", val.as_ptr() as str),
        _ => printf("User not found\n")
    }

    db.delete("user:101")
    db.close()
    return 0
}
```
