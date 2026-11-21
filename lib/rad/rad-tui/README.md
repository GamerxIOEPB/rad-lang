# rad-tui

A modern, high-performance, double-buffered Terminal User Interface (TUI) framework written entirely in pure Rad.

## Features

- **Differential Rendering**: Zero screen flicker with diff-based ANSI emission.
- **Terminal Safety**: Hardened lifecycle management with Linux `SYS_rt_sigaction` signal guards, automatic cooked-mode restoration on panic/exit, and alternate screen buffers.
- **Layout Solver**: Declarative constraint-based layout engine (`Fixed`, `Percentage`, `Min`, `Max`, `Ratio`) with automatic resizing.
- **Styling & Colors**: 16 standard ANSI colors, 256-color indexed palette, TrueColor RGB, and text modifiers (`bold`, `dim`, `italic`, `underline`, `reverse`).
- **Widgets**: Blocks with customizable borders (Plain, Rounded, Double, Thick), Paragraphs with text alignment, Buttons, Progress Bars, Lists/Menus, Tables, and Checkboxes.
- **Canvas / Drawing API**: Low-level 2D canvas drawing primitives (`draw_char`, `draw_line`, `draw_rect`, `fill_rect`, `draw_text`) for terminal games and custom visualizations.
- **Zero Dependencies**: Pure native Rad implementation with no external C or third-party dependencies.

## Installation

Add to your project's `rad.toml`:

```toml
[dependencies]
rad-tui = "^0.1.0"
```

Or install via the Rad package manager:

```bash
rad add rad-tui
```

## Quick Example

```rad
import tui;

fn main() -> i32 {
    var app = App.new();
    app.init();

    while app.running() {
        let ev = app.poll_event(50);
        match ev {
            Event.Key(k) => {
                if k == KeyCode.Char(113u32) { // 'q'
                    app.quit();
                }
            },
            _ => {}
        }

        let size = app.size();
        let area = Rect.new(0, 0, size.cols as i32, size.rows as i32);

        let block = Block.new()
            .title(" My Rad Application ")
            .borders(BorderType.Rounded)
            .border_style(Style.default().fg(Color.cyan()));

        app.draw_widget(block, area);
        app.render();
    }

    app.close();
    0
}
```

## License

MIT © 2026 GamerxIOEPB
