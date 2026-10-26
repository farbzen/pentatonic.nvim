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
      local expected_data_size = wav.sample_count() * 2
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
  {
    "fades out smoothly into trailing silence",
    function()
      local data = wav.render(1760, 1):sub(45)
      local function absolute_sample(index)
        local value = data:byte(index * 2 + 1) + data:byte(index * 2 + 2) * 256
        return value >= 32768 and 65536 - value or value
      end
      local window_size = math.floor(wav.sample_rate * 0.01)
      local tone_sample_count = wav.tone_sample_count()
      local previous_window_peak = math.huge
      for window_start = tone_sample_count - 40 * window_size, tone_sample_count - 1, window_size do
        local window_peak = 0
        for index = window_start, math.min(window_start + window_size, tone_sample_count) - 1 do
          window_peak = math.max(window_peak, absolute_sample(index))
        end
        assert(
          window_peak <= previous_window_peak,
          ("envelope rises at sample %d: %d > %d"):format(
            window_start,
            window_peak,
            previous_window_peak
          )
        )
        previous_window_peak = window_peak
      end
      assert(previous_window_peak <= 1, "tone ends with amplitude " .. previous_window_peak)
      assert(data:sub(tone_sample_count * 2 + 1):match("^%z+$"), "trailing samples are not silent")
    end,
  },
}
