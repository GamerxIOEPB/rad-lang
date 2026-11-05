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

    // Update LD_LIBRARY_PATH
    char *old_ld = getenv("LD_LIBRARY_PATH");
    char new_ld[PATH_MAX * 2];
    if (old_ld && *old_ld) {
        snprintf(new_ld, sizeof(new_ld), "%s:%s", lib_llvm, old_ld);
    } else {
        snprintf(new_ld, sizeof(new_ld), "%s", lib_llvm);
    }
    setenv("LD_LIBRARY_PATH", new_ld, 1);

    // Determine target binary from argv[0]
    char *base = basename(argv[0]);
    char target_binary[PATH_MAX];
    if (strstr(base, "clang++") != NULL) {
        snprintf(target_binary, sizeof(target_binary), "%s/clang++", lib_llvm);
        argv[0] = "clang++";
    } else if (strstr(base, "clang") != NULL) {
        snprintf(target_binary, sizeof(target_binary), "%s/clang", lib_llvm);
        argv[0] = "clang";
    } else if (strstr(base, "lld") != NULL) {
        snprintf(target_binary, sizeof(target_binary), "%s/ld.lld", lib_llvm);
        argv[0] = "ld.lld";
    } else {
        snprintf(target_binary, sizeof(target_binary), "%s/llc_real", lib_llvm);
        argv[0] = "llc";
    }

    execv(target_binary, argv);
    perror("execv");
    return 1;
}
