local player = require("pentatonic.player")
local scales = require("pentatonic.scales")
local wav = require("pentatonic.wav")

local M = {}

local AUGROUP_NAME = "Pentatonic"
local TRIGGERS = { insert = true, all = true }

local defaults = {
  enabled = true,
  trigger = "insert",
  scale = "pentatonic",
  volume = 0.15,
  volume_step = 0.05,
  max_voices = 16,
  player = nil,
  filetypes_exclude = { "TelescopePrompt" },
}

local config = vim.deepcopy(defaults)
local note_names = scales.resolve(config.scale)
local octave_walk = scales.new_walk()
local on_key_namespace = vim.api.nvim_create_namespace("pentatonic")
local is_enabled = false
local missing_player_reported = false

local function cache_directory()
  return vim.fn.stdpath("cache") .. "/pentatonic/r" .. wav.revision
end

local function sample_path(note_name, octave)
  local file_safe_note_name = note_name:gsub("#", "s")
  local volume_percent = math.floor(config.volume * 100 + 0.5)
  return ("%s/%s%d_v%d.wav"):format(cache_directory(), file_safe_note_name, octave, volume_percent)
end

local function ensure_sample(note_name, octave)
  local path = sample_path(note_name, octave)
  if vim.uv.fs_stat(path) then
    return path
  end
  vim.fn.mkdir(cache_directory(), "p")
  local file = io.open(path, "wb")
  if not file then
    return nil
  end
  file:write(wav.render(scales.frequency(note_name, octave), config.volume))
  file:close()
  return path
end

local function prerender_samples()
  for _, note_name in ipairs(note_names) do
    for octave = scales.lowest_octave, scales.highest_octave do
      ensure_sample(note_name, octave)
    end
  end
end

local function player_command()
  local command = config.player or player.detect()
  if not command and not missing_player_reported then
    missing_player_reported = true
    vim.notify(
      "pentatonic: no audio player found (pw-play, paplay, aplay, afplay); set `player` in setup()",
      vim.log.levels.WARN
    )
  end
  return command
end

local function is_current_buffer_excluded()
  return vim.bo.buftype == "prompt" or vim.tbl_contains(config.filetypes_exclude, vim.bo.filetype)
end

function M.play_next_note()
  if is_current_buffer_excluded() then
    return
  end
  local command = player_command()
  if not command then
    return
  end
  local path = ensure_sample(scales.next_note(octave_walk, note_names))
  if path then
    player.play(command, path, config.max_voices)
  end
end

local function attach_trigger()
  if config.trigger == "insert" then
    vim.api.nvim_create_autocmd("InsertCharPre", {
      group = vim.api.nvim_create_augroup(AUGROUP_NAME, { clear = true }),
      callback = M.play_next_note,
    })
  else
    vim.on_key(function(_, typed)
      if typed and typed ~= "" then
        vim.schedule(M.play_next_note)
      end
    end, on_key_namespace)
  end
end

local function detach_trigger()
  pcall(vim.api.nvim_del_augroup_by_name, AUGROUP_NAME)
  vim.on_key(nil, on_key_namespace)
end

function M.is_enabled()
  return is_enabled
end

function M.enable()
  detach_trigger()
  attach_trigger()
  is_enabled = true
  vim.schedule(prerender_samples)
end

function M.disable()
  detach_trigger()
  is_enabled = false
end

function M.toggle()
  if is_enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.volume()
  return config.volume
end

function M.set_volume(volume)
  vim.validate("volume", volume, "number")
  config.volume = math.floor(math.max(0, math.min(1, volume)) * 100 + 0.5) / 100
  if is_enabled then
    vim.schedule(prerender_samples)
  end
  local volume_percent = math.floor(config.volume * 100 + 0.5)
  vim.notify(("pentatonic: volume %d %%"):format(volume_percent), vim.log.levels.INFO)
  return config.volume
end

function M.louder()
  return M.set_volume(config.volume + config.volume_step)
end

function M.quieter()
  return M.set_volume(config.volume - config.volume_step)
end

function M.setup(options)
  options = options or {}
  vim.validate("options", options, "table")
  local merged = vim.tbl_extend("force", vim.deepcopy(defaults), options)
  vim.validate("enabled", merged.enabled, "boolean")
  vim.validate("trigger", merged.trigger, function(value)
    return TRIGGERS[value] == true
  end, "'insert' or 'all'")
  vim.validate("scale", merged.scale, { "string", "table" })
  vim.validate("volume", merged.volume, function(value)
    return type(value) == "number" and value >= 0 and value <= 1
  end, "number between 0 and 1")
  vim.validate("volume_step", merged.volume_step, function(value)
    return type(value) == "number" and value > 0 and value <= 1
  end, "number greater than 0 and at most 1")
  vim.validate("max_voices", merged.max_voices, function(value)
    return type(value) == "number" and value >= 1
  end, "number >= 1")
  vim.validate("player", merged.player, "table", true)
  vim.validate("filetypes_exclude", merged.filetypes_exclude, "table")

  note_names = scales.resolve(merged.scale)
  config = merged
  octave_walk = scales.new_walk()

  if config.enabled then
    M.enable()
  else
    M.disable()
  end
end

return M
