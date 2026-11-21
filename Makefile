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
LLVM_SYSLIBS  ?= $(shell llvm-config --system-libs 2>/dev/null || echo "-lz -lzstd -lrt -ldl -lm")

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
    $(RADPM_DIR)/toml.rad \
    $(RADPM_DIR)/test.rad \
    $(RADPM_DIR)/bench.rad \
    $(RADPM_DIR)/doc.rad \
    $(RADPM_DIR)/main.rad

# Output binaries
BIN_DIR := bin
BIN_RADC := $(BIN_DIR)/radc
BIN_RAD  := $(BIN_DIR)/rad

.PHONY: all radc rad dist install clean help check-radc test quality-test

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

$(BIN_RADC): $(RADC_SRCS) $(RADC_DIR)/util.ll $(RADC_DIR)/backend_bridge.cpp $(RADC_DIR)/crash_report.cpp
	@mkdir -p $(BIN_DIR)
	@echo "==> Compiling backend bridge..."
	clang++ -c -O2 -fPIC $(LLVM_CXXFLAGS) -fexceptions $(RADC_DIR)/backend_bridge.cpp -o $(BIN_DIR)/backend_bridge.o
	clang++ -c -O2 -fPIC $(LLVM_CXXFLAGS) $(RADC_DIR)/crash_report.cpp -o $(BIN_DIR)/crash_report.o
	@echo "==> Compiling self-hosted compiler ($@) using $(RADC)..."
	@if $(RADC) --version 2>&1 | grep -q "0.2"; then \
		$(RADC) -c $(RADC_SRCS) -o $(BIN_DIR)/radc_rad.o $(RADC_FLAGS); \
	else \
		$(RADC) --emit-llvm $(RADC_SRCS) -o $(BIN_DIR)/radc_rad.ll $(RADC_FLAGS) && \
		rad-llc -filetype=obj -relocation-model=pic $(BIN_DIR)/radc_rad.ll -o $(BIN_DIR)/radc_rad.o; \
	fi
	clang++ $(BIN_DIR)/radc_rad.o $(BIN_DIR)/backend_bridge.o $(BIN_DIR)/crash_report.o $(LLVM_LDFLAGS) -L$(PREFIX)/lib/llvm -Wl,-rpath,'$$ORIGIN/../lib/llvm' -lLLVM -llldELF -llldWasm -llldCommon $(LLVM_SYSLIBS) -o $(BIN_RADC)
	@chmod 755 $(BIN_RADC)

rad: $(BIN_RAD)

$(BIN_RAD): $(RAD_SRCS) $(BIN_RADC)
	@mkdir -p $(BIN_DIR)
	@echo "==> Compiling package manager ($@) using $(BIN_RADC)..."
	$(BIN_RADC) $(RAD_SRCS) -o $(BIN_RAD) $(RAD_FLAGS)
	@chmod 755 $(BIN_RAD)

quality-test: $(BIN_RADC)
	@RADC="$(abspath $(BIN_RADC))" bash tests/quality/run.sh

test: $(BIN_RADC)
	@RADC="$(abspath $(BIN_RADC))" bash tests/radtest/runner/run_tests.sh
	@RADC="$(abspath $(BIN_RADC))" bash tests/quality/run.sh

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
	@mkdir -p $(PREFIX)/bin $(PREFIX)/lib/targets/$(TARGET_TRIPLE) $(PREFIX)/lib/rad $(PREFIX)/share/rad
	@find $(BIN_DIR) -maxdepth 1 -type f -exec cp -f {} $(PREFIX)/bin/ \;
	cp -rf lib/rad/* $(PREFIX)/lib/rad/
	cp -rf $(SYSROOT)/* $(PREFIX)/lib/targets/$(TARGET_TRIPLE)/
	@if [ -d "share/rad" ]; then cp -rf share/rad/* $(PREFIX)/share/rad/; fi
	@if [ -d "../rad-lib/packages" ]; then \
		echo "==> Pre-installing Rad ecosystem libraries to $(PREFIX)/lib/rad..."; \
		for pkg in rad-tui rad-json rad-http rad-args rad-test rad-math rad-log rad-kv rad-sqlite rad-gfx rad-toml rad-yaml rad-gui rad-sound; do \
			if [ -d "../rad-lib/packages/$$pkg/0.1.0" ]; then \
				rm -rf $(PREFIX)/lib/rad/$$pkg; \
				cp -rf ../rad-lib/packages/$$pkg/0.1.0 $(PREFIX)/lib/rad/$$pkg; \
			fi; \
		done; \
		ln -sfn rad-tui $(PREFIX)/lib/rad/tui; \
		ln -sfn rad-json $(PREFIX)/lib/rad/json; \
		ln -sfn rad-http $(PREFIX)/lib/rad/http; \
		ln -sfn rad-args $(PREFIX)/lib/rad/args; \
		ln -sfn rad-test $(PREFIX)/lib/rad/test; \
		ln -sfn rad-math $(PREFIX)/lib/rad/math; \
		ln -sfn rad-log $(PREFIX)/lib/rad/log; \
		ln -sfn rad-kv $(PREFIX)/lib/rad/kv; \
		ln -sfn rad-sqlite $(PREFIX)/lib/rad/sqlite; \
		ln -sfn rad-gfx $(PREFIX)/lib/rad/gfx; \
		ln -sfn rad-gui $(PREFIX)/lib/rad/gui; \
		ln -sfn rad-sound $(PREFIX)/lib/rad/sound; \
		ln -sfn rad-toml $(PREFIX)/lib/rad/toml; \
		ln -sfn rad-yaml $(PREFIX)/lib/rad/yaml; \
		echo "    [✓] Ecosystem libraries installed to $(PREFIX)/lib/rad"; \
	fi
	@ln -sfn lib/rad $(PREFIX)/packages
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
	@echo "  dist       - Build distribution archives (.tar.xz) and SHA256SUMS"
	@echo "  install    - Install built binaries and standard library to PREFIX (default: ~/.rad)"
	@echo "  clean      - Remove bin/ and temporary distribution outputs"
	@echo ""
	@echo "Variables:"
	@echo "  RADC       - Path to radc compiler (default: auto-detected)"
	@echo "  PREFIX     - Installation prefix (default: $(HOME)/.rad)"
