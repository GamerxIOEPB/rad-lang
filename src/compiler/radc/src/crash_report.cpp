#include "crash_report.h"
#include "llvm/Support/Signals.h"
#include <atomic>
#include <unistd.h>

namespace {
void radc_fatal_signal_banner(void *) {
    static constexpr char message[] =
        "\n[radc] internal compiler error: the compiler received a fatal signal\n"
        "[radc] LLVM's stack trace follows. Please include it in a bug report.\n";
    // write(2) is async-signal-safe; avoid allocation, iostreams, and locks.
    (void)::write(STDERR_FILENO, message, sizeof(message) - 1);
}
}

extern "C" void rad_install_crash_reporting(void) {
    static std::atomic_flag installed = ATOMIC_FLAG_INIT;
    if (installed.test_and_set(std::memory_order_relaxed)) return;

    llvm::sys::AddSignalHandler(&radc_fatal_signal_banner, nullptr);
    llvm::sys::PrintStackTraceOnErrorSignal("radc", false);
}
