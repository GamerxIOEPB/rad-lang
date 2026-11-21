#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <linux/input-event-codes.h>

#include <wayland-client.h>
#include "xdg-shell-client-protocol.h"
#include "font8x16.h"
#include "wayland_native.h"

#define EVENT_RING_CAP 256

struct InputEvent {
    int type;      // 1=close, 2=resize, 3=mouse_down, 4=mouse_up, 5=mouse_move, 6=key_down
    float x;
    float y;
    uint32_t code;
};

struct RadWaylandWindow {
    struct wl_display *display;
    struct wl_registry *registry;
    struct wl_compositor *compositor;
    struct wl_shm *shm;
    struct xdg_wm_base *wm_base;
    struct wl_seat *seat;
    struct wl_pointer *pointer;
    struct wl_keyboard *keyboard;

    struct wl_surface *surface;
    struct xdg_surface *xdg_surface;
    struct xdg_toplevel *xdg_toplevel;

    int width;
    int height;
    int stride;
    int buffer_size;
    int memfd;
    uint32_t *pixels;
    struct wl_shm_pool *pool;
    struct wl_buffer *buffer;

    int configured;
    int running;
    int closed;

    float mouse_x;
    float mouse_y;
    int mouse_down;

    struct InputEvent events[EVENT_RING_CAP];
    int event_head;
    int event_tail;

    struct InputEvent current_event;
};

static void push_event(struct RadWaylandWindow *win, int type, float x, float y, uint32_t code) {
    if (!win) return;
    int next_tail = (win->event_tail + 1) % EVENT_RING_CAP;
    if (next_tail == win->event_head) {
        // Drop oldest event if ring buffer is full
        win->event_head = (win->event_head + 1) % EVENT_RING_CAP;
    }
    win->events[win->event_tail].type = type;
    win->events[win->event_tail].x = x;
    win->events[win->event_tail].y = y;
    win->events[win->event_tail].code = code;
    win->event_tail = next_tail;
}

// ------------------------------------------------------------------------------
// Wayland XDG Shell Listeners
// ------------------------------------------------------------------------------

static void xdg_wm_base_ping_handler(void *data, struct xdg_wm_base *wm_base, uint32_t serial) {
    (void)data;
    xdg_wm_base_pong(wm_base, serial);
}

static const struct xdg_wm_base_listener wm_base_listener = {
    .ping = xdg_wm_base_ping_handler,
};

static void xdg_surface_configure_handler(void *data, struct xdg_surface *xdg_surface, uint32_t serial) {
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    xdg_surface_ack_configure(xdg_surface, serial);
    win->configured = 1;
}

static const struct xdg_surface_listener xdg_surface_listener = {
    .configure = xdg_surface_configure_handler,
};

static void xdg_toplevel_configure_handler(void *data, struct xdg_toplevel *xdg_toplevel,
                                          int32_t width, int32_t height, struct wl_array *states) {
    (void)data;
    (void)xdg_toplevel;
    (void)width;
    (void)height;
    (void)states;
}

static void xdg_toplevel_close_handler(void *data, struct xdg_toplevel *xdg_toplevel) {
    (void)xdg_toplevel;
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    win->running = 0;
    win->closed = 1;
    push_event(win, 1 /* WINDOW_EVENT_CLOSE */, 0.0f, 0.0f, 0);
}

static const struct xdg_toplevel_listener xdg_toplevel_listener = {
    .configure = xdg_toplevel_configure_handler,
    .close = xdg_toplevel_close_handler,
};

// ------------------------------------------------------------------------------
// Wayland Input Listeners (Pointer & Keyboard)
// ------------------------------------------------------------------------------

static void pointer_enter(void *data, struct wl_pointer *pointer, uint32_t serial,
                          struct wl_surface *surface, wl_fixed_t sx, wl_fixed_t sy) {
    (void)pointer;
    (void)serial;
    (void)surface;
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    win->mouse_x = (float)wl_fixed_to_double(sx);
    win->mouse_y = (float)wl_fixed_to_double(sy);
    push_event(win, 5 /* MOUSE_MOVE */, win->mouse_x, win->mouse_y, 0);
}

