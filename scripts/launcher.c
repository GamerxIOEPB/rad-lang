#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <limits.h>

int main(int argc, char **argv) {
    char exe_path[PATH_MAX];
    ssize_t len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
    if (len == -1) {
        perror("readlink /proc/self/exe");
        return 1;
    }
    exe_path[len] = '\0';

    char *bin_dir = dirname(exe_path); // <prefix>/bin
    char prefix[PATH_MAX];
    strncpy(prefix, bin_dir, sizeof(prefix) - 1);
    prefix[sizeof(prefix) - 1] = '\0';
    char *parent = dirname(prefix); // <prefix>

    char lib_llvm[PATH_MAX];
    snprintf(lib_llvm, sizeof(lib_llvm), "%s/lib/llvm", parent);

    // Update LD_LIBRARY_PATH if directory exists
    if (access(lib_llvm, F_OK) == 0) {
        char *old_ld = getenv("LD_LIBRARY_PATH");
        char new_ld[PATH_MAX * 2];
        if (old_ld && *old_ld) {
            snprintf(new_ld, sizeof(new_ld), "%s:%s", lib_llvm, old_ld);
        } else {
            snprintf(new_ld, sizeof(new_ld), "%s", lib_llvm);
        }
        setenv("LD_LIBRARY_PATH", new_ld, 1);
    }

    // Determine target binary from argv[0]
    char *base = basename(argv[0]);
    int is_cpp = (strstr(base, "clang++") != NULL);
    char target_binary[PATH_MAX];
    if (is_cpp) {
        snprintf(target_binary, sizeof(target_binary), "%s/clang++", lib_llvm);
    } else {
        snprintf(target_binary, sizeof(target_binary), "%s/clang", lib_llvm);
    }

    // Handle --version / -v cleanly even if backend tool is not yet installed
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--version") == 0 || strcmp(argv[i], "-v") == 0) {
            if (access(target_binary, X_OK) == 0) {
                argv[0] = is_cpp ? "clang++" : "clang";
                execv(target_binary, argv);
            }
            // Standalone fallback report
            printf("rad-%s version 0.2.1 (Rad toolchain standalone driver)\n", is_cpp ? "clang++" : "clang");
            printf("Target: x86_64-unknown-linux-musl\n");
            printf("Thread model: posix\n");
            return 0;
        }
    }

    // Try executing bundled compiler
    if (access(target_binary, X_OK) == 0) {
        argv[0] = is_cpp ? "clang++" : "clang";
        execv(target_binary, argv);
    }

    // Fallback: try system compiler in PATH
    const char *sys_cmd = is_cpp ? "clang++" : "clang";
    argv[0] = (char *)sys_cmd;
    execvp(sys_cmd, argv);

    fprintf(stderr, "error: %s: could not execute C/C++ compiler backend (%s or system %s).\n", base, target_binary, sys_cmd);
    return 1;
}
