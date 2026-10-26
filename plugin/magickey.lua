if vim.g.loaded_magickey then
  return
end
vim.g.loaded_magickey = true

local subcommands = { "enable", "disable", "toggle" }

vim.api.nvim_create_user_command("Magickey", function(command)
  local subcommand = command.fargs[1] or "toggle"
  if not vim.tbl_contains(subcommands, subcommand) then
    vim.notify(("magickey: unknown subcommand %q"):format(subcommand), vim.log.levels.ERROR)
    return
  end
  require("magickey")[subcommand]()
end, {
  nargs = "?",
  desc = "Enable, disable or toggle magickey sounds",
  complete = function(argument_lead)
    return vim.tbl_filter(function(subcommand)
      return vim.startswith(subcommand, argument_lead)
    end, subcommands)
  end,
})