static void pointer_leave(void *data, struct wl_pointer *pointer, uint32_t serial,
                          struct wl_surface *surface) {
    (void)data;
    (void)pointer;
    (void)serial;
    (void)surface;
}

static void pointer_motion(void *data, struct wl_pointer *pointer, uint32_t time,
                           wl_fixed_t sx, wl_fixed_t sy) {
    (void)pointer;
    (void)time;
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    win->mouse_x = (float)wl_fixed_to_double(sx);
    win->mouse_y = (float)wl_fixed_to_double(sy);
    push_event(win, 5 /* MOUSE_MOVE */, win->mouse_x, win->mouse_y, 0);
}

static void pointer_button(void *data, struct wl_pointer *pointer, uint32_t serial,
                           uint32_t time, uint32_t button, uint32_t state) {
    (void)pointer;
    (void)serial;
    (void)time;
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    if (button == BTN_LEFT) {
        if (state == 1) { // Pressed
            win->mouse_down = 1;
            push_event(win, 3 /* MOUSE_DOWN */, win->mouse_x, win->mouse_y, button);
        } else { // Released
            win->mouse_down = 0;
            push_event(win, 4 /* MOUSE_UP */, win->mouse_x, win->mouse_y, button);
        }
    }
}

static void pointer_axis(void *data, struct wl_pointer *pointer, uint32_t time,
                         uint32_t axis, wl_fixed_t value) {
    (void)data; (void)pointer; (void)time; (void)axis; (void)value;
}
static void pointer_frame(void *data, struct wl_pointer *pointer) {
    (void)data; (void)pointer;
}
static void pointer_axis_source(void *data, struct wl_pointer *pointer, uint32_t axis_source) {
    (void)data; (void)pointer; (void)axis_source;
}
static void pointer_axis_stop(void *data, struct wl_pointer *pointer, uint32_t time, uint32_t axis) {
    (void)data; (void)pointer; (void)time; (void)axis;
}
static void pointer_axis_discrete(void *data, struct wl_pointer *pointer, uint32_t axis, int32_t discrete) {
    (void)data; (void)pointer; (void)axis; (void)discrete;
}
static void pointer_axis_value120(void *data, struct wl_pointer *pointer, uint32_t axis, int32_t value120) {
    (void)data; (void)pointer; (void)axis; (void)value120;
}
static void pointer_axis_relative_direction(void *data, struct wl_pointer *pointer, uint32_t axis, uint32_t direction) {
    (void)data; (void)pointer; (void)axis; (void)direction;
}
static void pointer_warp(void *data, struct wl_pointer *pointer, wl_fixed_t sx, wl_fixed_t sy) {
    (void)data; (void)pointer; (void)sx; (void)sy;
}

static const struct wl_pointer_listener pointer_listener = {
    .enter = pointer_enter,
    .leave = pointer_leave,
    .motion = pointer_motion,
    .button = pointer_button,
    .axis = pointer_axis,
    .frame = pointer_frame,
    .axis_source = pointer_axis_source,
    .axis_stop = pointer_axis_stop,
    .axis_discrete = pointer_axis_discrete,
    .axis_value120 = pointer_axis_value120,
    .axis_relative_direction = pointer_axis_relative_direction,
    .warp = pointer_warp,
};

static void keyboard_keymap(void *data, struct wl_keyboard *keyboard, uint32_t format, int32_t fd, uint32_t size) {
    (void)data; (void)keyboard; (void)format; (void)size;
    close(fd);
}
static void keyboard_enter(void *data, struct wl_keyboard *keyboard, uint32_t serial,
                           struct wl_surface *surface, struct wl_array *keys) {
    (void)data; (void)keyboard; (void)serial; (void)surface; (void)keys;
}
static void keyboard_leave(void *data, struct wl_keyboard *keyboard, uint32_t serial,
                           struct wl_surface *surface) {
    (void)data; (void)keyboard; (void)serial; (void)surface;
}
static void keyboard_key(void *data, struct wl_keyboard *keyboard, uint32_t serial,
                         uint32_t time, uint32_t key, uint32_t state) {
    (void)keyboard; (void)serial; (void)time;
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    if (state == 1) { // Pressed
        push_event(win, 6 /* KEY_DOWN */, win->mouse_x, win->mouse_y, key);
        if (key == KEY_ESC || key == KEY_Q) {
            push_event(win, 1 /* CLOSE */, 0.0f, 0.0f, 0);
            win->running = 0;
            win->closed = 1;
        }
    }
}
static void keyboard_modifiers(void *data, struct wl_keyboard *keyboard, uint32_t serial,
                               uint32_t mods_depressed, uint32_t mods_latched,
                               uint32_t mods_locked, uint32_t group) {
    (void)data; (void)keyboard; (void)serial; (void)mods_depressed; (void)mods_latched; (void)mods_locked; (void)group;
}
static void keyboard_repeat_info(void *data, struct wl_keyboard *keyboard, int32_t rate, int32_t delay) {
    (void)data; (void)keyboard; (void)rate; (void)delay;
}

