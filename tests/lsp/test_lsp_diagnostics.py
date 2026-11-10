import subprocess
import json
import sys

def send_msg(proc, payload):
    body = json.dumps(payload).encode("utf-8")
    header = f"Content-Length: {len(body)}\r\n\r\n".encode("utf-8")
    proc.stdin.write(header + body)
    proc.stdin.flush()

def read_msg(proc):
    header = b""
    while b"\r\n\r\n" not in header:
        chunk = proc.stdout.read(1)
        if not chunk:
            return None
        header += chunk
    parts = header.decode("utf-8").split("\r\n")
    length = 0
    for p in parts:
        if p.startswith("Content-Length:"):
            length = int(p.split(":")[1].strip())
    body = proc.stdout.read(length)
    return json.loads(body.decode("utf-8"))

def test_diagnostics():
    cmd = [sys.argv[1] if len(sys.argv) > 1 else "./bin/rad", "lsp"]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    # Initialize
    send_msg(proc, {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {"capabilities": {}}
    })
    resp = read_msg(proc)
    assert resp and resp.get("id") == 1

    send_msg(proc, {
        "jsonrpc": "2.0",
        "method": "initialized",
        "params": {}
    })

    # Test Case 1: Undeclared variable assignment `a = 10`
    code1 = "fn main() {\n    a = 10\n}\n"
    send_msg(proc, {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
            "textDocument": {
                "uri": "file:///workspace/test1.rad",
                "languageId": "rad",
                "version": 1,
                "text": code1
            }
        }
    })
    resp1 = read_msg(proc)
    print("Test 1 (Undeclared assignment) diagnostics:", json.dumps(resp1, indent=2))
    assert resp1["method"] == "textDocument/publishDiagnostics"
    diags1 = resp1["params"]["diagnostics"]
    assert len(diags1) == 1
    assert diags1[0]["code"] == "E0020"
    assert diags1[0]["severity"] == 1
    assert diags1[0]["range"]["start"]["line"] == 1
    assert diags1[0]["range"]["start"]["character"] == 4
    assert diags1[0]["range"]["end"]["character"] == 5
    print("  [✓] Test 1 passed: E0020 error underlined 'a' with severity 1")

    # Test Case 2: Unused mutability `var a = 10; print(a)`
    code2 = "fn main() {\n    var a = 10\n    print(a)\n}\n"
    send_msg(proc, {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
            "textDocument": {
                "uri": "file:///workspace/test2.rad",
                "languageId": "rad",
                "version": 1,
                "text": code2
            }
        }
    })
    resp2 = read_msg(proc)
    print("Test 2 (Unused mutability) diagnostics:", json.dumps(resp2, indent=2))
    assert resp2["method"] == "textDocument/publishDiagnostics"
    diags2 = resp2["params"]["diagnostics"]
    assert len(diags2) == 1
    assert diags2[0]["code"] == "W0001"
    assert diags2[0]["severity"] == 2
    assert diags2[0]["range"]["start"]["line"] == 1
    assert diags2[0]["range"]["start"]["character"] == 4
    assert diags2[0]["range"]["end"]["character"] == 9
    print("  [✓] Test 2 passed: W0001 warning underlined 'var a' with severity 2")

    # Test Case 3: F-string interpolation column tracking
    code3 = "fn main() {\n    a = \"Abhinav\"\n    print(f\"Hi my name is {a}\")\n}\n"
    send_msg(proc, {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
            "textDocument": {
                "uri": "file:///workspace/test3.rad",
                "languageId": "rad",
                "version": 1,
                "text": code3
            }
        }
    })
    resp3 = read_msg(proc)
    print("Test 3 (F-string column tracking) diagnostics:", json.dumps(resp3, indent=2))
    assert resp3["method"] == "textDocument/publishDiagnostics"
    diags3 = resp3["params"]["diagnostics"]
    assert len(diags3) == 2
    # Diag 0: a = "Abhinav" undeclared assignment at line 1, col 4-5
    assert diags3[0]["range"]["start"]["line"] == 1
    assert diags3[0]["range"]["start"]["character"] == 4
    assert diags3[0]["range"]["end"]["character"] == 5
    # Diag 1: {a} unresolved identifier at line 2, col 27-28 (under 'a', NOT 'f' which is col 10)
    assert diags3[1]["range"]["start"]["line"] == 2
    assert diags3[1]["range"]["start"]["character"] == 27
    assert diags3[1]["range"]["end"]["character"] == 28
    print("  [✓] Test 3 passed: E0020 error underlined '{a}' at char 27-28, NOT 'f'")

    # Shutdown
    send_msg(proc, {"jsonrpc": "2.0", "id": 99, "method": "shutdown", "params": {}})
    read_msg(proc)
    send_msg(proc, {"jsonrpc": "2.0", "method": "exit", "params": {}})
    proc.wait(timeout=2)
    print("\nALL 3 DIAGNOSTIC TESTS PASSED CLEANLY!")

if __name__ == "__main__":
    test_diagnostics()
