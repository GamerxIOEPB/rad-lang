# ==============================================================================
# Rad Toolchain Makefile
# ==============================================================================

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

# Compiler discovery:
# 1. Use user-supplied RADC environment variable if given.
# 2. Check if 'radc' is in PATH.
# 3. Check if installed in ~/.rad/bin/radc.
# 4. Check if already built in ./bin/radc.
# 5. Check if reference compiler is available in old_rad.
RADC ?= $(shell \
    if command -v radc >/dev/null 2>&1; then \
        command -v radc; \
    elif [ -x "$(HOME)/.rad/bin/radc" ]; then \
        echo "$(HOME)/.rad/bin/radc"; \
    elif [ -x "bin/radc" ]; then \
        echo "$$(pwd)/bin/radc"; \
    elif [ -x "old_rad/target/release/radc" ]; then \
        echo "$$(pwd)/old_rad/target/release/radc"; \
    elif [ -x "old_rad/target/debug/radc" ]; then \
        echo "$$(pwd)/old_rad/target/debug/radc"; \
    else \
        echo "radc"; \
    fi)

RADC_FLAGS ?= -O2
RAD_FLAGS  ?= -O2
PREFIX     ?= $(HOME)/.rad

# Host & target triples
TARGET_TRIPLE ?= x86_64-unknown-linux-musl
SYSROOT       ?= lib/targets/$(TARGET_TRIPLE)

# Source files
RADC_DIR  := src/compiler/radc/src
RADPM_DIR := src/tools/rad_pm/src

RADC_SRCS := \
    $(RADC_DIR)/main.rad \
    $(RADC_DIR)/util.rad \
    $(RADC_DIR)/token.rad \
    $(RADC_DIR)/ast.rad \
    $(RADC_DIR)/parser.rad \
    $(RADC_DIR)/codegen.rad \
    $(RADC_DIR)/linker.rad

RAD_SRCS := \
    $(RADPM_DIR)/main.rad

LAUNCHER_SRC := scripts/launcher.c

# Output binaries
BIN_DIR := bin
BIN_RADC := $(BIN_DIR)/radc
BIN_RAD  := $(BIN_DIR)/rad
BIN_LLC  := $(BIN_DIR)/rad-llc
BIN_LLD     := $(BIN_DIR)/rad-lld
BIN_CLANG   := $(BIN_DIR)/rad-clang
BIN_CLANGXX := $(BIN_DIR)/rad-clang++

.PHONY: all radc rad launchers dist install clean help check-radc

all: check-radc $(BIN_RADC) $(BIN_RAD) $(BIN_LLC) $(BIN_LLD) $(BIN_CLANG) $(BIN_CLANGXX)
	@echo ""
	@echo "======================================================================"
	@echo " Rad Toolchain Built Successfully into $(BIN_DIR)/"
	@echo "   - $(BIN_RADC)"
	@echo "   - $(BIN_RAD)"
	@echo "   - $(BIN_LLC)"
	@echo "   - $(BIN_LLD)"
	@echo "   - $(BIN_CLANG)"
	@echo "   - $(BIN_CLANGXX)"
	@echo "======================================================================"

check-radc:
	@if ! command -v $(RADC) >/dev/null 2>&1 && [ ! -x "$(RADC)" ]; then \
		echo "ERROR: 'radc' not found in PATH, ~/.rad/bin/radc, or bin/radc."; \
		echo "Please provide the path to radc:"; \
		echo "  make RADC=/path/to/radc"; \
		exit 1; \
	fi

radc: $(BIN_RADC)

$(BIN_RADC): $(RADC_SRCS) $(RADC_DIR)/util.ll
	@mkdir -p $(BIN_DIR)
	@echo "==> Compiling self-hosted compiler ($@) using $(RADC)..."
	$(RADC) $(RADC_SRCS) -o $(BIN_RADC) $(RADC_FLAGS)
	@chmod 755 $(BIN_RADC)

rad: $(BIN_RAD)

$(BIN_RAD): $(RAD_SRCS) $(BIN_RADC)
	@mkdir -p $(BIN_DIR)
	@echo "==> Compiling package manager ($@) using $(BIN_RADC)..."
	$(BIN_RADC) $(RAD_SRCS) -o $(BIN_RAD) $(RAD_FLAGS)
	@chmod 755 $(BIN_RAD)

