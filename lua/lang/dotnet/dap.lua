local M = {}

local function first_executable(candidates)
  for _, candidate in ipairs(candidates) do
    if candidate and candidate ~= "" and vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
end

function M.setup_adapter(dap)
  if dap.adapters.netcoredbg then
    return true
  end

  local data = vim.fn.stdpath "data"
  local netcoredbg = first_executable {
    vim.fn.exepath "netcoredbg",
    vim.fs.joinpath(data, "mason", "bin", "netcoredbg"),
    vim.fs.joinpath(data, "mason", "bin", "netcoredbg.cmd"),
    vim.fs.joinpath(data, "mason", "bin", "netcoredbg.exe"),
    vim.fs.joinpath(data, "mason", "packages", "netcoredbg", "libexec", "netcoredbg", "netcoredbg"),
    vim.fs.joinpath(data, "mason", "packages", "netcoredbg", "netcoredbg", "netcoredbg.exe"),
  }

  if not netcoredbg then
    vim.notify("netcoredbg is not executable; install it with :MasonInstall netcoredbg", vim.log.levels.WARN)
    return false
  end

  dap.adapters.netcoredbg = {
    type = "executable",
    command = netcoredbg,
    args = { "--interpreter=vscode" },
  }

  return true
end

return M
