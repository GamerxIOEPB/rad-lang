#!/usr/bin/env python3
"""
tests/lsp/test_lsp_client.py — Comprehensive Automated Test Suite for `rad lsp`
Validates stdio JSON-RPC 2.0 protocol, capabilities, diagnostics, completion,
hover, definition, document symbols, formatting, and lifecycle methods.
"""

import json
import subprocess
import sys
import time

def send_rpc(proc, msg_dict):
    content = json.dumps(msg_dict).encode("utf-8")
    header = f"Content-Length: {len(content)}\r\n\r\n".encode("utf-8")
    proc.stdin.write(header + content)
    proc.stdin.flush()

def read_rpc(proc, timeout=3.0):
    start = time.time()
    header_line = b""
    content_len = 0
    # Read headers
    while True:
        if time.time() - start > timeout:
            raise TimeoutError("Timed out waiting for LSP response header")
        line = proc.stdout.readline()
        if not line:
            return None
        line_str = line.decode("utf-8")
        if line_str.startswith("Content-Length:"):
            content_len = int(line_str.split(":")[1].strip())
        elif line_str in ("\r\n", "\n"):
            break

    if content_len == 0:
        return None

    # Read body
    body = proc.stdout.read(content_len)
    return json.loads(body.decode("utf-8"))

