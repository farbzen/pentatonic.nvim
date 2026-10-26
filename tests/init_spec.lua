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
