local M = {}

M.sample_rate = 44100
M.duration_seconds = 1.6
M.trailing_silence_seconds = 0.03
M.revision = 2

local BITS_PER_SAMPLE = 16
local BYTES_PER_SAMPLE = BITS_PER_SAMPLE / 8
local CHANNEL_COUNT = 1
local PCM_FORMAT = 1
local FMT_CHUNK_SIZE = 16
local RIFF_HEADER_REMAINDER_SIZE = 36
local MAX_AMPLITUDE = 32767
local DECAY_TIME_CONSTANT_SECONDS = 0.3
local FADE_OUT_SECONDS = 0.4

local function little_endian(value, byte_count)
  local bytes = {}
  for index = 1, byte_count do
    bytes[index] = string.char(value % 256)
    value = math.floor(value / 256)
  end
  return table.concat(bytes)
end

local function header(data_size)
  return table.concat({
    "RIFF",
    little_endian(RIFF_HEADER_REMAINDER_SIZE + data_size, 4),
    "WAVE",
    "fmt ",
    little_endian(FMT_CHUNK_SIZE, 4),
    little_endian(PCM_FORMAT, 2),
    little_endian(CHANNEL_COUNT, 2),
    little_endian(M.sample_rate, 4),
    little_endian(M.sample_rate * CHANNEL_COUNT * BYTES_PER_SAMPLE, 4),
    little_endian(CHANNEL_COUNT * BYTES_PER_SAMPLE, 2),
    little_endian(BITS_PER_SAMPLE, 2),
    "data",
    little_endian(data_size, 4),
  })
end

function M.tone_sample_count()
  return math.floor(M.sample_rate * M.duration_seconds)
end

function M.sample_count()
  return M.tone_sample_count() + math.floor(M.sample_rate * M.trailing_silence_seconds)
end

function M.render(frequency, volume)
  local tone_sample_count = M.tone_sample_count()
  local fade_out_start = tone_sample_count - math.floor(M.sample_rate * FADE_OUT_SECONDS)
  local fade_out_length = tone_sample_count - fade_out_start
  local angular_step = 2 * math.pi * frequency / M.sample_rate
  local peak = MAX_AMPLITUDE * math.max(0, math.min(1, volume))
  local samples = {}
  for index = 0, tone_sample_count - 1 do
    local seconds = index / M.sample_rate
    local envelope = math.exp(-seconds / DECAY_TIME_CONSTANT_SECONDS)
    if index >= fade_out_start then
      local fade_progress = (index - fade_out_start) / fade_out_length
      envelope = envelope * 0.5 * (1 + math.cos(math.pi * fade_progress))
    end
    local sample = math.floor(peak * envelope * math.sin(angular_step * index) + 0.5)
    if sample < 0 then
      sample = sample + 65536
    end
    samples[index + 1] = string.char(sample % 256, math.floor(sample / 256))
  end
  local silence = string.rep("\0", (M.sample_count() - tone_sample_count) * BYTES_PER_SAMPLE)
  local data = table.concat(samples) .. silence
  return header(#data) .. data
end

return M
