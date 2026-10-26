if vim.g.loaded_pentatonic then
  return
end
vim.g.loaded_pentatonic = true

local subcommands = { "enable", "disable", "toggle" }

vim.api.nvim_create_user_command("Pentatonic", function(command)
  local subcommand = command.fargs[1] or "toggle"
  if not vim.tbl_contains(subcommands, subcommand) then
    vim.notify(("pentatonic: unknown subcommand %q"):format(subcommand), vim.log.levels.ERROR)
    return
  end
  require("pentatonic")[subcommand]()
end, {
  nargs = "?",
  desc = "Enable, disable or toggle pentatonic sounds",
  complete = function(argument_lead)
    return vim.tbl_filter(function(subcommand)
      return vim.startswith(subcommand, argument_lead)
    end, subcommands)
  end,
})
