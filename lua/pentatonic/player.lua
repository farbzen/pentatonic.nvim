local M = {}

local candidate_commands = {
  { "pw-play" },
  { "paplay" },
  { "aplay", "-q" },
  { "afplay" },
}

local active_voice_count = 0

function M.detect()
  for _, command in ipairs(candidate_commands) do
    if vim.fn.executable(command[1]) == 1 then
      return command
    end
  end
  return nil
end

function M.active_voice_count()
  return active_voice_count
end

function M.play(command, path, max_voices)
  if active_voice_count >= max_voices then
    return false
  end
  active_voice_count = active_voice_count + 1
  local started = pcall(
    vim.system,
    vim.list_extend(vim.deepcopy(command), { path }),
    { stdout = false, stderr = false },
    function()
      active_voice_count = active_voice_count - 1
    end
  )
  if not started then
    active_voice_count = active_voice_count - 1
  end
  return started
end

return M
