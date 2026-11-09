// ==============================================================================
// llvm_stubs.cpp — Non-X86 LLVM Target Initializer Stubs for Minimal radc
//
// liblldELF.a references target initializers for all LLVM architectures enabled
// during LLD compilation. Since Rad targets x86_64 exclusively, these stubs
// satisfy the linker without linking hundreds of megabytes of non-x86 backends.
// ==============================================================================

extern "C" {

#define STUB_TARGET(T) \
    void LLVMInitialize##T##TargetInfo() {} \
    void LLVMInitialize##T##Target() {} \
    void LLVMInitialize##T##TargetMC() {} \
    void LLVMInitialize##T##AsmPrinter() {} \
    void LLVMInitialize##T##AsmParser() {} \
    void LLVMInitialize##T##Disassembler() {}

    STUB_TARGET(AArch64)
    STUB_TARGET(AMDGPU)
    STUB_TARGET(ARM)
    STUB_TARGET(AVR)
    STUB_TARGET(BPF)
    STUB_TARGET(Hexagon)
    STUB_TARGET(Lanai)
    STUB_TARGET(LoongArch)
    STUB_TARGET(Mips)
    STUB_TARGET(MSP430)
    STUB_TARGET(NVPTX)
    STUB_TARGET(PowerPC)
    STUB_TARGET(RISCV)
    STUB_TARGET(Sparc)
    STUB_TARGET(SPIRV)
    STUB_TARGET(SystemZ)
    STUB_TARGET(VE)
    STUB_TARGET(WebAssembly)
    STUB_TARGET(XCore)

}
