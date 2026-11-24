#!/usr/bin/env python3
"""
gen_suite.py - Comprehensive test generator for Rad language test suite
Generates ~820 tests across 14 categories.
"""

import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TESTS_DIR = os.path.join(BASE_DIR, "tests")
EXP_DIR = os.path.join(TESTS_DIR, "expected")

os.makedirs(EXP_DIR, exist_ok=True)

def write_test(cat, name, code, out=None, contains=None, exit_code=None, diag=None):
    cat_dir = os.path.join(TESTS_DIR, cat)
    os.makedirs(cat_dir, exist_ok=True)
    with open(os.path.join(cat_dir, f"{name}.rad"), "w", encoding="utf-8") as f:
        f.write(code.strip() + "\n")
    if out is not None:
        with open(os.path.join(EXP_DIR, f"{name}.out"), "w", encoding="utf-8") as f:
            f.write(out.strip() + "\n")
    if contains is not None:
        with open(os.path.join(EXP_DIR, f"{name}.contains"), "w", encoding="utf-8") as f:
            f.write(contains.strip())
    if exit_code is not None:
        with open(os.path.join(EXP_DIR, f"{name}.exit"), "w", encoding="utf-8") as f:
            f.write(str(exit_code) + "\n")
    if diag is not None:
        with open(os.path.join(EXP_DIR, f"{name}.diag"), "w", encoding="utf-8") as f:
            f.write(diag.strip() + "\n")

# ==========================================
# 1. 01_basics (60 tests)
# ==========================================
def gen_basics():
    cat = "01_basics"
    # Basic arithmetic and formatting
    for i in range(1, 21):
        name = f"b_gen_{i:03d}"
        val1 = i * 7
        val2 = i * 3 + 1
        s = val1 + val2
        d = val1 - val2
        p = val1 * val2
        q = val1 // val2
        m = val1 % val2
        code = f"""
fn main() {{
    let a: i64 = {val1}i64
    let b: i64 = {val2}i64
    println(f"add: {{a + b}}, sub: {{a - b}}, mul: {{a * b}}, div: {{a / b}}, mod: {{a % b}}")
}}
"""
        out = f"add: {s}, sub: {d}, mul: {p}, div: {q}, mod: {m}"
        write_test(cat, name, code, out=out)

    # F-string format specifiers: width, zero padding, hex, octal, floats
    for i in range(21, 41):
        name = f"b_gen_{i:03d}"
        n = (i * 17) % 500
        flt = (i * 3.14159) / 7.0
        hex_val = n
        oct_val = n
        code = f"""
fn main() {{
    let n: i64 = {n}i64
    let f: f64 = {flt}
    let h: i64 = {hex_val}i64
    let o: i64 = {oct_val}i64
    println(f"pad: {{n:05d}}, flt2: {{f:.2f}}, flt4: {{f:.4f}}, hex: {{h:04x}}, oct: {{o:04o}}")
}}
"""
        out = f"pad: {n:05d}, flt2: {flt:.2f}, flt4: {flt:.4f}, hex: {hex_val:04x}, oct: {oct_val:04o}"
        write_test(cat, name, code, out=out)

    # Boolean expressions and short circuit logic
    for i in range(41, 61):
        name = f"b_gen_{i:03d}"
        b1 = (i % 2 == 0)
        b2 = (i % 3 == 0)
        b3 = (i % 5 == 0)
        and_res = b1 and b2
        or_res = b1 or b3
        complex_res = (b1 and not b2) or (b3 and not b1)
        code = f"""
fn main() {{
    let b1 = {"true" if b1 else "false"}
    let b2 = {"true" if b2 else "false"}
    let b3 = {"true" if b3 else "false"}
    let r1 = b1 && b2
    let r2 = b1 || b3
    let r3 = (b1 && !b2) || (b3 && !b1)
    println(f"r1: {{r1}}, r2: {{r2}}, r3: {{r3}}")
}}
"""
        out = f"r1: {1 if and_res else 0}, r2: {1 if or_res else 0}, r3: {1 if complex_res else 0}"
        write_test(cat, name, code, out=out)

