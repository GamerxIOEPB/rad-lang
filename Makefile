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
RAD_LIB    ?= $(shell \
    if [ -d "../rad-lib" ]; then \
        echo "../rad-lib"; \
    elif [ -d "$(HOME)/Projects/rad-lib" ]; then \
        echo "$(HOME)/Projects/rad-lib"; \
    else \
        echo "../rad-lib"; \
    fi)

# LLVM compilation and link flags
LLVM_CXXFLAGS ?= $(shell llvm-config --cxxflags 2>/dev/null || echo "-I$(PREFIX)/include")
LLVM_LDFLAGS  ?= $(shell llvm-config --ldflags 2>/dev/null || echo "")
LLVM_SYSLIBS  ?= -lz -lzstd -lrt -ldl -lm

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
    $(RADC_DIR)/parser_types.rad \
    $(RADC_DIR)/parser_expr.rad \
    $(RADC_DIR)/parser_stmt.rad \
    $(RADC_DIR)/parser_decl.rad \
    $(RADC_DIR)/codegen.rad \
    $(RADC_DIR)/codegen_types.rad \
    $(RADC_DIR)/codegen_expr.rad \
    $(RADC_DIR)/codegen_call.rad \
    $(RADC_DIR)/codegen_stmt.rad \
    $(RADC_DIR)/codegen_sema.rad \
    $(RADC_DIR)/linker.rad

RAD_SRCS := \
    $(RADPM_DIR)/util.rad \
    $(RADPM_DIR)/fmt.rad \
    $(RADPM_DIR)/lsp.rad \
    $(RADPM_DIR)/toml.rad \
    $(RADPM_DIR)/cmd_project.rad \
    $(RADPM_DIR)/cmd_pkg.rad \
    $(RADPM_DIR)/cmd_build.rad \
    $(RADPM_DIR)/cmd_doctor.rad \
    $(RADPM_DIR)/test.rad \
    $(RADPM_DIR)/bench.rad \
    $(RADPM_DIR)/doc.rad \
    $(RADPM_DIR)/main.rad

# Output binaries
BIN_DIR := bin
BIN_RADC := $(BIN_DIR)/radc
BIN_RAD  := $(BIN_DIR)/rad

.PHONY: all radc rad dist install clean help check-radc test quality-test sync-docs sysroot self-host-check

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

$(BIN_RADC): $(RADC_SRCS) $(RADC_DIR)/backend_bridge.cpp $(RADC_DIR)/crash_report.cpp
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

self-host-check: $(BIN_RADC)
	@RADC="$(abspath $(BIN_RADC))" bash scripts/verify_self_hosting.sh

test: $(BIN_RADC)
	@RADC="$(abspath $(BIN_RADC))" bash tests/quality/run_all.sh

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

sysroot:
	@bash scripts/fetch_sysroot.sh

sync-docs:
	@echo "==> Synchronizing docs/docs/*.md to skills references..."
	@mkdir -p extensions/skills/rad/references
	@cp -f docs/docs/*.md extensions/skills/rad/references/
	@if [ -d "$(HOME)/.gemini/antigravity-cli/skills/rad/references" ]; then \
		cp -f docs/docs/*.md "$(HOME)/.gemini/antigravity-cli/skills/rad/references/"; \
	fi
	@python3 -c "import os, json; d='docs/docs'; fs=sorted([f for f in os.listdir(d) if f.endswith('.md')]); data={f: open(os.path.join(d, f)).read() for f in fs}; open('docs/docs-data.js', 'w').write('window.RAD_DOCS = ' + json.dumps(data, indent=2) + ';\n')"
	@echo "  [✓] Documentation synchronized across portal and skills."

install: all
	@echo "==> Installing Rad toolchain to $(PREFIX)..."
	@mkdir -p $(PREFIX)/bin $(PREFIX)/lib/targets/$(TARGET_TRIPLE) $(PREFIX)/lib/rad $(PREFIX)/share/rad
	@find $(BIN_DIR) -maxdepth 1 -type f -exec cp -f {} $(PREFIX)/bin/ \;
	cp -rf lib/rad/* $(PREFIX)/lib/rad/
	cp -rf $(SYSROOT)/* $(PREFIX)/lib/targets/$(TARGET_TRIPLE)/
	@if [ -d "share/rad" ]; then cp -rf share/rad/* $(PREFIX)/share/rad/; fi
	@echo "==> Installing full Rad ecosystem libraries to $(PREFIX)/lib/rad..."
	@ALL_PKGS="rad-args rad-test rad-json rad-toml rad-log rad-math rad-tui rad-http rad-kv rad-sqlite rad-gfx rad-gui rad-sound rad-yaml"; \
	RAD_LIB_PKGS="$(RAD_LIB)/packages"; \
	if [ ! -d "$$RAD_LIB_PKGS" ] && [ -d "$(HOME)/Projects/rad-lib/packages" ]; then \
		RAD_LIB_PKGS="$(HOME)/Projects/rad-lib/packages"; \
	fi; \
	if [ -d "$$RAD_LIB_PKGS" ]; then \
		for pkg in $$ALL_PKGS; do \
			if [ -d "$$RAD_LIB_PKGS/$$pkg/0.1.0" ]; then \
				rm -rf $(PREFIX)/lib/rad/$$pkg; \
				cp -rf "$$RAD_LIB_PKGS/$$pkg/0.1.0" $(PREFIX)/lib/rad/$$pkg; \
				short_name=$${pkg#rad-}; \
				ln -sfn "$$pkg" "$(PREFIX)/lib/rad/$$short_name"; \
			fi; \
		done; \
		if [ -f "$$RAD_LIB_PKGS/rad-sqlite/0.1.0/vendor/libsqlite3.a" ]; then \
			mkdir -p $(PREFIX)/lib/targets/$(TARGET_TRIPLE)/lib; \
			cp -f "$$RAD_LIB_PKGS/rad-sqlite/0.1.0/vendor/libsqlite3.a" $(PREFIX)/lib/targets/$(TARGET_TRIPLE)/lib/; \
			echo "    [✓] Installed static archive libsqlite3.a to $(PREFIX)/lib/targets/$(TARGET_TRIPLE)/lib"; \
		fi; \
		echo "    [✓] All ecosystem libraries installed from $$RAD_LIB_PKGS"; \
	else \
		echo "==> Local rad-lib not found. Checking installed packages using rad package list -g..."; \
		INSTALLED=$$($(PREFIX)/bin/rad package list -g 2>/dev/null || $(BIN_DIR)/rad package list -g 2>/dev/null); \
		for pkg in $$ALL_PKGS; do \
			if echo "$$INSTALLED" | grep -q "$$pkg"; then \
				echo "    [✓] $$pkg already installed"; \
			else \
				echo "    Installing missing package $$pkg via rad package install..."; \
				$(PREFIX)/bin/rad package install "$$pkg" || $(BIN_DIR)/rad package install "$$pkg" || true; \
			fi; \
		done; \
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
