local M = {}

local LOWEST_OCTAVE = 4
local HIGHEST_OCTAVE = 6
local OCTAVE_STEP_PROBABILITY = 0.5
local CONCERT_PITCH_HZ = 440
local CONCERT_PITCH_MIDI_NUMBER = 69

local semitone_by_note_name = {
  C = 0,
  ["C#"] = 1,
  D = 2,
  ["D#"] = 3,
  E = 4,
  F = 5,
  ["F#"] = 6,
  G = 7,
  ["G#"] = 8,
  A = 9,
  ["A#"] = 10,
  B = 11,
}

M.presets = {
  pentatonic = { "C", "D", "E", "G", "A" },
  wholetone = { "C", "D", "E", "F#", "G#", "A#" },
}

M.lowest_octave = LOWEST_OCTAVE
M.highest_octave = HIGHEST_OCTAVE

function M.is_note_name(name)
  return semitone_by_note_name[name] ~= nil
end

function M.resolve(scale)
  local note_names = type(scale) == "string" and M.presets[scale] or scale
  if type(note_names) ~= "table" or #note_names == 0 then
    error(("magickey: unknown scale %s"):format(vim.inspect(scale)))
  end
  for _, name in ipairs(note_names) do
    if not M.is_note_name(name) then
      error(("magickey: unknown note %s"):format(vim.inspect(name)))
    end
  end
  return note_names
end

function M.frequency(note_name, octave)
  local midi_number = (octave + 1) * 12 + semitone_by_note_name[note_name]
  return CONCERT_PITCH_HZ * 2 ^ ((midi_number - CONCERT_PITCH_MIDI_NUMBER) / 12)
end

function M.new_walk()
  return { octave = LOWEST_OCTAVE, direction = 1 }
end

function M.next_note(walk, note_names, random)
  random = random or math.random
  local note_name = note_names[random(#note_names)]
  local octave = walk.octave
  if random() < OCTAVE_STEP_PROBABILITY then
    walk.octave = walk.octave + walk.direction
  end
  if walk.octave >= HIGHEST_OCTAVE then
    walk.direction = -1
  elseif walk.octave <= LOWEST_OCTAVE then
    walk.direction = 1
  end
  return note_name, octave
end

return M
