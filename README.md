<div align="center">

# pentatonic.nvim

_A harmonic tone for every keystroke in Neovim._

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=flat-square)](CHANGELOG.md)
[![Neovim](https://img.shields.io/badge/Neovim-0.11%2B-57A143?style=flat-square&logo=neovim)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua)](https://www.lua.org)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](LICENSE)

[Overview](#overview) • [Getting Started](#getting-started) • [Usage](#usage) • [Documentation](#documentation)

</div>

pentatonic.nvim is a Neovim plugin for everyone who likes the `pentatonic` sound of
[monkeytype](https://monkeytype.com): every keystroke plays a short sine tone from a
musical scale, so whole sentences sound like a melody instead of clicks.

## Overview

The plugin is written in pure [Lua](https://www.lua.org) and needs nothing besides an
audio player that already ships with most desktops. Tones are synthesized once and
cached as WAV files, playback runs in background processes.

The repository consists of the following parts:

- **Plugin core** – scales, synthesis, sample cache and playback, built with the
  [Neovim Lua API](https://neovim.io/doc/user/lua.html). The code lives in `lua/pentatonic/`.
- **User command** – `:Pentatonic` with its subcommands. The code lives in `plugin/`.
- **Help** – the Vim help file for `:help pentatonic`. It lives in `doc/`.
- **Tests** – headless specs with a minimal runner. They live in `tests/`.

## Features

- **Scales**: `pentatonic`, `wholetone` or any custom list of notes always sound harmonic.
- **Wandering octave**: the pitch drifts between octaves 4 and 6 just like on monkeytype.
- **No dependencies**: samples are synthesized in Lua and cached as WAV files.
- **Non-blocking**: playback runs in background processes, capped by `max_voices`.
- **Configurable trigger**: only typed characters, or every key in every mode.
- **Volume control**: make the tones louder or quieter on the fly.

## Getting Started

### Prerequisites

- [Neovim](https://neovim.io) 0.11 or newer
- One of `pw-play` (PipeWire), `paplay` (PulseAudio), `aplay` (ALSA) or `afplay` (macOS)

### Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "farbzen/pentatonic.nvim",
  opts = {},
}
```

> [!TIP]
> The first keystrokes after the very first start render the samples (about 100 ms in
> total); afterwards they are read from the cache.

## Usage

Pass options to `setup()` (or `opts` in lazy.nvim):

```lua
require("pentatonic").setup({
  scale = "wholetone",
  trigger = "all",
  volume = 0.3,
})
```

Control the plugin at runtime:

```vim
:Pentatonic           " same as :Pentatonic toggle
:Pentatonic enable
:Pentatonic disable
:Pentatonic louder
:Pentatonic quieter
```

> [!NOTE]
> The plugin sets no key mappings, and volume changes last for the current session only.

```lua
vim.keymap.set("n", "<leader>p+", require("pentatonic").louder, { desc = "Pentatonic louder" })
vim.keymap.set("n", "<leader>p-", require("pentatonic").quieter, { desc = "Pentatonic quieter" })
```

## Documentation

- [Configuration](docs/configuration.md) – all options, sound and cache
- [Development](docs/development.md) – environment, tests, linting
- `:help pentatonic` – Vim help
- [Changelog](CHANGELOG.md)

## License

See [LICENSE](LICENSE).