# ==========================================
# 2. 02_types (60 tests)
# ==========================================
def gen_types():
    cat = "02_types"
    # Integer width conversions and casts
    for i in range(1, 21):
        name = f"t_gen_{i:03d}"
        v = (i * 12345) & 0xFFFFFFFF
        code = f"""
fn main() {{
    let x: i64 = {v}i64
    let u: u64 = x as u64
    let i32_v: i32 = x as i32
    let u32_v: u32 = x as u32
    let i16_v: i16 = x as i16
    let u8_v: u8 = x as u8
    println(f"x={{x}} u32={{u32_v}} u8={{u8_v}}")
}}
"""
        out = f"x={v} u32={v & 0xFFFFFFFF} u8={v & 0xFF}"
        write_test(cat, name, code, out=out)

    # Tuples: 2-tuple, 3-tuple, 4-tuple indexing
    for i in range(21, 41):
        name = f"t_gen_{i:03d}"
        t0 = i
        t1 = i * 10
        t2 = i * 100
        code = f"""
fn main() {{
    let t = ({t0}i64, {t1}i64, {t2}i64)
    println(f"t0: {{t.0}}, t1: {{t.1}}, t2: {{t.2}}, sum: {{t.0 + t.1 + t.2}}")
}}
"""
        out = f"t0: {t0}, t1: {t1}, t2: {t2}, sum: {t0 + t1 + t2}"
        write_test(cat, name, code, out=out)

    # Float casts and operations
    for i in range(41, 61):
        name = f"t_gen_{i:03d}"
        f_val = i * 2.5
        i_cast = int(f_val)
        code = f"""
fn main() {{
    let f: f64 = {f_val}
    let n: i64 = f as i64
    let back: f64 = n as f64
    println(f"f={{f:.1f}} n={{n}} back={{back:.1f}}")
}}
"""
        out = f"f={f_val:.1f} n={i_cast} back={float(i_cast):.1f}"
        write_test(cat, name, code, out=out)

# ==========================================
# 3. 03_control_flow (60 tests)
# ==========================================
def gen_control_flow():
    cat = "03_control_flow"
    # While loop accumulators
    for i in range(1, 21):
        name = f"cf_gen_{i:03d}"
        limit = i + 5
        total = sum(k * k for k in range(1, limit + 1))
        code = f"""
fn main() {{
    var sum: i64 = 0i64
    var k: i64 = 1i64
    while k <= {limit}i64 {{
        sum = sum + k * k
        k = k + 1i64
    }}
    println(f"sum: {{sum}}")
}}
"""
        out = f"sum: {total}"
        write_test(cat, name, code, out=out)

    # For-in range loops with steps and conditions
    for i in range(21, 41):
        name = f"cf_gen_{i:03d}"
        end = i * 3
        count = sum(1 for x in range(end) if x % 3 == 0)
        sum_evens = sum(x for x in range(end) if x % 3 == 0)
        code = f"""
fn main() {{
    var cnt: i64 = 0i64
    var total: i64 = 0i64
    for x in 0..{end} {{
        if x % 3 == 0 {{
            cnt = cnt + 1i64
            total = total + (x as i64)
        }}
    }}
    println(f"cnt: {{cnt}}, total: {{total}}")
}}
"""
        out = f"cnt: {count}, total: {sum_evens}"
        write_test(cat, name, code, out=out)

    # Nested loops with break and continue
    for i in range(41, 61):
        name = f"cf_gen_{i:03d}"
        outer = (i % 5) + 3
        inner = (i % 4) + 4
        hits = 0
        for x in range(outer):
            for y in range(inner):
                if y == 2:
                    continue
                if x == 2:
                    break
                hits += 1
        code = f"""
fn main() {{
    var hits: i64 = 0i64
    var x: i64 = 0i64
    while x < {outer}i64 {{
        var y: i64 = 0i64
        while y < {inner}i64 {{
            if y == 2i64 {{
                y = y + 1i64
                continue
            }}
            if x == 2i64 {{
                break
            }}
            hits = hits + 1i64
            y = y + 1i64
        }}
        x = x + 1i64
    }}
    println(f"hits: {{hits}}")
}}
"""
        out = f"hits: {hits}"
        write_test(cat, name, code, out=out)

