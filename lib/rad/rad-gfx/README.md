# rad-gfx

Zero-dependency 2D graphics framebuffer, rasterizer, and image export engine for Rad.

## Features
- **Fast 2D Rasterization**: Bresenham lines, circles, filled circles, stroked & filled rectangles.
- **TrueColor Framebuffer**: 32-bit RGBA pixel grid.
- **Image Exporter**: Direct output to binary PPM (P6 Netpbm) for instant viewing in image viewers and web browsers.
- **Zero Dependencies**: Pure Rad implementation using direct Linux kernel syscalls for I/O.

## Usage
```rad
import rad_gfx

fn main() -> i32 {
    var canvas = Canvas.new(640usize, 480usize)
    canvas.clear(Color.rgb(20u8, 20u8, 30u8)) // Dark blue background

    // Draw geometries
    canvas.fill_circle(320i64, 240i64, 100i64, Color.yellow())
    canvas.draw_circle(320i64, 240i64, 120i64, Color.white())
    canvas.draw_line(0i64, 0i64, 640i64, 480i64, Color.cyan())
    canvas.fill_rect(50usize, 50usize, 120usize, 80usize, Color.red())

    canvas.save_ppm("demo.ppm")
    canvas.destroy()
    return 0
}
```
