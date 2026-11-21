#pragma once

#ifdef __cplusplus
extern "C" {
#endif

// Install LLVM's process-level fatal-signal handler and Rad-specific ICE banner.
void rad_install_crash_reporting(void);

#ifdef __cplusplus
}
#endif