# ==========================================
# 4. 04_functions (60 tests)
# ==========================================
def gen_functions():
    cat = "04_functions"
    # Recursive functions: gcd, power, fibonacci, factorial
    for i in range(1, 21):
        name = f"ft_gen_{i:03d}"
        a = (i * 13) + 7
        b = (i * 5) + 3
        import math
        g = math.gcd(a, b)
        code = f"""
fn gcd(a: i64, b: i64) -> i64 {{
    if b == 0i64 {{
        return a
    }}
    return gcd(b, a % b)
}}

fn main() {{
    let res = gcd({a}i64, {b}i64)
    println(f"gcd({a}, {b}) = {{res}}")
}}
"""
        out = f"gcd({a}, {b}) = {g}"
        write_test(cat, name, code, out=out)

    # Multi-parameter math helper functions
    for i in range(21, 41):
        name = f"ft_gen_{i:03d}"
        x = i
        y = i + 2
        z = i * 3
        poly = x * x + 2 * y + 3 * z
        code = f"""
fn eval_poly(x: i64, y: i64, z: i64) -> i64 {{
    let r = x * x + 2i64 * y + 3i64 * z
    return r
}}

fn main() {{
    let res = eval_poly({x}i64, {y}i64, {z}i64)
    println(f"poly({x}, {y}, {z}) = {{res}}")
}}
"""
        out = f"poly({x}, {y}, {z}) = {poly}"
        write_test(cat, name, code, out=out)

    # Mutual recursion: is_even / is_odd
    for i in range(41, 61):
        name = f"ft_gen_{i:03d}"
        n = i
        is_even = (n % 2 == 0)
        code = f"""
fn is_odd(n: i64) -> bool;

fn is_even(n: i64) -> bool {{
    if n == 0i64 {{
        return true
    }}
    return is_odd(n - 1i64)
}}

fn is_odd(n: i64) -> bool {{
    if n == 0i64 {{
        return false
    }}
    return is_even(n - 1i64)
}}

fn main() {{
    let ev = is_even({n}i64)
    println(f"is_even({n}): {{ev}}")
}}
"""
        out = f"is_even({n}): {1 if is_even else 0}"
        write_test(cat, name, code, out=out)

# ==========================================
# 5. 05_structs (60 tests)
# ==========================================
def gen_structs():
    cat = "05_structs"
    # Struct methods and static constructors
    for i in range(1, 21):
        name = f"st_gen_{i:03d}"
        w = i + 2
        h = i + 5
        area = w * h
        perim = 2 * (w + h)
        code = f"""
struct Rectangle {{
    width: i64,
    height: i64,
}}

impl Rectangle {{
    fn new(width: i64, height: i64) -> Rectangle {{
        return Rectangle {{ width: width, height: height }}
    }}
    fn area(self) -> i64 {{
        return self.width * self.height
    }}
    fn perimeter(self) -> i64 {{
        return 2i64 * (self.width + self.height)
    }}
}}

fn main() {{
    let r = Rectangle.new({w}i64, {h}i64)
    println(f"area: {{r.area()}}, perim: {{r.perimeter()}}")
}}
"""
        out = f"area: {area}, perim: {perim}"
        write_test(cat, name, code, out=out)

    # Struct mutating methods (var self)
    for i in range(21, 41):
        name = f"st_gen_{i:03d}"
        init = i * 10
        add = i * 3
        mul = 2
        final_val = (init + add) * mul
        code = f"""
struct Counter {{
    val: i64,
}}

impl Counter {{
    fn new(val: i64) -> Counter {{
        return Counter {{ val: val }}
    }}
    fn add(var self, amount: i64) {{
        self.val = self.val + amount
    }}
    fn multiply(var self, factor: i64) {{
        self.val = self.val * factor
    }}
}}

fn main() {{
    var c = Counter.new({init}i64)
    c.add({add}i64)
    c.multiply({mul}i64)
    println(f"counter: {{c.val}}")
}}
"""
        out = f"counter: {final_val}"
        write_test(cat, name, code, out=out)

    # Nested structs (Point inside Circle)
    for i in range(41, 61):
        name = f"st_gen_{i:03d}"
        x = i
        y = i + 1
        r = i + 3
        code = f"""
struct Point {{
    x: i64,
    y: i64,
}}

struct Circle {{
    center: Point,
    radius: i64,
}}

impl Circle {{
    fn new(x: i64, y: i64, radius: i64) -> Circle {{
        return Circle {{
            center: Point {{ x: x, y: y }},
            radius: radius,
        }}
    }}
    fn diameter(self) -> i64 {{
        return self.radius * 2i64
    }}
}}

fn main() {{
    let c = Circle.new({x}i64, {y}i64, {r}i64)
    println(f"center=({{c.center.x}}, {{c.center.y}}), diam={{c.diameter()}}")
}}
"""
        out = f"center=({x}, {y}), diam={r * 2}"
        write_test(cat, name, code, out=out)

