local M = {}

function M.adapter()
  return require "neotest-dotnet" {
    discovery_root = "solution",
    dap = {
      justMyCode = false,
      adapter_name = "netcoredbg",
    },
  }
end

return M
