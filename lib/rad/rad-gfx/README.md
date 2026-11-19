# rad-gfx

Pure-Rad zero-dependency 2D graphics framebuffer, 60 FPS interactive terminal windowing, rasterizer, and image export engine.

## Features

- **TrueColor Rasterization**: Bresenham lines, circles, filled circles, stroked & filled rectangles in 24-bit RGB.
- **60 FPS Interactive Terminal Windowing**: Non-blocking raw keyboard and mouse event polling, half-block subpixel rendering (`▀`), atomic synchronized screen presentation (`\x1b[?2025h`), and seamless terminal teardown.
- **Shooter-Style Movement & Camera Controller (`FpsController`)**:
  - Quake/Source-style ground acceleration & friction braking (stops within ~0.15s without sliding).
  - Zero-drift instant camera look (`vel_turn = target_turn`).
  - Dual-mode input: Kitty progressive enhancement release-event tracking (`EVENT_KEY_UP`) + legacy repeat watchdog.
  - Multi-axis concurrent steering without forward speed starvation.
- **Crisp 1-Cell Native Typography**: 24-bit TrueColor text directly on top of canvas background fills without low-resolution font scaling.
- **Image Exporter**: Binary PPM (P6 Netpbm) export.
- **Zero External Dependencies**: Pure Rad implementation using direct Linux kernel syscalls (`SYS_write`, `SYS_ioctl`, `SYS_nanosleep`).

## Quick Start

```rad
import gfx;

pub fn main() -> i32 {
    var window = Window.open_autores("My Rad App");
    var canvas = Canvas.new(window.width, window.height);

    while window.is_open() {
        while true {
            let ev_opt = window.poll_event();
            match ev_opt {
                Option.Some(ev) => {
                    if ev.is_close() || ev.is_key(113u8) { // 'q'
                        window.close();
                        break;
                    }
                },
                Option.None => { break; },
            }
        }

        canvas.fill(Color.rgb(15u8, 20u8, 30u8));
        canvas.fill_rect(20usize, 10usize, 40usize, 20usize, Color.cyan());
        canvas.draw_text(25usize, 18usize, "Hello, Rad Graphics!", Color.white());

        window.draw_canvas(canvas);
        Window.sleep_frame(60u64);
    }

    canvas.destroy();
    window.destroy();
    return 0;
}
```

## License

MIT
