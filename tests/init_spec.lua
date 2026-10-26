local pentatonic = require("pentatonic")
local wav = require("pentatonic.wav")

local silent_player = { "true" }

local function has_insert_autocmd()
  local found, autocmds =
    pcall(vim.api.nvim_get_autocmds, { group = "Pentatonic", event = "InsertCharPre" })
  return found and #autocmds == 1
end

return {
  {
    "registers the InsertCharPre trigger by default",
    function()
      pentatonic.setup({ player = silent_player })
      assert(pentatonic.is_enabled(), "not enabled after setup")
      assert(has_insert_autocmd(), "InsertCharPre autocmd missing")
    end,
  },
  {
    "removes the trigger when disabled and restores it on toggle",
    function()
      pentatonic.setup({ player = silent_player })
      pentatonic.disable()
      assert(not pentatonic.is_enabled(), "still enabled after disable")
      assert(not has_insert_autocmd(), "autocmd left after disable")
      pentatonic.toggle()
      assert(pentatonic.is_enabled(), "not enabled after toggle")
      assert(has_insert_autocmd(), "autocmd missing after toggle")
    end,
  },
  {
    "uses vim.on_key instead of the autocmd for trigger 'all'",
    function()
      pentatonic.setup({ trigger = "all", player = silent_player })
      assert(pentatonic.is_enabled(), "not enabled with trigger 'all'")
      assert(not has_insert_autocmd(), "autocmd registered with trigger 'all'")
      pentatonic.disable()
    end,
  },
  {
    "stays disabled when enabled is false",
    function()
      pentatonic.setup({ enabled = false })
      assert(not pentatonic.is_enabled(), "enabled despite enabled = false")
      assert(not has_insert_autocmd(), "autocmd registered despite enabled = false")
    end,
  },
  {
    "rejects invalid options",
    function()
      assert(not pcall(pentatonic.setup, { volume = 2 }), "volume 2 accepted")
      assert(not pcall(pentatonic.setup, { trigger = "normal" }), "trigger 'normal' accepted")
      assert(not pcall(pentatonic.setup, { scale = "dorian" }), "scale 'dorian' accepted")
      assert(not pcall(pentatonic.setup, { max_voices = 0 }), "max_voices 0 accepted")
      assert(not pcall(pentatonic.setup, { volume_step = 0 }), "volume_step 0 accepted")
      assert(not pcall(pentatonic.setup, { volume_step = -0.1 }), "negative volume_step accepted")
    end,
  },
  {
    "changes the volume by volume_step and clamps it to 0..1",
    function()
      local original_notify = vim.notify
      vim.notify = function() end
      pentatonic.setup({ enabled = false, volume = 0.15 })
      assert(pentatonic.louder() == 0.2, "louder from 0.15: " .. pentatonic.volume())
      assert(pentatonic.quieter() == 0.15, "quieter from 0.2: " .. pentatonic.volume())
      pentatonic.setup({ enabled = false, volume = 0.98, volume_step = 0.1 })
      assert(pentatonic.louder() == 1, "louder above 1: " .. pentatonic.volume())
      pentatonic.set_volume(0.02)
      assert(pentatonic.quieter() == 0, "quieter below 0: " .. pentatonic.volume())
      vim.notify = original_notify
    end,
  },
  {
    "renders the sample into the cache when a note is played",
    function()
      pentatonic.setup({ player = silent_player, scale = { "A" }, volume = 0.42 })
      pentatonic.play_next_note()
      local pattern = vim.fn.stdpath("cache") .. "/pentatonic/r" .. wav.revision .. "/A?_v42.wav"
      local cached = vim.fn.glob(pattern, false, true)
      assert(#cached >= 1, "no sample cached at " .. pattern)
      pentatonic.disable()
    end,
  },
}
