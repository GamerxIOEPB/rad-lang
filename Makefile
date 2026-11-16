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
RADC ?= $(shell \
    if command -v radc >/dev/null 2>&1; then \
        command -v radc; \
    elif [ -x "$(HOME)/.rad/bin/radc" ]; then \
        echo "$(HOME)/.rad/bin/radc"; \
    elif [ -x "bin/radc" ]; then \
        echo "$$(pwd)/bin/radc"; \
    else \
        echo "radc"; \
    fi)

RADC_FLAGS ?= -O2
RAD_FLAGS  ?= -O2
PREFIX     ?= $(HOME)/.rad

# LLVM compilation and link flags
LLVM_CXXFLAGS ?= $(shell llvm-config --cxxflags 2>/dev/null || echo "-I$(PREFIX)/include")
LLVM_LDFLAGS  ?= $(shell llvm-config --ldflags 2>/dev/null || echo "")

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
    $(RADPM_DIR)/fmt.rad \
    $(RADPM_DIR)/lsp.rad \
    $(RADPM_DIR)/main.rad

# Output binaries
BIN_DIR := bin
BIN_RADC := $(BIN_DIR)/radc
BIN_RAD  := $(BIN_DIR)/rad

.PHONY: all radc rad dist install clean help check-radc

all: check-radc $(BIN_RADC) $(BIN_RAD)
	@echo ""
	@echo "======================================================================"
	@echo " Rad Toolchain Built Successfully into $(BIN_DIR)/"
	@echo "   - $(BIN_RADC)"
	@echo "   - $(BIN_RAD)"
	@echo "======================================================================"

check-radc:
	@if ! command -v $(RADC) >/dev/null 2>&1 && [ ! -x "$(RADC)" ]; then \
		echo "ERROR: 'radc' not found in PATH, ~/.rad/bin/radc, or bin/radc."; \
		echo "Please provide the path to radc:"; \
		echo "  make RADC=/path/to/radc"; \
		exit 1; \
	fi

radc: $(BIN_RADC)

$(BIN_RADC): $(RADC_SRCS) $(RADC_DIR)/util.ll $(RADC_DIR)/backend_bridge.cpp
	@mkdir -p $(BIN_DIR)
	@echo "==> Compiling backend bridge..."
	clang++ -c -O2 -fPIC $(LLVM_CXXFLAGS) -fexceptions $(RADC_DIR)/backend_bridge.cpp -o $(BIN_DIR)/backend_bridge.o
	@echo "==> Compiling self-hosted compiler ($@) using $(RADC)..."
	@if $(RADC) --version 2>&1 | grep -q "0.2"; then \
		$(RADC) -c $(RADC_SRCS) -o $(BIN_DIR)/radc_rad.o $(RADC_FLAGS); \
	else \
		$(RADC) --emit-llvm $(RADC_SRCS) -o $(BIN_DIR)/radc_rad.ll $(RADC_FLAGS) && \
		rad-llc -filetype=obj -relocation-model=pic $(BIN_DIR)/radc_rad.ll -o $(BIN_DIR)/radc_rad.o; \
	fi
	clang++ $(BIN_DIR)/radc_rad.o $(BIN_DIR)/backend_bridge.o $(LLVM_LDFLAGS) -L$(PREFIX)/lib/llvm -Wl,-rpath,'$$ORIGIN/../lib/llvm' -lLLVM -llldELF -llldCommon -o $(BIN_RADC)
	@chmod 755 $(BIN_RADC)

rad: $(BIN_RAD)

$(BIN_RAD): $(RAD_SRCS) $(BIN_RADC)
	@mkdir -p $(BIN_DIR)
	@echo "==> Compiling package manager ($@) using $(BIN_RADC)..."
	$(BIN_RADC) $(RAD_SRCS) -o $(BIN_RAD) $(RAD_FLAGS)
	@chmod 755 $(BIN_RAD)

