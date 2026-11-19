# rad-gui

Immediate-Mode Graphical User Interface (IMGUI) toolkit built on top of `rad-gfx`.

## Features

- **Immediate-Mode Design**: Zero retained widget trees; widgets declare behavior and rendering in a single pass (`gui.button(...)`, `gui.slider_i64(...)`).
- **Comprehensive Widget Library**:
  - `button`: Push button with hover, active, and focus visual states.
  - `checkbox`: Binary toggle with accent indicator.
  - `slider_i64` / `slider_f64`: Interactive draggable sliders with value bounds and formatted labels.
  - `text_input`: Editable text field with cursor blinking, printable ASCII input, and backspace.
  - `panel`: Static containers with framed borders and title headers.
  - `draggable_window`: Floating dialog windows draggable across the screen with title bars.
- **Crisp 1-Cell Typography**: Native 1-character resolution text aligned with half-block graphical backgrounds.
- **Theming**: Easily customizable color palettes via `GuiTheme` (`cyber`, `amber`, `dracula`, `monokai`, `light`).
- **Input Dispatch**: Integrated mouse hit-testing, active widget tracking, and keyboard focus management.

## Quick Start

```rad
import gfx;
import gui;

pub fn main() -> i32 {
    var window = Window.open_autores("GUI Demo");
    var canvas = Canvas.new(window.width, window.height);
    var gui = GuiContext.new(GuiTheme.cyber());
    var counter: i64 = 0;

    while window.is_open() {
        gui.begin_frame();
        while true {
            let ev_opt = window.poll_event();
            match ev_opt {
                Option.Some(ev) => {
                    gui.handle_event(ev);
                    if ev.is_close() || ev.is_key(113u8) { window.close(); break; }
                },
                Option.None => { break; },
            }
        }

        canvas.fill(Color.rgb(18u8, 22u8, 30u8));
        gui.panel(canvas, "Counter Panel", 5usize, 2usize, 40usize, 18usize);
        if gui.button(canvas, 1usize, "Increment", 10usize, 6usize, 16usize, 4usize) {
            counter = counter + 1;
        }

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