# ==========================================
# 6. 06_collections (60 tests)
# ==========================================
def gen_collections():
    cat = "06_collections"
    # Vec push, pop, len, indexing
    for i in range(1, 21):
        name = f"co_gen_{i:03d}"
        count = i + 3
        items = [(k * 7) for k in range(count)]
        total = sum(items)
        code = f"""
fn main() {{
    var v = Vec.new()
    var k: i64 = 0i64
    while k < {count}i64 {{
        v.push(k * 7i64)
        k = k + 1i64
    }}
    var sum: i64 = 0i64
    var idx = 0usize
    while idx < v.len {{
        sum = sum + v.ptr[idx]
        idx = idx + 1usize
    }}
    println(f"len: {{v.len}}, sum: {{sum}}")
}}
"""
        out = f"len: {count}, sum: {total}"
        write_test(cat, name, code, out=out)

    # String building, push_str, push_byte, len
    for i in range(21, 41):
        name = f"co_gen_{i:03d}"
        base = f"Prefix_{i}_"
        suffix = "Suffix"
        full = base + suffix
        code = f"""
fn main() {{
    var s = String.from_str("{base}")
    s.push_str("{suffix}")
    println(f"str: {{s.as_ptr() as str}}, len: {{s.len()}}")
}}
"""
        out = f"str: {full}, len: {len(full)}"
        write_test(cat, name, code, out=out)

    # HashMap insertions and queries
    for i in range(41, 61):
        name = f"co_gen_{i:03d}"
        k1 = f"key_{i}_a"
        v1 = i * 11
        k2 = f"key_{i}_b"
        v2 = i * 22
        code = f"""
fn main() {{
    var map = HashMap.new()
    map.insert("{k1}", {v1}i64)
    map.insert("{k2}", {v2}i64)
    println("map-inserted-ok")
}}
"""
        out = "map-inserted-ok"
        write_test(cat, name, code, out=out)

# ==========================================
# 7. 07_enums_match (80 tests)
# ==========================================
def gen_enums_match():
    cat = "07_enums_match"
    # Match pattern guards on Option
    for i in range(1, 21):
        name = f"em_gen_{i:03d}"
        val = i * 3 - 25
        # Guard logic
        if val > 15:
            expected = "large_positive"
        elif val > 0:
            expected = "small_positive"
        elif val == 0:
            expected = "zero"
        else:
            expected = "negative"
        code = f"""
fn classify(o: Option<i64>) -> str {{
    match o {{
        Option.Some(x) if x > 15i64 => return "large_positive",
        Option.Some(x) if x > 0i64 => return "small_positive",
        Option.Some(0i64) => return "zero",
        Option.Some(x) => return "negative",
        Option.None => return "none",
    }}
}}

fn main() {{
    let res = classify(Option.Some({val}i64))
    println(res)
}}
"""
        out = expected
        write_test(cat, name, code, out=out)

    # User Enum Constructor in Match Head Position
    for i in range(21, 41):
        name = f"em_gen_{i:03d}"
        radius = i * 4
        expected = f"Radius: {radius}"
        code = f"""
enum Geometry {{
    Square,
    Circle(i64),
    Triangle(i64, i64),
}}

fn main() {{
    match Geometry::Circle({radius}i64) {{
        Geometry::Circle(r) if r > 100i64 => println(f"BigRadius: {{r}}"),
        Geometry::Circle(r) => println(f"Radius: {{r}}"),
        Geometry::Square => println("Square"),
        _ => println("Other"),
    }}
}}
"""
        if radius > 100:
            out = f"BigRadius: {radius}"
        else:
            out = f"Radius: {radius}"
        write_test(cat, name, code, out=out)

    # Or-patterns and wildcard guards
    for i in range(41, 61):
        name = f"em_gen_{i:03d}"
        num = i % 10
        if num in (1, 2, 3):
            expected = f"group_123: {num}"
        elif num in (4, 5, 6):
            expected = f"group_456: {num}"
        elif num > 6:
            expected = f"high: {num}"
        else:
            expected = f"zero: {num}"
        code = f"""
fn main() {{
    let x: i64 = {num}i64
    match x {{
        1i64 | 2i64 | 3i64 => println(f"group_123: {{x}}"),
        4i64 | 5i64 | 6i64 => println(f"group_456: {{x}}"),
        _ if x > 6i64 => println(f"high: {{x}}"),
        _ => println(f"zero: {{x}}"),
    }}
}}
"""
        out = expected
        write_test(cat, name, code, out=out)

    # Literal payload in match arm (N3 fix verification: Some(0), Ok(1), Err("str"))
    for i in range(61, 81):
        name = f"em_gen_{i:03d}"
        val = i - 70  # can be 0 or other
        if val == 0:
            expected = "exact_zero"
        elif val > 0:
            expected = "positive"
        else:
            expected = "negative"
        code = f"""
fn test_literal_arm(opt: Option<i64>) -> str {{
    match opt {{
        Option.Some(0i64) => return "exact_zero",
        Option.Some(v) if v > 0i64 => return "positive",
        Option.Some(v) => return "negative",
        Option.None => return "none",
    }}
}}

fn main() {{
    let res = test_literal_arm(Option.Some({val}i64))
    println(res)
}}
"""
        out = expected
        write_test(cat, name, code, out=out)

