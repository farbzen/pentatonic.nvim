local repository_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(repository_root)
package.path = repository_root .. "/tests/?.lua;" .. package.path

local spec_files = vim.fn.glob(repository_root .. "/tests/*_spec.lua", false, true)
local failure_count = 0
local test_count = 0

for _, spec_file in ipairs(spec_files) do
  local spec_name = vim.fn.fnamemodify(spec_file, ":t:r")
  local cases = dofile(spec_file)
  for _, case in ipairs(cases) do
    test_count = test_count + 1
    local passed, message = pcall(case[2])
    if passed then
      io.write(("ok    %s: %s"):format(spec_name, case[1]) .. "\n")
    else
      failure_count = failure_count + 1
      io.write(("FAIL  %s: %s\n      %s"):format(spec_name, case[1], message) .. "\n")
    end
  end
end

io.write(("%d tests, %d failures"):format(test_count, failure_count) .. "\n")
os.exit(failure_count == 0 and 0 or 1)
