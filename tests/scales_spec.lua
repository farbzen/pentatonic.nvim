local scales = require("magickey.scales")

local function sequence_random(values)
  local position = 0
  return function(upper_bound)
    position = position % #values + 1
    local value = values[position]
    if upper_bound then
      return math.floor(value * upper_bound) + 1
    end
    return value
  end
end

local function assert_close(actual, expected)
  assert(math.abs(actual - expected) < 0.01, ("expected %s, got %s"):format(expected, actual))
end

return {
  {
    "resolves preset names to note lists",
    function()
      local pentatonic = scales.resolve("pentatonic")
      local wholetone = scales.resolve("wholetone")
      assert(vim.deep_equal(pentatonic, { "C", "D", "E", "G", "A" }), vim.inspect(pentatonic))
      assert(vim.deep_equal(wholetone, { "C", "D", "E", "F#", "G#", "A#" }), vim.inspect(wholetone))
    end,
  },
  {
    "accepts custom note lists and rejects unknown notes or scales",
    function()
      local custom = scales.resolve({ "A", "C#" })
      assert(vim.deep_equal(custom, { "A", "C#" }), vim.inspect(custom))
      assert(not pcall(scales.resolve, { "H" }), "unknown note accepted")
      assert(not pcall(scales.resolve, "dorian"), "unknown preset accepted")
      assert(not pcall(scales.resolve, {}), "empty scale accepted")
    end,
  },
  {
    "computes equal-tempered frequencies",
    function()
      assert_close(scales.frequency("A", 4), 440)
      assert_close(scales.frequency("C", 4), 261.63)
      assert_close(scales.frequency("C", 6), 1046.5)
    end,
  },
  {
    "picks only scale notes and keeps the octave within bounds",
    function()
      local walk = scales.new_walk()
      local note_names = scales.resolve("pentatonic")
      for _ = 1, 2000 do
        local note_name, octave = scales.next_note(walk, note_names)
        assert(vim.tbl_contains(note_names, note_name), "note outside scale: " .. note_name)
        assert(
          octave >= scales.lowest_octave and octave <= scales.highest_octave,
          "octave out of range: " .. octave
        )
      end
    end,
  },
  {
    "walks the octave up and turns around at the upper bound",
    function()
      local walk = scales.new_walk()
      local always_step = sequence_random({ 0 })
      local octaves = {}
      for index = 1, 5 do
        local _, octave = scales.next_note(walk, { "C" }, always_step)
        octaves[index] = octave
      end
      assert(vim.deep_equal(octaves, { 4, 5, 6, 5, 4 }), vim.inspect(octaves))
    end,
  },
}