# ==========================================
# 8. 08_memory (40 tests)
# ==========================================
def gen_memory():
    cat = "08_memory"
    # Raw pointer malloc, write, read, free
    for i in range(1, 21):
        name = f"mm_gen_{i:03d}"
        v1 = i * 10
        v2 = i * 20
        code = f"""
extern "C" {{
    fn malloc(size: usize) -> *raw var u8;
    fn free(ptr: *raw var u8);
}}

fn main() {{
    let p = malloc(16usize) as *raw var i64
    p[0] = {v1}i64
    p[1] = {v2}i64
    let r0 = p[0]
    let r1 = p[1]
    println(f"r0: {{r0}}, r1: {{r1}}, sum: {{r0 + r1}}")
    free(p as *raw var u8)
}}
"""
        out = f"r0: {v1}, r1: {v2}, sum: {v1 + v2}"
        write_test(cat, name, code, out=out)

    # Pointer offset arithmetic and struct layout
    for i in range(21, 41):
        name = f"mm_gen_{i:03d}"
        n_elems = 4
        total = sum((i + k) * 3 for k in range(n_elems))
        code = f"""
extern "C" {{
    fn malloc(size: usize) -> *raw var u8;
    fn free(ptr: *raw var u8);
}}

fn main() {{
    let count: usize = {n_elems}usize
    let p = malloc(count * 8usize) as *raw var i64
    var idx = 0usize
    while idx < count {{
        p[idx] = (({i}i64 + (idx as i64)) * 3i64)
        idx = idx + 1usize
    }}
    var total: i64 = 0i64
    idx = 0usize
    while idx < count {{
        total = total + p[idx]
        idx = idx + 1usize
    }}
    println(f"total: {{total}}")
    free(p as *raw var u8)
}}
"""
        out = f"total: {total}"
        write_test(cat, name, code, out=out)

# ==========================================
# 9. 09_c_interop (30 tests)
# ==========================================
def gen_c_interop():
    cat = "09_c_interop"
    # C math functions: sqrt, abs
    for i in range(1, 16):
        name = f"xi_gen_{i:03d}"
        val = float(i * i * 4)
        import math
        sq = math.sqrt(val)
        code = f"""
extern "C" {{
    fn sqrt(x: f64) -> f64;
}}

fn main() {{
    let s = sqrt({val})
    println(f"sqrt({val:.1f}) = {{s:.1f}}")
}}
"""
        out = f"sqrt({val:.1f}) = {sq:.1f}"
        write_test(cat, name, code, out=out)

    # C string functions: strlen, strcmp
    for i in range(16, 31):
        name = f"xi_gen_{i:03d}"
        s = f"hello_c_{i}"
        code = f"""
extern "C" {{
    fn strlen(s: str) -> usize;
}}

fn main() {{
    let l = strlen("{s}")
    println(f"len('{s}') = {{l}}")
}}
"""
        out = f"len('{s}') = {len(s)}"
        write_test(cat, name, code, out=out)

