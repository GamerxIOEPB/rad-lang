# ==============================================================================
# Rad Toolchain — Hermetic Musl Compiler Builder Environment
# Base: Alpine 3.23 (x86_64, musl libc)
#
# Builds statically linked PIE executables for x86_64-unknown-linux-musl.
# Statically links LLVM and LLD in-process backend directly into radc.
# ==============================================================================

FROM --platform=linux/amd64 alpine:3.23

# 1. Install build toolchain and LLVM 21 static libraries
RUN apk add --no-cache \
    build-base \
    cmake \
    ninja \
    llvm21-dev \
    llvm21-static \
    zlib-dev \
    zlib-static \
    zstd-dev \
    zstd-static \
    git \
    bash \
    coreutils

# 2. Fix Alpine LLVM CMake export issue by creating empty static archives for optional testing targets
RUN for f in libLLVMTestingAnnotations.a libLLVMTestingSupport.a libllvm_gtest.a libllvm_gtest_main.a; do \
        ar crs "/usr/lib/llvm21/lib/$f" 2>/dev/null || true; \
    done

# 3. Clone and build static LLD libraries (liblldELF.a and liblldCommon.a) with position-independent code (-fPIC)
RUN git clone --depth 1 --branch llvmorg-21.1.2 --filter=blob:none --sparse https://github.com/llvm/llvm-project.git /tmp/llvm-lld && \
    cd /tmp/llvm-lld && \
    git sparse-checkout set lld cmake llvm/cmake && \
    mkdir -p /tmp/llvm-lld/build && cd /tmp/llvm-lld/build && \
    cmake -G Ninja /tmp/llvm-lld/lld \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_DIR=/usr/lib/llvm21/lib/cmake/llvm \
      -DBUILD_SHARED_LIBS=OFF \
      -DLLVM_LINK_LLVM_DYLIB=OFF \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
    ninja lldELF lldCommon && \
    mkdir -p /usr/local/lib/lld /usr/local/include && \
    cp lib/liblldELF.a lib/liblldCommon.a /usr/local/lib/lld/ && \
    cp -r /tmp/llvm-lld/lld/include/* /usr/local/include/ && \
    rm -rf /tmp/llvm-lld

WORKDIR /workspace
