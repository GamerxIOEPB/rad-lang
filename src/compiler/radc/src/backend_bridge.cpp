#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include "llvm-c/Core.h"
#include "llvm-c/Target.h"
#include "llvm-c/TargetMachine.h"
#include "llvm-c/IRReader.h"
#include "lld/Common/Driver.h"

LLD_HAS_DRIVER(elf)

static bool g_llvm_initialized = false;

extern "C" {

void rad_llvm_init() {
    if (g_llvm_initialized) return;
    LLVMInitializeX86TargetInfo();
    LLVMInitializeX86Target();
    LLVMInitializeX86TargetMC();
    LLVMInitializeX86AsmPrinter();
    g_llvm_initialized = true;
}

int rad_llvm_emit_obj(const char* ir_str, size_t ir_len, const char* out_obj_path, int opt_level, const char* target_triple, char* err_buf, size_t err_buf_len) {
    rad_llvm_init();

    LLVMMemoryBufferRef mem_buf = LLVMCreateMemoryBufferWithMemoryRangeCopy(ir_str, ir_len, "module.ll");
    LLVMContextRef ctx = LLVMContextCreate();
    LLVMModuleRef mod = nullptr;
    char* err_msg = nullptr;

    if (LLVMParseIRInContext2(ctx, mem_buf, &mod, &err_msg)) {
        if (err_buf && err_buf_len > 0) {
            snprintf(err_buf, err_buf_len, "%s", err_msg ? err_msg : "LLVM IR Parse Error");
        }
        if (err_msg) LLVMDisposeMessage(err_msg);
        LLVMContextDispose(ctx);
        return 1;
    }

    const char* triple = target_triple;
    char* default_triple = nullptr;
    if (!triple || strlen(triple) == 0) {
        default_triple = LLVMGetDefaultTargetTriple();
        triple = default_triple;
    }

    LLVMTargetRef target = nullptr;
    if (LLVMGetTargetFromTriple(triple, &target, &err_msg)) {
        if (err_buf && err_buf_len > 0) {
            snprintf(err_buf, err_buf_len, "%s", err_msg ? err_msg : "Unknown LLVM Target Triple");
        }
        if (err_msg) LLVMDisposeMessage(err_msg);
        if (default_triple) LLVMDisposeMessage(default_triple);
        LLVMDisposeModule(mod);
        LLVMContextDispose(ctx);
        return 1;
    }

    LLVMCodeGenOptLevel opt = LLVMCodeGenLevelDefault;
    if (opt_level == 0) opt = LLVMCodeGenLevelNone;
    else if (opt_level == 1) opt = LLVMCodeGenLevelLess;
    else if (opt_level == 2) opt = LLVMCodeGenLevelDefault;
    else if (opt_level >= 3) opt = LLVMCodeGenLevelAggressive;

    LLVMTargetMachineRef tm = LLVMCreateTargetMachine(
        target,
        triple,
        "generic",
        "",
        opt,
        LLVMRelocPIC,
        LLVMCodeModelDefault
    );

    if (LLVMTargetMachineEmitToFile(tm, mod, out_obj_path, LLVMObjectFile, &err_msg)) {
        if (err_buf && err_buf_len > 0) {
            snprintf(err_buf, err_buf_len, "%s", err_msg ? err_msg : "Failed to emit object file");
        }
        if (err_msg) LLVMDisposeMessage(err_msg);
        LLVMDisposeTargetMachine(tm);
        if (default_triple) LLVMDisposeMessage(default_triple);
        LLVMDisposeModule(mod);
        LLVMContextDispose(ctx);
        return 1;
    }

    LLVMDisposeTargetMachine(tm);
    if (default_triple) LLVMDisposeMessage(default_triple);
    LLVMDisposeModule(mod);
    LLVMContextDispose(ctx);
    return 0;
}

int rad_lld_link(int argc, const char** argv, char* err_buf, size_t err_buf_len) {
    try {
        std::vector<const char*> args;
        args.reserve(argc);
        for (int i = 0; i < argc; ++i) {
            args.push_back(argv[i]);
        }
        std::string out_str, err_str;
        llvm::raw_string_ostream os(out_str);
        llvm::raw_string_ostream es(err_str);
        bool ok = lld::elf::link(args, os, es, false, false);
        if (!ok) {
            if (err_buf && err_buf_len > 0) {
                snprintf(err_buf, err_buf_len, "%s", err_str.c_str());
            }
            return 1;
        }
        return 0;
    } catch (const std::exception& e) {
        if (err_buf && err_buf_len > 0) {
            snprintf(err_buf, err_buf_len, "LLD Exception: %s", e.what());
        }
        return 2;
    } catch (...) {
        if (err_buf && err_buf_len > 0) {
            snprintf(err_buf, err_buf_len, "Unknown LLD Exception");
        }
        return 3;
    }
}

int rad_lld_link_str(const char* cmd_str, char* err_buf, size_t err_buf_len) {
    if (!cmd_str || strlen(cmd_str) == 0) return 1;
    std::vector<std::string> storage;
    std::vector<const char*> args;
    std::string current;
    bool in_quote = false;
    for (const char* p = cmd_str; *p; ++p) {
        if (*p == ' ' && !in_quote) {
            if (!current.empty()) {
                storage.push_back(current);
                current.clear();
            }
        } else if (*p == '"') {
            in_quote = !in_quote;
        } else {
            current.push_back(*p);
        }
    }
    if (!current.empty()) storage.push_back(current);
    if (storage.empty()) return 1;

    // Ensure first argument is program name (e.g. "ld.lld")
    if (storage[0] == "rad-lld" || storage[0] == "ld.lld") {
        storage[0] = "ld.lld";
    }

    for (const auto& s : storage) {
        // Strip out shell redirects if present
        if (s == "2>/dev/null" || s == ">/dev/null") continue;
        args.push_back(s.c_str());
    }

    return rad_lld_link((int)args.size(), args.data(), err_buf, err_buf_len);
}

}