static const struct wl_keyboard_listener keyboard_listener = {
    .keymap = keyboard_keymap,
    .enter = keyboard_enter,
    .leave = keyboard_leave,
    .key = keyboard_key,
    .modifiers = keyboard_modifiers,
    .repeat_info = keyboard_repeat_info,
};

static void seat_handle_capabilities(void *data, struct wl_seat *seat, uint32_t caps) {
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    if ((caps & WL_SEAT_CAPABILITY_POINTER) && !win->pointer) {
        win->pointer = wl_seat_get_pointer(seat);
        wl_pointer_add_listener(win->pointer, &pointer_listener, win);
    } else if (!(caps & WL_SEAT_CAPABILITY_POINTER) && win->pointer) {
        wl_pointer_destroy(win->pointer);
        win->pointer = NULL;
    }

    if ((caps & WL_SEAT_CAPABILITY_KEYBOARD) && !win->keyboard) {
        win->keyboard = wl_seat_get_keyboard(seat);
        wl_keyboard_add_listener(win->keyboard, &keyboard_listener, win);
    } else if (!(caps & WL_SEAT_CAPABILITY_KEYBOARD) && win->keyboard) {
        wl_keyboard_destroy(win->keyboard);
        win->keyboard = NULL;
    }
}

static void seat_handle_name(void *data, struct wl_seat *seat, const char *name) {
    (void)data; (void)seat; (void)name;
}

static const struct wl_seat_listener seat_listener = {
    .capabilities = seat_handle_capabilities,
    .name = seat_handle_name,
};

// ------------------------------------------------------------------------------
// Wayland Registry Listener
// ------------------------------------------------------------------------------

static void registry_handle_global(void *data, struct wl_registry *registry,
                                   uint32_t name, const char *interface, uint32_t version) {
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)data;
    if (strcmp(interface, wl_compositor_interface.name) == 0) {
        win->compositor = (struct wl_compositor *)wl_registry_bind(registry, name, &wl_compositor_interface, 4);
    } else if (strcmp(interface, wl_shm_interface.name) == 0) {
        win->shm = (struct wl_shm *)wl_registry_bind(registry, name, &wl_shm_interface, 1);
    } else if (strcmp(interface, xdg_wm_base_interface.name) == 0) {
        win->wm_base = (struct xdg_wm_base *)wl_registry_bind(registry, name, &xdg_wm_base_interface, 1);
        xdg_wm_base_add_listener(win->wm_base, &wm_base_listener, win);
    } else if (strcmp(interface, wl_seat_interface.name) == 0) {
        win->seat = (struct wl_seat *)wl_registry_bind(registry, name, &wl_seat_interface, version >= 7 ? 7 : version);
        wl_seat_add_listener(win->seat, &seat_listener, win);
    }
}

static void registry_handle_global_remove(void *data, struct wl_registry *registry, uint32_t name) {
    (void)data; (void)registry; (void)name;
}

static const struct wl_registry_listener registry_listener = {
    .global = registry_handle_global,
    .global_remove = registry_handle_global_remove,
};

// ------------------------------------------------------------------------------
// Window Lifecycle Implementation
// ------------------------------------------------------------------------------

struct RadWaylandWindow* rad_wayland_init(const char* title, int width, int height) {
    struct RadWaylandWindow *win = (struct RadWaylandWindow *)calloc(1, sizeof(struct RadWaylandWindow));
    if (!win) return NULL;

