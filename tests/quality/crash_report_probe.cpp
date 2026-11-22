#include "crash_report.h"
#include <csignal>
#include <cstdlib>
#include <cstring>

int main(int argc, char **argv) {
    rad_install_crash_reporting();
    if (argc > 1 && std::strcmp(argv[1], "abort") == 0) std::abort();
    std::raise(SIGSEGV);
    return 0;
}
