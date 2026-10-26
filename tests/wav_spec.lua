local wav = require("pentatonic.wav")

local function read_little_endian(bytes, offset, byte_count)
  local value = 0
  for index = byte_count, 1, -1 do
    value = value * 256 + bytes:byte(offset + index - 1)
  end
  return value
end

local function assert_equal(actual, expected, field)
  assert(actual == expected, ("%s: expected %s, got %s"):format(field, expected, actual))
end

return {
  {
    "writes a valid mono 16-bit PCM header",
    function()
      local bytes = wav.render(440, 0.5)
      local expected_data_size = math.floor(wav.sample_rate * wav.duration_seconds) * 2
      assert_equal(bytes:sub(1, 4), "RIFF", "chunk id")
      assert_equal(read_little_endian(bytes, 5, 4), 36 + expected_data_size, "riff size")
      assert_equal(bytes:sub(9, 16), "WAVEfmt ", "format")
      assert_equal(read_little_endian(bytes, 21, 2), 1, "audio format")
      assert_equal(read_little_endian(bytes, 23, 2), 1, "channel count")
      assert_equal(read_little_endian(bytes, 25, 4), wav.sample_rate, "sample rate")
      assert_equal(read_little_endian(bytes, 35, 2), 16, "bits per sample")
      assert_equal(bytes:sub(37, 40), "data", "data chunk id")
      assert_equal(read_little_endian(bytes, 41, 4), expected_data_size, "data size")
      assert_equal(#bytes, 44 + expected_data_size, "file size")
    end,
  },
  {
    "renders silence at zero volume and ends silent",
    function()
      local silent = wav.render(440, 0)
      assert(silent:sub(45):match("^%z+$"), "zero volume produced sound")
      local loud = wav.render(440, 1)
      assert_equal(loud:sub(-2), "\0\0", "last sample")
    end,
  },
}