def main():
    print("==> Launching `rad lsp` process...")
    proc = subprocess.Popen(
        ["./bin/rad", "lsp"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    try:
        # 1. Test `initialize`
        print("==> [1/7] Testing `initialize` request...")
        init_req = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "processId": None,
                "rootUri": "file:///workspace",
                "capabilities": {}
            }
        }
        send_rpc(proc, init_req)
        init_resp = read_rpc(proc)
        print("    Initialize response:", json.dumps(init_resp, indent=2))
        assert init_resp is not None, "No initialize response received"
        assert init_resp.get("id") == 1
        capabilities = init_resp.get("result", {}).get("capabilities", {})
        assert capabilities.get("textDocumentSync") == 1, "textDocumentSync capability missing"
        assert capabilities.get("hoverProvider") is True, "hoverProvider missing"
        assert capabilities.get("definitionProvider") is True, "definitionProvider missing"
        assert capabilities.get("documentSymbolProvider") is True, "documentSymbolProvider missing"
        assert capabilities.get("documentFormattingProvider") is True, "documentFormattingProvider missing"
        assert "completionProvider" in capabilities, "completionProvider missing"
        print("    [✓] `initialize` returned correct server capabilities")

        # 2. Test `initialized` notification
        print("==> [2/7] Testing `initialized` notification...")
        send_rpc(proc, {"jsonrpc": "2.0", "method": "initialized", "params": {}})

        # 3. Test `textDocument/didOpen` diagnostics
        print("==> [3/7] Testing `textDocument/didOpen` & diagnostics...")
        valid_rad_code = "fn main() {\n    let msg = \"Hello Rad!\";\n    println(\"{}\", msg);\n}\n"
        send_rpc(proc, {
            "jsonrpc": "2.0",
            "method": "textDocument/didOpen",
            "params": {
                "textDocument": {
                    "uri": "file:///workspace/test.rad",
                    "languageId": "rad",
                    "version": 1,
                    "text": valid_rad_code
                }
            }
        })
        diag_notif = read_rpc(proc)
        print("    Diagnostics notification:", json.dumps(diag_notif, indent=2))
        assert diag_notif is not None
        assert diag_notif.get("method") == "textDocument/publishDiagnostics"
        diags = diag_notif.get("params", {}).get("diagnostics", [])
        assert len(diags) == 0, f"Expected 0 diagnostics for valid code, got: {diags}"
        print("    [✓] `textDocument/publishDiagnostics` emitted 0 diagnostics for clean code")

        # 4. Test `textDocument/hover`
        print("==> [4/7] Testing `textDocument/hover`...")
        send_rpc(proc, {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "textDocument/hover",
            "params": {
                "textDocument": {"uri": "file:///workspace/test.rad"},
                "position": {"line": 0, "character": 1} # on 'fn'
            }
        })
        hover_resp = read_rpc(proc)
        print("    Hover response:", json.dumps(hover_resp, indent=2))
        assert hover_resp.get("id") == 2
        hover_contents = hover_resp.get("result", {}).get("contents", {})
        assert "Keyword `fn`" in hover_contents.get("value", "")
        print("    [✓] `textDocument/hover` returned valid markdown documentation")

        # 5. Test `textDocument/completion`
        print("==> [5/7] Testing `textDocument/completion`...")
        send_rpc(proc, {
            "jsonrpc": "2.0",
            "id": 3,
            "method": "textDocument/completion",
            "params": {
                "textDocument": {"uri": "file:///workspace/test.rad"},
                "position": {"line": 1, "character": 4}
            }
        })
        comp_resp = read_rpc(proc)
        assert comp_resp.get("id") == 3
        res_data = comp_resp.get("result", [])
        if isinstance(res_data, list):
            items = res_data
        else:
            items = res_data.get("items", [])
        labels = [item.get("label") for item in items]
        print(f"    Completions count: {len(labels)}, sample: {labels[:8]}")
        assert "fn" in labels
        assert "let" in labels
        assert "var" in labels
        assert "println" in labels
        assert "i64" in labels
        print("    [✓] `textDocument/completion` returned standard keywords and types")

        # 6. Test `textDocument/documentSymbol`
        print("==> [6/7] Testing `textDocument/documentSymbol`...")
        send_rpc(proc, {
            "jsonrpc": "2.0",
            "id": 4,
            "method": "textDocument/documentSymbol",
            "params": {
                "textDocument": {"uri": "file:///workspace/test.rad"}
            }
        })
        sym_resp = read_rpc(proc)
        assert sym_resp.get("id") == 4
        symbols = sym_resp.get("result", [])
        sym_names = [s.get("name") for s in symbols]
        print("    Document symbols:", sym_names)
        assert "main" in sym_names
        print("    [✓] `textDocument/documentSymbol` returned symbol outline")

        # 7. Test `textDocument/formatting`
        print("==> [7/7] Testing `textDocument/formatting`...")
        unformatted_code = "fn   add(a:i64,b:i64)->i64\n{\nreturn a+b;\n}\n"
        send_rpc(proc, {
            "jsonrpc": "2.0",
            "method": "textDocument/didChange",
            "params": {
                "textDocument": {"uri": "file:///workspace/test.rad", "version": 2},
                "contentChanges": [{"text": unformatted_code}]
            }
        })
        # Did change might trigger diagnostics
        # Send formatting request
        send_rpc(proc, {
            "jsonrpc": "2.0",
            "id": 5,
            "method": "textDocument/formatting",
            "params": {
                "textDocument": {"uri": "file:///workspace/test.rad"},
                "options": {"tabSize": 4, "insertSpaces": True}
            }
        })
        # Consume any publishDiagnostics notification before reading response 5
        resp = read_rpc(proc)
        while resp.get("method") == "textDocument/publishDiagnostics":
            resp = read_rpc(proc)

        assert resp.get("id") == 5
        edits = resp.get("result", [])
        print("    Formatting edits count:", len(edits))
        assert len(edits) > 0
        new_text = edits[0].get("newText", "")
        print("    Formatted text from LSP:\n" + new_text)
        assert "fn add(a: i64, b: i64) -> i64 {" in new_text
        print("    [✓] `textDocument/formatting` returned correctly formatted text")

        # Shutdown & exit
        print("==> Testing `shutdown` and `exit`...")
        send_rpc(proc, {"jsonrpc": "2.0", "id": 6, "method": "shutdown", "params": {}})
        shut_resp = read_rpc(proc)
        assert shut_resp.get("id") == 6
        assert shut_resp.get("result") is None

        send_rpc(proc, {"jsonrpc": "2.0", "method": "exit", "params": {}})
        proc.wait(timeout=2.0)
        assert proc.returncode == 0
        print("    [✓] Clean LSP server exit code 0")

        print("\n=======================================================")
        print("ALL 7 RAD LANGUAGE SERVER (LSP) TESTS PASSED CLEANLY!")
        print("=======================================================")

    finally:
        if proc.poll() is None:
            proc.kill()

if __name__ == "__main__":
    main()