    win->width = width;
    win->height = height;
    win->stride = width * 4;
    win->buffer_size = win->stride * height;
    win->running = 1;

    win->display = wl_display_connect(NULL);
    if (!win->display) {
        free(win);
        return NULL;
    }

    win->registry = wl_display_get_registry(win->display);
    wl_registry_add_listener(win->registry, &registry_listener, win);

    // Initial roundtrip to discover globals
    wl_display_roundtrip(win->display);

    if (!win->compositor || !win->shm || !win->wm_base) {
        wl_display_disconnect(win->display);
        free(win);
        return NULL;
    }

    // Allocate SHM buffer
    win->memfd = memfd_create("rad-wayland-gui-shm", MFD_CLOEXEC);
    if (win->memfd < 0) {
        wl_display_disconnect(win->display);
        free(win);
        return NULL;
    }
    if (ftruncate(win->memfd, win->buffer_size) < 0) {
        close(win->memfd);
        wl_display_disconnect(win->display);
        free(win);
        return NULL;
    }
    win->pixels = (uint32_t*)mmap(NULL, win->buffer_size, PROT_READ | PROT_WRITE, MAP_SHARED, win->memfd, 0);
    if (win->pixels == MAP_FAILED) {
        close(win->memfd);
        wl_display_disconnect(win->display);
        free(win);
        return NULL;
    }

    win->pool = wl_shm_create_pool(win->shm, win->memfd, win->buffer_size);
    win->buffer = wl_shm_pool_create_buffer(win->pool, 0, win->width, win->height, win->stride, WL_SHM_FORMAT_XRGB8888);

    // Create surface and xdg shell toplevel
    win->surface = wl_compositor_create_surface(win->compositor);
    win->xdg_surface = xdg_wm_base_get_xdg_surface(win->wm_base, win->surface);
    xdg_surface_add_listener(win->xdg_surface, &xdg_surface_listener, win);

    win->xdg_toplevel = xdg_surface_get_toplevel(win->xdg_surface);
    xdg_toplevel_add_listener(win->xdg_toplevel, &xdg_toplevel_listener, win);

    if (title && strlen(title) > 0) {
        xdg_toplevel_set_title(win->xdg_toplevel, title);
    }
    xdg_toplevel_set_app_id(win->xdg_toplevel, "rad.wayland.gui");

    // Commit empty surface to prompt compositor to send initial configure event
    wl_surface_commit(win->surface);

    // Wait until configured
    while (!win->configured && win->running) {
        if (wl_display_dispatch(win->display) < 0) {
            win->running = 0;
            break;
        }
    }

    // Initial commit of buffer
    wl_surface_attach(win->surface, win->buffer, 0, 0);
    wl_surface_damage_buffer(win->surface, 0, 0, win->width, win->height);
    wl_surface_commit(win->surface);
    wl_display_flush(win->display);

    return win;
}

int rad_wayland_poll_events(struct RadWaylandWindow* win) {
    if (!win || !win->running) return -1;
    wl_display_flush(win->display);

    if (wl_display_prepare_read(win->display) == 0) {
        struct pollfd pfd = { .fd = wl_display_get_fd(win->display), .events = POLLIN };
        if (poll(&pfd, 1, 0) > 0) {
            wl_display_read_events(win->display);
        } else {
            wl_display_cancel_read(win->display);
        }
    }

    if (wl_display_dispatch_pending(win->display) < 0) {
        win->running = 0;
        return -1;
    }
    return 0;
}

int rad_wayland_is_open(struct RadWaylandWindow* win) {
    return (win && win->running && !win->closed) ? 1 : 0;
}

void rad_wayland_close(struct RadWaylandWindow* win) {
    if (win) {
        win->running = 0;
        win->closed = 1;
    }
}

