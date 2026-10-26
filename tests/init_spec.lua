local magickey = require("magickey")

local silent_player = { "true" }

local function has_insert_autocmd()
  local found, autocmds =
    pcall(vim.api.nvim_get_autocmds, { group = "Magickey", event = "InsertCharPre" })
  return found and #autocmds == 1
end

return {
  {
    "registers the InsertCharPre trigger by default",
    function()
      magickey.setup({ player = silent_player })
      assert(magickey.is_enabled(), "not enabled after setup")
      assert(has_insert_autocmd(), "InsertCharPre autocmd missing")
    end,
  },
  {
    "removes the trigger when disabled and restores it on toggle",
    function()
      magickey.setup({ player = silent_player })
      magickey.disable()
      assert(not magickey.is_enabled(), "still enabled after disable")
      assert(not has_insert_autocmd(), "autocmd left after disable")
      magickey.toggle()
      assert(magickey.is_enabled(), "not enabled after toggle")
      assert(has_insert_autocmd(), "autocmd missing after toggle")
    end,
  },
  {
    "uses vim.on_key instead of the autocmd for trigger 'all'",
    function()
      magickey.setup({ trigger = "all", player = silent_player })
      assert(magickey.is_enabled(), "not enabled with trigger 'all'")
      assert(not has_insert_autocmd(), "autocmd registered with trigger 'all'")
      magickey.disable()
    end,
  },
  {
    "stays disabled when enabled is false",
    function()
      magickey.setup({ enabled = false })
      assert(not magickey.is_enabled(), "enabled despite enabled = false")
      assert(not has_insert_autocmd(), "autocmd registered despite enabled = false")
    end,
  },
  {
    "rejects invalid options",
    function()
      assert(not pcall(magickey.setup, { volume = 2 }), "volume 2 accepted")
      assert(not pcall(magickey.setup, { trigger = "normal" }), "trigger 'normal' accepted")
      assert(not pcall(magickey.setup, { scale = "dorian" }), "scale 'dorian' accepted")
      assert(not pcall(magickey.setup, { max_voices = 0 }), "max_voices 0 accepted")
    end,
  },
  {
    "renders the sample into the cache when a note is played",
    function()
      magickey.setup({ player = silent_player, scale = { "A" }, volume = 0.42 })
      magickey.play_next_note()
      local pattern = vim.fn.stdpath("cache") .. "/magickey/A?_v42.wav"
      local cached = vim.fn.glob(pattern, false, true)
      assert(#cached >= 1, "no sample cached at " .. pattern)
      magickey.disable()
    end,
  },
}
