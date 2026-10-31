# Development

## Environment

The development environment is provided by [devenv](https://devenv.sh). It ships
Neovim, [StyLua](https://github.com/JohnnyMorganz/StyLua),
[selene](https://github.com/Kampfkarren/selene) and
[lua-language-server](https://github.com/LuaLS/lua-language-server):

```sh
devenv shell
```

With [direnv](https://direnv.net) installed, the `.envrc` enters the environment
automatically.

## Repository layout

| Path | Content |
| --- | --- |
| `lua/pentatonic/init.lua` | Public API, `setup()`, sample cache, keystroke triggers and volume control |
| `lua/pentatonic/scales.lua` | Scale presets, note names and frequencies, wandering octave |
| `lua/pentatonic/wav.lua` | Sine synthesis and WAV encoding |
| `lua/pentatonic/player.lua` | Player detection and non-blocking playback |
| `plugin/pentatonic.lua` | `:Pentatonic` user command |
| `doc/pentatonic.txt` | Vim help (`:help pentatonic`) |
| `tests/` | Specs (`*_spec.lua`) and the minimal runner `run.lua` |

## Tests

```sh
run-tests
```

The script runs `nvim --clean -l tests/run.lua` headless with a separate cache
directory below `$DEVENV_STATE`. The runner executes every `tests/*_spec.lua`; each
spec returns a list of `{ name, function }` pairs, and a failing assertion makes the
run exit with a non-zero status.

## Code quality

```sh
lint     # stylua --check and selene on lua/, plugin/ and tests/
format   # stylua on lua/, plugin/ and tests/
```

Formatting follows `stylua.toml` (100 columns, two spaces, double quotes), linting
uses the `vim` standard library from `selene.toml` and `vim.yml`.