void rad_wayland_destroy(struct RadWaylandWindow* win) {
    if (!win) return;
    if (win->pixels && win->pixels != MAP_FAILED) {
        munmap(win->pixels, win->buffer_size);
    }
    if (win->memfd >= 0) {
        close(win->memfd);
    }
    if (win->buffer) wl_buffer_destroy(win->buffer);
    if (win->pool) wl_shm_pool_destroy(win->pool);
    if (win->xdg_toplevel) xdg_toplevel_destroy(win->xdg_toplevel);
    if (win->xdg_surface) xdg_surface_destroy(win->xdg_surface);
    if (win->surface) wl_surface_destroy(win->surface);
    if (win->pointer) wl_pointer_destroy(win->pointer);
    if (win->keyboard) wl_keyboard_destroy(win->keyboard);
    if (win->seat) wl_seat_destroy(win->seat);
    if (win->wm_base) xdg_wm_base_destroy(win->wm_base);
    if (win->shm) wl_shm_destroy(win->shm);
    if (win->compositor) wl_compositor_destroy(win->compositor);
    if (win->registry) wl_registry_destroy(win->registry);
    if (win->display) wl_display_disconnect(win->display);
    free(win);
}

uint32_t* rad_wayland_get_buffer(struct RadWaylandWindow* win) {
    return win ? win->pixels : NULL;
}

int rad_wayland_get_width(struct RadWaylandWindow* win) {
    return win ? win->width : 0;
}

int rad_wayland_get_height(struct RadWaylandWindow* win) {
    return win ? win->height : 0;
}

void rad_wayland_commit(struct RadWaylandWindow* win) {
    if (!win || !win->running) return;
    wl_surface_attach(win->surface, win->buffer, 0, 0);
    wl_surface_damage_buffer(win->surface, 0, 0, win->width, win->height);
    wl_surface_commit(win->surface);
    wl_display_flush(win->display);
}

int rad_wayland_poll_event(struct RadWaylandWindow* win) {
    if (!win || win->event_head == win->event_tail) {
        return 0;
    }
    win->current_event = win->events[win->event_head];
    win->event_head = (win->event_head + 1) % EVENT_RING_CAP;
    return 1;
}

int rad_wayland_event_type(struct RadWaylandWindow* win) {
    return win ? win->current_event.type : 0;
}

float rad_wayland_event_x(struct RadWaylandWindow* win) {
    return win ? win->current_event.x : 0.0f;
}

float rad_wayland_event_y(struct RadWaylandWindow* win) {
    return win ? win->current_event.y : 0.0f;
}

uint32_t rad_wayland_event_code(struct RadWaylandWindow* win) {
    return win ? win->current_event.code : 0u;
}

float rad_wayland_mouse_x(struct RadWaylandWindow* win) {
    return win ? win->mouse_x : 0.0f;
}

float rad_wayland_mouse_y(struct RadWaylandWindow* win) {
    return win ? win->mouse_y : 0.0f;
}

int rad_wayland_mouse_down(struct RadWaylandWindow* win) {
    return win ? win->mouse_down : 0;
}

// ------------------------------------------------------------------------------
// Software Rasterizer Primitives
// ------------------------------------------------------------------------------

void rad_wayland_clear(struct RadWaylandWindow* win, uint32_t color) {
    if (!win || !win->pixels) return;
    int count = win->width * win->height;
    for (int i = 0; i < count; i++) {
        win->pixels[i] = color;
    }
}

void rad_wayland_draw_rect(struct RadWaylandWindow* win, int x, int y, int w, int h, uint32_t color) {
    if (!win || !win->pixels || w <= 0 || h <= 0) return;
    int x0 = x < 0 ? 0 : x;
    int y0 = y < 0 ? 0 : y;
    int x1 = (x + w > win->width) ? win->width : x + w;
    int y1 = (y + h > win->height) ? win->height : y + h;

    for (int r = y0; r < y1; r++) {
        uint32_t *line = &win->pixels[r * win->width];
        for (int c = x0; c < x1; c++) {
            line[c] = color;
        }
    }
}

void rad_wayland_draw_rect_outline(struct RadWaylandWindow* win, int x, int y, int w, int h, int border_width, uint32_t color) {
    if (!win || !win->pixels || w <= 0 || h <= 0 || border_width <= 0) return;
    // Top
    rad_wayland_draw_rect(win, x, y, w, border_width, color);
    // Bottom
    rad_wayland_draw_rect(win, x, y + h - border_width, w, border_width, color);
    // Left
    rad_wayland_draw_rect(win, x, y + border_width, border_width, h - 2 * border_width, color);
    // Right
    rad_wayland_draw_rect(win, x + w - border_width, y + border_width, border_width, h - 2 * border_width, color);
}

