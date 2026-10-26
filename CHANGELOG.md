# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `:Pentatonic louder` and `:Pentatonic quieter` change the volume for the current
  session by the new option `volume_step` (default `0.05`), clamped to `0`–`1`.
- Lua API `volume()`, `set_volume()`, `louder()` and `quieter()`.

### Fixed

- Tones fade out smoothly instead of being cut off: the tone lasts 1.6 s, its last
  0.4 s fade out along a raised cosine and 30 ms of trailing silence protect the end
  from players that clip it.
- Cached samples are stored per synthesis revision (`stdpath("cache")/pentatonic/r2`),
  so changed sounds are rendered again automatically.

## [0.1.0] - 2026-10-26

### Added

- Harmonic tone per keystroke, modelled on the `pentatonic` sound of monkeytype:
  a random note of the selected scale with an octave that wanders between 4 and 6.
- Scales `pentatonic` (C D E G A) and `wholetone` (C D E F# G# A#) plus custom
  note lists.
- Sine samples rendered in pure Lua as WAV files and cached under
  `stdpath("cache")/pentatonic`.
- Non-blocking playback via `pw-play`, `paplay`, `aplay` or `afplay`, or a custom
  player command, limited by `max_voices`.
- Configurable trigger: typed characters only (`insert`, default) or every key
  (`all`).
- `:Pentatonic enable|disable|toggle` and `:help pentatonic`.

[Unreleased]: https://github.com/farbzen/pentatonic.nvim/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/farbzen/pentatonic.nvim/releases/tag/v0.1.0
