#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <wchar.h>

char __libc_single_threaded = 1;

void *__memcpy_chk(void *dest, const void *src, size_t len, size_t destlen) {
    return memcpy(dest, src, len);
}

void *__memmove_chk(void *dest, const void *src, size_t len, size_t destlen) {
    return memmove(dest, src, len);
}

void *__memset_chk(void *dest, int c, size_t len, size_t destlen) {
    return memset(dest, c, len);
}

wchar_t *__wmemcpy_chk(wchar_t *dest, const wchar_t *src, size_t n, size_t destlen) {
    return wmemcpy(dest, src, n);
}

wchar_t *__wmemmove_chk(wchar_t *dest, const wchar_t *src, size_t n, size_t destlen) {
    return wmemmove(dest, src, n);
}

wchar_t *__wmemset_chk(wchar_t *dest, wchar_t c, size_t n, size_t destlen) {
    return wmemset(dest, c, n);
}

size_t __mbsrtowcs_chk(wchar_t *dest, const char **src, size_t len, mbstate_t *ps, size_t destlen) {
    return mbsrtowcs(dest, src, len, ps);
}

char *__strcpy_chk(char *dest, const char *src, size_t destlen) {
    return strcpy(dest, src);
}

char *__strncpy_chk(char *dest, const char *src, size_t n, size_t destlen) {
    return strncpy(dest, src, n);
}

char *__strcat_chk(char *dest, const char *src, size_t destlen) {
    return strcat(dest, src);
}

char *__strncat_chk(char *dest, const char *src, size_t n, size_t destlen) {
    return strncat(dest, src, n);
}

int __sprintf_chk(char *s, int flag, size_t slen, const char *format, ...) {
    va_list ap;
    va_start(ap, format);
    int ret = vsprintf(s, format, ap);
    va_end(ap);
    return ret;
}

int __snprintf_chk(char *s, size_t maxlen, int flag, size_t slen, const char *format, ...) {
    va_list ap;
    va_start(ap, format);
    int ret = vsnprintf(s, maxlen, format, ap);
    va_end(ap);
    return ret;
}

int __vsprintf_chk(char *s, int flag, size_t slen, const char *format, va_list ap) {
    return vsprintf(s, format, ap);
}

int __vsnprintf_chk(char *s, size_t maxlen, int flag, size_t slen, const char *format, va_list ap) {
    return vsnprintf(s, maxlen, format, ap);
}

int __fprintf_chk(FILE *fp, int flag, const char *format, ...) {
    va_list ap;
    va_start(ap, format);
    int ret = vfprintf(fp, format, ap);
    va_end(ap);
    return ret;
}

int __vfprintf_chk(FILE *fp, int flag, const char *format, va_list ap) {
    return vfprintf(fp, format, ap);
}

int __printf_chk(int flag, const char *format, ...) {
    va_list ap;
    va_start(ap, format);
    int ret = vprintf(format, ap);
    va_end(ap);
    return ret;
}

ssize_t __read_chk(int fd, void *buf, size_t nbytes, size_t buflen) {
    return read(fd, buf, nbytes);
}

long __isoc23_strtol(const char *nptr, char **endptr, int base) {
    return strtol(nptr, endptr, base);
}

unsigned long __isoc23_strtoul(const char *nptr, char **endptr, int base) {
    return strtoul(nptr, endptr, base);
}

long long __isoc23_strtoll(const char *nptr, char **endptr, int base) {
    return strtoll(nptr, endptr, base);
}

unsigned long long __isoc23_strtoull(const char *nptr, char **endptr, int base) {
    return strtoull(nptr, endptr, base);
}

float __isoc23_strtof(const char *nptr, char **endptr) {
    return strtof(nptr, endptr);
}

double __isoc23_strtod(const char *nptr, char **endptr) {
    return strtod(nptr, endptr);
}

uint32_t arc4random(void) {
    return (uint32_t)rand();
}
