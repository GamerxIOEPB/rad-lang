# Rad quality and memory-safety tests

Run with:

```bash
make quality-test
# or, after building radc:
RADC="$PWD/bin/radc" bash tests/quality/run.sh
```

The runner performs three kinds of validation:

1. **Compile/import matrix:** checks the std root, every module under
   lib/rad/std/src, every allocator module under lib/rad/alloc/src, and every
   in-tree ecosystem package exposing src/lib.rad. These are compile checks,
   not claims that every function in every package has exhaustive behavioral
   coverage.
2. **Runtime regressions:** runs the existing memory, collection, and standard
   library integration programs plus a stress program covering malloc,
   realloc, free, Vec, String, HashMap, HashSet, StringHashMap, Box, Arena,
   and LinkedList.
3. **Compiler diagnostics and memory instrumentation:** builds a probe using
   the same crash_report.cpp linked into radc, triggers SIGSEGV and SIGABRT,
   and verifies the Rad ICE banner and stack trace. When Valgrind is installed,
   the stress binary is checked for invalid accesses and definite/indirect leaks.

Valgrind is optional locally. CI sets REQUIRE_VALGRIND=1 so a missing
installation becomes a failure. The crash probe requires llvm-config and a
C++ compiler.

Raw pointers remain an explicitly unsafe facility. These tests exercise
valid pointer workloads and use Valgrind to detect errors occurring under
those workloads; they do not prove safety for every possible pointer program,
nor do they make arbitrary invalid pointer dereferences safe.
