<div align="center">

# pentatonic.nvim

_A harmonic tone for every keystroke in Neovim._

[![Version](https://img.shields.io/badge/version-0.1.0-blue?style=flat-square)](CHANGELOG.md)
[![Neovim](https://img.shields.io/badge/Neovim-0.11%2B-57A143?style=flat-square&logo=neovim)](https://neovim.io)
[![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua)](https://www.lua.org)

[Overview](#overview) • [Getting Started](#getting-started) • [Usage](#usage) • [Development](#development) • [Documentation](#documentation)

</div>

pentatonic.nvim turns typing into music: like the `pentatonic` sound of
[monkeytype](https://monkeytype.com), every keystroke plays a short sine tone from
a musical scale, so whole sentences sound like a melody instead of clicks.

## Overview

The plugin is written in pure Lua and needs nothing besides an audio player that is
already part of most desktops. The code lives in `lua/pentatonic/`, the user command in
`plugin/`.

## Features

- **Scales**: `pentatonic`, `wholetone` or any custom list of notes always sound harmonic.
- **Wandering octave**: the pitch drifts between octaves 4 and 6 just like on monkeytype.
- **No dependencies**: samples are synthesized in Lua and cached as WAV files.
- **Non-blocking**: playback runs in background processes, capped by `max_voices`.
- **Configurable trigger**: only typed characters, or every key in every mode.

## Getting Started

### Prerequisites

- Neovim 0.11 or newer
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

```lua
require("pentatonic").setup({
  scale = "wholetone",
  trigger = "all",
  volume = 0.3,
})
```

```vim
:Pentatonic toggle
```

All options are described in [docs/configuration.md](docs/configuration.md) and
`:help pentatonic`.

## Development

The development environment is provided by [devenv](https://devenv.sh):

```sh
devenv shell
run-tests   # headless test suite (nvim -l tests/run.lua)
lint        # stylua --check and selene
format      # stylua
```

## Documentation

- [Configuration](docs/configuration.md)
- [Changelog](CHANGELOG.md)