launchers: $(BIN_LLC) $(BIN_LLD) $(BIN_CLANG) $(BIN_CLANGXX)

$(BIN_LLC): $(LAUNCHER_SRC) $(SYSROOT)/crt/rcrt1.o
	@mkdir -p $(BIN_DIR)
	@echo "==> Building static PIE launcher ($@)..."
	clang -c -target $(TARGET_TRIPLE) $(LAUNCHER_SRC) -o $(BIN_DIR)/launcher.o
	ld.lld -flavor gnu -m elf_x86_64 -static -pie --no-dynamic-linker -z text -z noexecstack \
		-o $(BIN_LLC) \
		$(SYSROOT)/crt/rcrt1.o \
		$(SYSROOT)/crt/crti.o \
		$(BIN_DIR)/launcher.o \
		-L$(SYSROOT)/lib \
		--start-group $(SYSROOT)/lib/libc.a $(SYSROOT)/lib/libclang_rt.builtins-x86_64.a --end-group \
		$(SYSROOT)/crt/crtn.o
	@rm -f $(BIN_DIR)/launcher.o
	@chmod 755 $(BIN_LLC)

$(BIN_LLD): $(BIN_LLC)
	@mkdir -p $(BIN_DIR)
	@echo "==> Creating linker launcher ($@)..."
	cp -f $(BIN_LLC) $(BIN_LLD)
	@chmod 755 $(BIN_LLD)

$(BIN_CLANG): $(BIN_LLC)
	@mkdir -p $(BIN_DIR)
	@echo "==> Creating C compiler launcher ($@)..."
	cp -f $(BIN_LLC) $(BIN_CLANG)
	@chmod 755 $(BIN_CLANG)

$(BIN_CLANGXX): $(BIN_LLC)
	@mkdir -p $(BIN_DIR)
	@echo "==> Creating C++ compiler launcher ($@)..."
	cp -f $(BIN_LLC) $(BIN_CLANGXX)
	@chmod 755 $(BIN_CLANGXX)

dist:
	@bash scripts/build_distribution.sh

install: all
	@echo "==> Installing Rad toolchain to $(PREFIX)..."
	@mkdir -p $(PREFIX)/bin $(PREFIX)/lib/targets/$(TARGET_TRIPLE) $(PREFIX)/lib/rad $(PREFIX)/share/rad $(PREFIX)/lib/llvm
	cp -f $(BIN_DIR)/* $(PREFIX)/bin/
	cp -rf library/core library/alloc library/std $(PREFIX)/lib/rad/
	cp -rf $(SYSROOT)/* $(PREFIX)/lib/targets/$(TARGET_TRIPLE)/
	@if [ -x /usr/bin/clang ]; then \
		cp -L /usr/bin/clang $(PREFIX)/lib/llvm/clang 2>/dev/null || true; \
		ln -sf clang $(PREFIX)/lib/llvm/clang++ 2>/dev/null || true; \
		cp -P /usr/lib/libclang-cpp*.so* $(PREFIX)/lib/llvm/ 2>/dev/null || true; \
	fi
	@if [ -d /usr/lib/clang ]; then \
		cp -rf /usr/lib/clang $(PREFIX)/lib/ 2>/dev/null || true; \
		ln -sf . $(PREFIX)/lib/lib 2>/dev/null || true; \
	fi
	@echo "[✓] Rad installed successfully to $(PREFIX)/bin"

clean:
	@echo "==> Cleaning build artifacts..."
	rm -rf $(BIN_DIR) target/dist target/dist_build
	@echo "[✓] Clean complete."

help:
	@echo "Rad Build System"
	@echo "================="
	@echo "Targets:"
	@echo "  all        - Build radc, rad, rad-llc, and rad-lld into bin/ (default)"
	@echo "  radc       - Compile self-hosted radc compiler using existing radc"
	@echo "  rad        - Compile native package manager using radc"
	@echo "  launchers  - Compile static PIE rad-llc and rad-lld wrappers"
	@echo "  dist       - Build distribution archives (.tar.gz) and SHA256SUMS"
	@echo "  install    - Install built binaries and standard library to PREFIX (default: ~/.rad)"
	@echo "  clean      - Remove bin/ and temporary distribution outputs"
	@echo ""
	@echo "Variables:"
	@echo "  RADC       - Path to radc compiler (default: auto-detected)"
	@echo "  PREFIX     - Installation prefix (default: $(HOME)/.rad)"