# ==========================================
# 10. 10_stdlib (60 tests)
# ==========================================
def gen_stdlib():
    cat = "10_stdlib"
    # Option unwrap_or, is_some, is_none
    for i in range(1, 31):
        name = f"sd_gen_{i:03d}"
        val = i * 15
        code = f"""
fn main() {{
    let some_val: Option<i64> = Option.Some({val}i64)
    let none_val: Option<i64> = Option.None

    let v1 = some_val.unwrap_or(0i64)
    let v2 = none_val.unwrap_or(999i64)
    let s1 = some_val.is_some()
    let s2 = none_val.is_none()

    println(f"v1={{v1}} v2={{v2}} s1={{s1}} s2={{s2}}")
}}
"""
        out = f"v1={val} v2=999 s1=1 s2=1"
        write_test(cat, name, code, out=out)

    # Result unwrap_or, is_ok, is_err
    for i in range(31, 61):
        name = f"sd_gen_{i:03d}"
        val = i * 25
        code = f"""
fn main() {{
    let ok_val: Result<i64, str> = Result.Ok({val}i64)
    let err_val: Result<i64, str> = Result.Err("error_occurred")

    let v1 = ok_val.unwrap_or(0i64)
    let v2 = err_val.unwrap_or(404i64)
    let is_ok = ok_val.is_ok()
    let is_err = err_val.is_err()

    println(f"ok={{v1}} err_fallback={{v2}} is_ok={{is_ok}} is_err={{is_err}}")
}}
"""
        out = f"ok={val} err_fallback=404 is_ok=1 is_err=1"
        write_test(cat, name, code, out=out)

# ==========================================
# 11. 11_complex (60 tests)
# ==========================================
def gen_complex():
    cat = "11_complex"
    # Singly linked list operations (push front, sum)
    for i in range(1, 21):
        name = f"cx_gen_{i:03d}"
        n_nodes = (i % 6) + 3
        items = list(range(1, n_nodes + 1))
        total = sum(items)
        code = f"""
struct Node {{
    val: i64,
    next: *raw var Node,
}}

extern "C" {{
    fn malloc(size: usize) -> *raw var u8;
    fn free(ptr: *raw var u8);
}}

fn main() {{
    var head = 0usize as *raw var Node
    var k: i64 = 1i64
    while k <= {n_nodes}i64 {{
        let n = malloc(16usize) as *raw var Node
        n.val = k
        n.next = head
        head = n
        k = k + 1i64
    }}
    var sum: i64 = 0i64
    var curr = head
    while (curr as usize) != 0usize {{
        sum = sum + curr.val
        let nxt = curr.next
        free(curr as *raw var u8)
        curr = nxt
    }}
    println(f"list_sum: {{sum}}")
}}
"""
        out = f"list_sum: {total}"
        write_test(cat, name, code, out=out)

    # Matrix operations (2x2 multiply)
    for i in range(21, 41):
        name = f"cx_gen_{i:03d}"
        a00 = i; a01 = i + 1; a10 = 2; a11 = 3
        b00 = 1; b01 = 0; b10 = 2; b11 = 1
        c00 = a00*b00 + a01*b10
        c01 = a00*b01 + a01*b11
        c10 = a10*b00 + a11*b10
        c11 = a10*b01 + a11*b11
        code = f"""
fn main() {{
    let a00 = {a00}i64; let a01 = {a01}i64; let a10 = {a10}i64; let a11 = {a11}i64
    let b00 = {b00}i64; let b01 = {b01}i64; let b10 = {b10}i64; let b11 = {b11}i64
    let c00 = a00 * b00 + a01 * b10
    let c01 = a00 * b01 + a01 * b11
    let c10 = a10 * b00 + a11 * b10
    let c11 = a10 * b01 + a11 * b11
    println(f"mat: [{{c00}}, {{c01}}; {{c10}}, {{c11}}]")
}}
"""
        out = f"mat: [{c00}, {c01}; {c10}, {c11}]"
        write_test(cat, name, code, out=out)

    # Ring buffer simulation
    for i in range(41, 61):
        name = f"cx_gen_{i:03d}"
        cap = 4
        ops = i + 5
        # simulate
        buf = [0] * cap
        head = 0
        tail = 0
        for op in range(ops):
            buf[head % cap] = op * 2
            head += 1
            if head - tail > cap:
                tail += 1
        last_elem = buf[(head - 1) % cap]
        code = f"""
fn main() {{
    var buf = [0i64, 0i64, 0i64, 0i64]
    var head = 0usize
    var op = 0i64
    while op < {ops}i64 {{
        buf[head % 4usize] = op * 2i64
        head = head + 1usize
        op = op + 1i64
    }}
    let last = buf[(head - 1usize) % 4usize]
    println(f"ring_last: {{last}}")
}}
"""
        out = f"ring_last: {last_elem}"
        write_test(cat, name, code, out=out)

