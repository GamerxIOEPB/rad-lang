#ifndef WAYLAND_NATIVE_H
#define WAYLAND_NATIVE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct RadWaylandWindow;

// Window lifecycle
struct RadWaylandWindow* rad_wayland_init(const char* title, int width, int height);
int rad_wayland_poll_events(struct RadWaylandWindow* win);
int rad_wayland_is_open(struct RadWaylandWindow* win);
void rad_wayland_close(struct RadWaylandWindow* win);
void rad_wayland_destroy(struct RadWaylandWindow* win);

// Buffer management
uint32_t* rad_wayland_get_buffer(struct RadWaylandWindow* win);
int rad_wayland_get_width(struct RadWaylandWindow* win);
int rad_wayland_get_height(struct RadWaylandWindow* win);
void rad_wayland_commit(struct RadWaylandWindow* win);

// Event polling (ring-buffer event queue)
// rad_wayland_poll_event pops the next event into internal slot. Returns 1 if event popped, 0 if empty.
int rad_wayland_poll_event(struct RadWaylandWindow* win);
// Event type: 0=NONE, 1=CLOSE, 2=RESIZE, 3=MOUSE_DOWN, 4=MOUSE_UP, 5=MOUSE_MOVE, 6=KEY_DOWN
int rad_wayland_event_type(struct RadWaylandWindow* win);
float rad_wayland_event_x(struct RadWaylandWindow* win);
float rad_wayland_event_y(struct RadWaylandWindow* win);
uint32_t rad_wayland_event_code(struct RadWaylandWindow* win);

// Direct state queries
float rad_wayland_mouse_x(struct RadWaylandWindow* win);
float rad_wayland_mouse_y(struct RadWaylandWindow* win);
int rad_wayland_mouse_down(struct RadWaylandWindow* win);

// Fast software rasterizer primitives
void rad_wayland_clear(struct RadWaylandWindow* win, uint32_t color);
void rad_wayland_draw_rect(struct RadWaylandWindow* win, int x, int y, int w, int h, uint32_t color);
void rad_wayland_draw_rect_outline(struct RadWaylandWindow* win, int x, int y, int w, int h, int border_width, uint32_t color);
void rad_wayland_draw_rect_rounded(struct RadWaylandWindow* win, int x, int y, int w, int h, int radius, uint32_t color);
void rad_wayland_draw_text(struct RadWaylandWindow* win, int x, int y, const char* text, uint32_t color, int scale);
void rad_wayland_draw_circle(struct RadWaylandWindow* win, int cx, int cy, int radius, uint32_t color);

// Text metrics and formatted text helpers
int rad_wayland_text_width(const char* text, int scale);
int rad_wayland_i64_width(int64_t val, int scale);
void rad_wayland_draw_i64(struct RadWaylandWindow* win, int x, int y, int64_t val, uint32_t color, int scale);
void rad_wayland_draw_formatted(struct RadWaylandWindow* win, int x, int y, const char* prefix, int64_t val, const char* suffix, uint32_t color, int scale);
void rad_wayland_draw_xy(struct RadWaylandWindow* win, int x, int y, const char* prefix, int64_t val_x, int64_t val_y, uint32_t color, int scale);
int rad_wayland_save_bmp(struct RadWaylandWindow* win, const char* filename);

#ifdef __cplusplus
}
#endif

#endif // WAYLAND_NATIVE_H