arcade: $(BIN_RADC)
	@echo "==> Building Rad Arcade games (pure native single-file imports)..."
	@mkdir -p bin/arcade
	$(BIN_RADC) tests/rad_arcade/tetris/main.rad -o bin/arcade/tetris
	$(BIN_RADC) tests/rad_arcade/dungeon/main.rad -o bin/arcade/dungeon
	$(BIN_RADC) tests/rad_arcade/invaders/main.rad -o bin/arcade/invaders
	$(BIN_RADC) tests/rad_arcade/raycaster/main.rad -o bin/arcade/raycaster
	$(BIN_RADC) tests/rad_arcade/snake/main.rad -o bin/arcade/snake
	$(BIN_RADC) tests/rad_arcade/pong/main.rad -o bin/arcade/pong
	$(BIN_RADC) tests/rad_arcade/breakout/main.rad -o bin/arcade/breakout
	$(BIN_RADC) tests/rad_arcade/2048/main.rad -o bin/arcade/2048
	$(BIN_RADC) tests/rad_arcade/radchess/src/main.rad -o bin/arcade/radchess
	$(BIN_RADC) tests/rad_arcade/launcher.rad -o bin/arcade/arcade
	@cp -f bin/arcade/arcade bin/rad-arcade
	@echo "[✓] Rad Arcade games & unified hub built in bin/arcade/"

dist:
	@bash scripts/build_distribution.sh

install: all
	@echo "==> Installing Rad toolchain to $(PREFIX)..."
	@mkdir -p $(PREFIX)/bin $(PREFIX)/lib/targets/$(TARGET_TRIPLE) $(PREFIX)/lib/rad $(PREFIX)/share/rad $(PREFIX)/packages
	@find $(BIN_DIR) -maxdepth 1 -type f -exec cp -f {} $(PREFIX)/bin/ \;
	@if [ -d "$(BIN_DIR)/arcade" ]; then \
		mkdir -p $(PREFIX)/bin/arcade; \
		cp -rf $(BIN_DIR)/arcade/* $(PREFIX)/bin/arcade/; \
		cp -f $(BIN_DIR)/arcade/arcade $(PREFIX)/bin/rad-arcade; \
	fi
	cp -rf lib/rad/core lib/rad/alloc lib/rad/std $(PREFIX)/lib/rad/
	cp -rf $(SYSROOT)/* $(PREFIX)/lib/targets/$(TARGET_TRIPLE)/
	@if [ -d "../rad-lib/packages" ]; then \
		echo "==> Pre-installing Rad ecosystem libraries to $(PREFIX)/packages..."; \
		for pkg in rad-tui rad-json rad-http rad-args rad-test rad-math; do \
			if [ -d "../rad-lib/packages/$$pkg/0.1.0" ]; then \
				rm -rf $(PREFIX)/packages/$$pkg; \
				cp -rf ../rad-lib/packages/$$pkg/0.1.0 $(PREFIX)/packages/$$pkg; \
			fi; \
		done; \
		ln -sfn rad-tui $(PREFIX)/packages/tui; \
		ln -sfn rad-json $(PREFIX)/packages/json; \
		ln -sfn rad-http $(PREFIX)/packages/http; \
		ln -sfn rad-args $(PREFIX)/packages/args; \
		ln -sfn rad-test $(PREFIX)/packages/test; \
		ln -sfn rad-math $(PREFIX)/packages/math; \
		echo "    [✓] Ecosystem libraries installed to $(PREFIX)/packages"; \
	fi
	@echo "[✓] Rad installed successfully to $(PREFIX)/bin"

clean:
	@echo "==> Cleaning build artifacts..."
	rm -rf $(BIN_DIR)
	@echo "[✓] Clean complete."

help:
	@echo "Rad Build System"
	@echo "================="
	@echo "Targets:"
	@echo "  all        - Build radc and rad into bin/ (default)"
	@echo "  radc       - Compile self-hosted radc compiler (with embedded LLVM & LLD)"
	@echo "  rad        - Compile native package manager using radc"
	@echo "  dist       - Build distribution archives (.tar.gz) and SHA256SUMS"
	@echo "  install    - Install built binaries and standard library to PREFIX (default: ~/.rad)"
	@echo "  clean      - Remove bin/ and temporary distribution outputs"
	@echo ""
	@echo "Variables:"
	@echo "  RADC       - Path to radc compiler (default: auto-detected)"
	@echo "  PREFIX     - Installation prefix (default: $(HOME)/.rad)"
