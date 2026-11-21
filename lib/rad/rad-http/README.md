# rad-http

Lightweight, high-performance HTTP/1.1 client and micro-server written in **100% pure native Rad**. Zero C, zero libc, zero external dependencies — built directly on top of Linux socket system calls.

## Features
- **HTTP Client**: Clean `http_get` and `http_post` APIs with automatic URL parsing, header construction, and body transfer.
- **HTTP Response Parsing**: Instant status code extraction, case-insensitive header querying (`get_header`), and payload decoding.
- **HTTP Micro-Server**: High-performance socket server (`HttpServer::bind`) with custom route handling and formatted response dispatch.

## Installation
```bash
rad add rad-http
```

## Quick Example

```rad
import "rad-http";

fn main() -> i32 {
    let res = http_get("http://127.0.0.1:8080/api/health");
    match res {
        Option.Some(resp) => {
            println("Status: " + int_to_str(resp.status_code as i64));
            println("Body: " + resp.body);
        },
        Option.None => {
            println("Connection failed");
        }
    }
    return 0;
}
```