void rad_wayland_draw_rect_rounded(struct RadWaylandWindow* win, int x, int y, int w, int h, int radius, uint32_t color) {
    if (!win || !win->pixels || w <= 0 || h <= 0) return;
    if (radius <= 0) {
        rad_wayland_draw_rect(win, x, y, w, h, color);
        return;
    }
    if (radius > w / 2) radius = w / 2;
    if (radius > h / 2) radius = h / 2;

    int r2 = radius * radius;

    // Center vertical strip
    rad_wayland_draw_rect(win, x, y + radius, w, h - 2 * radius, color);
    // Top and bottom horizontal strips (between corner boxes)
    rad_wayland_draw_rect(win, x + radius, y, w - 2 * radius, radius, color);
    rad_wayland_draw_rect(win, x + radius, y + h - radius, w - 2 * radius, radius, color);

    // 4 Rounded corners
    int cx[4] = { x + radius, x + w - radius - 1, x + radius, x + w - radius - 1 };
    int cy[4] = { y + radius, y + radius, y + h - radius - 1, y + h - radius - 1 };

    for (int dy = 0; dy < radius; dy++) {
        for (int dx = 0; dx < radius; dx++) {
            int d2 = (radius - 1 - dx) * (radius - 1 - dx) + (radius - 1 - dy) * (radius - 1 - dy);
            if (d2 <= r2) {
                // Top-left
                int px0 = cx[0] - radius + dx;
                int py0 = cy[0] - radius + dy;
                if (px0 >= 0 && px0 < win->width && py0 >= 0 && py0 < win->height)
                    win->pixels[py0 * win->width + px0] = color;

                // Top-right
                int px1 = cx[1] + (radius - 1 - dx);
                int py1 = cy[1] - radius + dy;
                if (px1 >= 0 && px1 < win->width && py1 >= 0 && py1 < win->height)
                    win->pixels[py1 * win->width + px1] = color;

                // Bottom-left
                int px2 = cx[2] - radius + dx;
                int py2 = cy[2] + (radius - 1 - dy);
                if (px2 >= 0 && px2 < win->width && py2 >= 0 && py2 < win->height)
                    win->pixels[py2 * win->width + px2] = color;

                // Bottom-right
                int px3 = cx[3] + (radius - 1 - dx);
                int py3 = cy[3] + (radius - 1 - dy);
                if (px3 >= 0 && px3 < win->width && py3 >= 0 && py3 < win->height)
                    win->pixels[py3 * win->width + px3] = color;
            }
        }
    }
}

void rad_wayland_draw_circle(struct RadWaylandWindow* win, int cx, int cy, int radius, uint32_t color) {
    if (!win || !win->pixels || radius <= 0) return;
    int r2 = radius * radius;
    int y0 = cy - radius < 0 ? 0 : cy - radius;
    int y1 = cy + radius >= win->height ? win->height - 1 : cy + radius;

    for (int y = y0; y <= y1; y++) {
        int dy = y - cy;
        int dx = 0;
        while (dx <= radius && (dx * dx + dy * dy) <= r2) {
            dx++;
        }
        dx--;
        int x0 = cx - dx < 0 ? 0 : cx - dx;
        int x1 = cx + dx >= win->width ? win->width - 1 : cx + dx;
        uint32_t *line = &win->pixels[y * win->width];
        for (int x = x0; x <= x1; x++) {
            line[x] = color;
        }
    }
}

void rad_wayland_draw_text(struct RadWaylandWindow* win, int x, int y, const char* text, uint32_t color, int scale) {
    if (!win || !win->pixels || !text) return;
    if (scale <= 0) scale = 1;

    int cur_x = x;
    int cur_y = y;

    for (int i = 0; text[i] != '\0'; i++) {
        unsigned char c = (unsigned char)text[i];
        if (c == '\n') {
            cur_x = x;
            cur_y += 18 * scale;
            continue;
        }

        const uint8_t *glyph = font8x16_data[c];
        for (int row = 0; row < 16; row++) {
            uint8_t bits = glyph[row];
            int py = cur_y + row * scale;
            if (py >= win->height) break;
            if (py + scale <= 0) continue;

            for (int col = 0; col < 8; col++) {
                if (bits & (0x80 >> col)) {
                    int px = cur_x + col * scale;
                    if (px >= win->width) break;
                    if (px + scale <= 0) continue;

                    if (scale == 1) {
                        if (px >= 0 && px < win->width && py >= 0 && py < win->height) {
                            win->pixels[py * win->width + px] = color;
                        }
                    } else {
                        rad_wayland_draw_rect(win, px, py, scale, scale, color);
                    }
                }
            }
        }
        cur_x += 8 * scale;
    }
}

