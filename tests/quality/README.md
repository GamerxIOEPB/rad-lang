# Rad quality and memory-safety tests

Run with:

```bash
make quality-test
# Run regression tests and quality checks as one failure-propagating command:
make test
# Or, after building radc:
RADC="$PWD/bin/radc" bash tests/quality/run_all.sh
```

The quality suite checks the core, standard-library and allocator modules,
plus every in-tree ecosystem package exposing `src/lib.rad`. It also runs the
existing memory, collection and standard-library integration programs and
adds stress coverage for malloc/realloc/free, Vec, String, hash collections,
Box, Arena and LinkedList.

A compiler crash probe links the same `crash_report.cpp` used by `radc`,
triggers SIGSEGV and SIGABRT, and checks for the Rad ICE banner and LLVM stack
trace. Valgrind checks all successfully built integration programs and the
memory stress workload for invalid accesses and definite/indirect leaks. A
separate deliberately-invalid use-after-free program verifies that Memcheck
actually detects an invalid read.

Valgrind is optional locally. CI sets `REQUIRE_VALGRIND=1`, making missing
tooling or a missing stress binary a hard failure. Raw pointers remain
explicitly unsafe: these tests verify exercised workloads but cannot prove
every possible pointer program safe.