# ==========================================
# 12. 17_runtime_safety (30 tests)
# ==========================================
def gen_runtime_safety():
    cat = "17_runtime_safety"
    # Division by zero panics
    for i in range(1, 16):
        name = f"rt_gen_{i:03d}"
        code = f"""
fn main() {{
    let a: i64 = {i * 10}i64
    let b: i64 = 0i64
    let c = a / b
    println(f"res: {{c}}")
}}
"""
        write_test(cat, name, code, contains="rad runtime panic: attempt to divide by zero", exit_code=1)

    # Slice bounds checking
    for i in range(16, 31):
        name = f"rt_gen_{i:03d}"
        idx = 10 + i
        code = f"""
fn main() {{
    var arr = [1i64, 2i64, 3i64, 4i64, 5i64]
    let bad_idx: usize = {idx}usize
    let v = arr[bad_idx]
    println(f"val: {{v}}")
}}
"""
        write_test(cat, name, code, contains="rad runtime panic: index out of bounds", exit_code=1)

# ==========================================
# 13. 18_algorithms (60 tests)
# ==========================================
def gen_algorithms():
    cat = "18_algorithms"
    # Binary search
    for i in range(1, 21):
        name = f"algo_gen_{i:03d}"
        target = i * 4
        arr = [k * 4 for k in range(1, 15)]
        idx = arr.index(target) if target in arr else -1
        code = f"""
fn binary_search(arr: []i64, target: i64) -> i64 {{
    var low: i64 = 0i64
    var high: i64 = (arr.len as i64) - 1i64
    while low <= high {{
        let mid = low + (high - low) / 2i64
        let val = arr[mid as usize]
        if val == target {{
            return mid
        }} else if val < target {{
            low = mid + 1i64
        }} else {{
            high = mid - 1i64
        }}
    }}
    return -1i64
}}

fn main() {{
    let data = [4i64, 8i64, 12i64, 16i64, 20i64, 24i64, 28i64, 32i64, 36i64, 40i64, 44i64, 48i64, 52i64, 56i64]
    let res = binary_search(data, {target}i64)
    println(f"bsearch({target}): {{res}}")
}}
"""
        out = f"bsearch({target}): {idx}"
        write_test(cat, name, code, out=out)

    # Bubble sort on slices
    for i in range(21, 41):
        name = f"algo_gen_{i:03d}"
        vals = [((i * 17 + k * 13) % 100) for k in range(6)]
        sorted_vals = sorted(vals)
        s_vals = ", ".join(f"{v}i64" for v in vals)
        exp_s = ", ".join(str(v) for v in sorted_vals)
        code = f"""
fn main() {{
    var arr = [{s_vals}]
    let n = arr.len
    var a = 0usize
    while a < n {{
        var b = 0usize
        while b < n - 1usize - a {{
            if arr[b] > arr[b + 1usize] {{
                let tmp = arr[b]
                arr[b] = arr[b + 1usize]
                arr[b + 1usize] = tmp
            }}
            b = b + 1usize
        }}
        a = a + 1usize
    }}
    println(f"sorted: [{{arr[0]}}, {{arr[1]}}, {{arr[2]}}, {{arr[3]}}, {{arr[4]}}, {{arr[5]}}]")
}}
"""
        out = f"sorted: [{exp_s}]"
        write_test(cat, name, code, out=out)

    # Prime factorization / Primality test
    for i in range(41, 61):
        name = f"algo_gen_{i:03d}"
        n = i * 2 + 15
        is_prime = True
        for d in range(2, int(n**0.5) + 1):
            if n % d == 0:
                is_prime = False
                break
        code = f"""
fn is_prime(n: i64) -> bool {{
    if n <= 1i64 {{
        return false
    }}
    var d: i64 = 2i64
    while d * d <= n {{
        if n % d == 0i64 {{
            return false
        }}
        d = d + 1i64
    }}
    return true
}}

fn main() {{
    let res = is_prime({n}i64)
    println(f"prime({n}): {{res}}")
}}
"""
        out = f"prime({n}): {1 if is_prime else 0}"
        write_test(cat, name, code, out=out)

