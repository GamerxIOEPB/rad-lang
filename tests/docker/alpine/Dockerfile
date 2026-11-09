# ==============================================================================
# Rad Toolchain — Alpine Linux Portability Acceptance Test Environment
# Pinned Alpine 3.23 (x86_64, musl libc)
#
# Contains ONLY test harness and diagnostic utilities (bash, binutils, file, tar).
# STRICTLY NO compilers, NO glibc/gcompat, NO LLVM/LLD, NO libstdc++.
# ==============================================================================

FROM alpine:3.23

RUN apk add --no-cache \
    bash \
    binutils \
    file \
    tar \
    coreutils

# Create an unprivileged test user
RUN addgroup -S radtest && adduser -S radtest -G radtest

WORKDIR /workspace
USER radtest