int rad_wayland_text_width(const char* text, int scale) {
    if (!text) return 0;
    if (scale <= 0) scale = 1;
    return (int)strlen(text) * 8 * scale;
}

int rad_wayland_i64_width(int64_t val, int scale) {
    char buf[64];
    snprintf(buf, sizeof(buf), "%ld", (long)val);
    return rad_wayland_text_width(buf, scale);
}

void rad_wayland_draw_i64(struct RadWaylandWindow* win, int x, int y, int64_t val, uint32_t color, int scale) {
    char buf[64];
    snprintf(buf, sizeof(buf), "%ld", (long)val);
    rad_wayland_draw_text(win, x, y, buf, color, scale);
}

void rad_wayland_draw_formatted(struct RadWaylandWindow* win, int x, int y, const char* prefix, int64_t val, const char* suffix, uint32_t color, int scale) {
    char buf[128];
    snprintf(buf, sizeof(buf), "%s%ld%s", prefix ? prefix : "", (long)val, suffix ? suffix : "");
    rad_wayland_draw_text(win, x, y, buf, color, scale);
}

void rad_wayland_draw_xy(struct RadWaylandWindow* win, int x, int y, const char* prefix, int64_t val_x, int64_t val_y, uint32_t color, int scale) {
    char buf[128];
    snprintf(buf, sizeof(buf), "%sX = %ld, Y = %ld px", prefix ? prefix : "", (long)val_x, (long)val_y);
    rad_wayland_draw_text(win, x, y, buf, color, scale);
}

int rad_wayland_save_bmp(struct RadWaylandWindow* win, const char* filename) {
    if (!win || !win->pixels || !filename) return -1;
    FILE *fp = fopen(filename, "wb");
    if (!fp) return -1;

    int w = win->width;
    int h = win->height;
    int row_size = w * 4;
    int image_size = row_size * h;
    int file_size = 54 + image_size;

    // BMP Header (14 bytes)
    uint8_t bmp_hdr[14] = {
        'B', 'M',
        (uint8_t)(file_size & 0xFF), (uint8_t)((file_size >> 8) & 0xFF), (uint8_t)((file_size >> 16) & 0xFF), (uint8_t)((file_size >> 24) & 0xFF),
        0, 0, 0, 0,
        54, 0, 0, 0
    };
    fwrite(bmp_hdr, 1, 14, fp);

    // DIB Header (BITMAPINFOHEADER, 40 bytes)
    // Negative height means top-down bitmap
    int32_t neg_h = -h;
    uint8_t dib_hdr[40] = {
        40, 0, 0, 0,
        (uint8_t)(w & 0xFF), (uint8_t)((w >> 8) & 0xFF), (uint8_t)((w >> 16) & 0xFF), (uint8_t)((w >> 24) & 0xFF),
        (uint8_t)(neg_h & 0xFF), (uint8_t)((neg_h >> 8) & 0xFF), (uint8_t)((neg_h >> 16) & 0xFF), (uint8_t)((neg_h >> 24) & 0xFF),
        1, 0,
        32, 0,
        0, 0, 0, 0,
        (uint8_t)(image_size & 0xFF), (uint8_t)((image_size >> 8) & 0xFF), (uint8_t)((image_size >> 16) & 0xFF), (uint8_t)((image_size >> 24) & 0xFF),
        0x13, 0x0B, 0, 0,
        0x13, 0x0B, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0
    };
    fwrite(dib_hdr, 1, 40, fp);

    // Pixel data
    fwrite(win->pixels, 4, w * h, fp);
    fclose(fp);
    return 0;
}