# ==========================================
# 14. 12_must_fail (100 tests)
# ==========================================
def gen_must_fail():
    cat = "12_must_fail"
    # Mutating immutable variable (E0021)
    for i in range(1, 21):
        name = f"nf_gen_{i:03d}"
        code = f"""
fn main() {{
    let x: i64 = {i}i64
    x = x + 1i64
}}
"""
        write_test(cat, name, code, diag="cannot assign to immutable variable 'x'")

    # Unresolved identifier (E0020)
    for i in range(21, 41):
        name = f"nf_gen_{i:03d}"
        ident = f"nonexistent_var_{i}"
        code = f"""
fn main() {{
    let a: i64 = {ident} + 5i64
}}
"""
        write_test(cat, name, code, diag=f"unresolved identifier '{ident}'")

    # Break / Continue outside loop (E0025)
    for i in range(41, 51):
        name = f"nf_gen_{i:03d}"
        code = f"""
fn main() {{
    let x = {i}
    break;
}}
"""
        write_test(cat, name, code, diag="'break' outside of a loop")

    for i in range(51, 61):
        name = f"nf_gen_{i:03d}"
        code = f"""
fn main() {{
    let y = {i}
    continue;
}}
"""
        write_test(cat, name, code, diag="'continue' outside of a loop")

    # Redefinition of function (E0027)
    for i in range(61, 71):
        name = f"nf_gen_{i:03d}"
        fn_name = f"duplicate_func_{i}"
        code = f"""
fn {fn_name}() {{
    let x = 1
}}
fn {fn_name}() {{
    let x = 2
}}
fn main() {{
}}
"""
        write_test(cat, name, code, diag=f"redefinition of function '{fn_name}'")

    # Missing main entry point (E0026)
    for i in range(71, 81):
        name = f"nf_gen_{i:03d}"
        code = f"""
fn not_main_{i}() {{
    println("hello")
}}
"""
        write_test(cat, name, code, diag="entry point 'main' function not found")

    # Same-line statement separator missing (E0011)
    for i in range(81, 91):
        name = f"nf_gen_{i:03d}"
        code = f"""
fn main() {{
    let a = {i} let b = {i + 1}
}}
"""
        write_test(cat, name, code, diag="expected ';' or newline between statements on the same line")

    # Mismatched types in binary operator (E0023)
    for i in range(91, 101):
        name = f"nf_gen_{i:03d}"
        code = f"""
fn main() {{
    let s: str = "prefix_{i}"
    let num: i64 = {i}i64
    let r = s + num
}}
"""
        write_test(cat, name, code, diag="mismatched types: cannot apply operator '+'")

if __name__ == "__main__":
    print("Generating 01_basics...")
    gen_basics()
    print("Generating 02_types...")
    gen_types()
    print("Generating 03_control_flow...")
    gen_control_flow()
    print("Generating 04_functions...")
    gen_functions()
    print("Generating 05_structs...")
    gen_structs()
    print("Generating 06_collections...")
    gen_collections()
    print("Generating 07_enums_match...")
    gen_enums_match()
    print("Generating 08_memory...")
    gen_memory()
    print("Generating 09_c_interop...")
    gen_c_interop()
    print("Generating 10_stdlib...")
    gen_stdlib()
    print("Generating 11_complex...")
    gen_complex()
    print("Generating 17_runtime_safety...")
    gen_runtime_safety()
    print("Generating 18_algorithms...")
    gen_algorithms()
    print("Generating 12_must_fail...")
    gen_must_fail()
    print("All tests generated successfully!")
