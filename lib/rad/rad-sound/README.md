# rad-sound

Pure-Rad native PCM audio synthesis engine, procedural waveform oscillators, retro sound generators, and WAV container exporter.

## Features

- **Pure Native Audio Engine**: 16-bit 44.1kHz mono PCM buffer manipulation with zero external dynamic C library dependencies.
- **Procedural Oscillators**: Sine wave, square wave (with customizable duty cycle), triangle wave, sawtooth wave, and white noise.
- **Envelope Shaping**: Linear attack, decay, sustain, release (ADSR) amplitude modulation.
- **Retro Game Sound Synthesizers**:
  - Jump bleeps (exponential pitch sweeps up)
  - Laser zaps (exponential pitch sweeps down)
  - Explosions (filtered noise sweeps)
  - Coin chimes (two-tone melodic blips)
  - Hurt / hit grunts
  - Powerup fanfare
- **Audio File Export**: Generates compliant standard RIFF/WAVE PCM container files (`export_wav`) for playback in any media player.
- **Real-Time Playback**: Direct playback support via `/dev/dsp` or native POSIX pipes to local sound daemons.

## Quick Start

```rad
import sound;

pub fn main() -> i32 {
    var engine = SoundEngine.new(44100u32);

    // Synthesize retro laser sound effect
    var buf = engine.gen_laser(880.0, 110.0, 0.2);

    // Save to WAV file
    buf.save_wav("laser.wav");
    buf.destroy();
    return 0;
}
```

## License

MIT
