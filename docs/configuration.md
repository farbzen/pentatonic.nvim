# Configuration

All options of `require("pentatonic").setup()` with their defaults:

```lua
require("pentatonic").setup({
  enabled = true,
  trigger = "insert",
  scale = "pentatonic",
  volume = 0.15,
  volume_step = 0.05,
  max_voices = 16,
  player = nil,
  filetypes_exclude = { "TelescopePrompt" },
})
```

| Option | Type | Description |
| --- | --- | --- |
| `enabled` | boolean | Start playing right after `setup()`. |
| `trigger` | `"insert"` \| `"all"` | `insert` reacts to typed characters (`InsertCharPre`), `all` to every typed key in every mode (`vim.on_key`). |
| `scale` | string \| string[] | Preset `pentatonic` or `wholetone`, or a list of note names (`C`, `C#`, … `B`). |
| `volume` | number | Peak amplitude between `0` and `1`. |
| `volume_step` | number | Step of `:Pentatonic louder` / `quieter` (greater than `0`, at most `1`). Changes last for the current session only. |
| `max_voices` | integer | Maximum number of simultaneously playing tones; further keystrokes stay silent. |
| `player` | string[] \| nil | Player command; the sample path is appended. `nil` picks the first available of `pw-play`, `paplay`, `aplay -q`, `afplay`. |
| `filetypes_exclude` | string[] | Filetypes without sound. Prompt buffers are always excluded. |

## Sound

Each keystroke plays a random note of the scale. The octave starts at 4 and moves one
step in its current direction with a probability of 50 %, turning around at octaves 4
and 6. The tone is a sine wave with an exponential decay (time constant 0.3 s), 1.6 s
long; its last 0.4 s fade out along a raised cosine, followed by 30 ms of silence so
players that clip the end of a buffer only lose silence.

## Cache

Samples are rendered once per note, octave and volume to
`stdpath("cache")/pentatonic/r<revision>/<note><octave>_v<volume>.wav` (e.g.
`r2/Fs5_v50.wav`). The revision changes whenever the synthesis changes, so samples are
rendered again automatically after an update. Deleting the directory is safe; missing
files are rendered again on demand.
