# Rad quality and memory-safety tests

Run with:

```bash
make quality-test
make test
# Or, after building radc:
RADC="$PWD/bin/radc" bash tests/quality/run_all.sh
```

The suite checks the core modules (excluding `core/ffi`, which currently uses
unsupported `type` alias syntax), standard-library modules, allocator
modules, and in-tree ecosystem package roots. It also runs the existing memory,
collection and standard-library programs and an additional stress test covering
malloc/realloc/free, Vec, String, hash collections, Arena and LinkedList.

A native probe links the same `crash_report.cpp` as `radc`, triggers SIGSEGV
and SIGABRT, and checks for the Rad ICE banner and LLVM stack trace. Valgrind
checks the compiled integration and memory-stress workloads for invalid
accesses and definite/indirect leaks. A separate intentionally-invalid
use-after-free probe verifies Memcheck's detection.

Valgrind is optional locally. CI sets `REQUIRE_VALGRIND=1`; missing tooling or
a missing memory-test binary is a hard failure. Raw pointers remain explicitly
unsafe: Valgrind only checks the exercised workloads and cannot prove all
possible pointer programs safe.
