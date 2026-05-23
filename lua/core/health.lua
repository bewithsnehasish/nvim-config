local platform = require "core.platform"

local M = {}

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function readable(path)
  return vim.fn.filereadable(path) == 1
end

local function has_any(paths)
  for _, path in ipairs(paths) do
    if path and path ~= "" and (executable(path) or readable(path)) then
      return true, path
    end
  end
  return false
end

local function status_line(label, ok, detail)
  local state = ok and "OK  " or "MISS"
  if detail and detail ~= "" then
    return string.format("[%s] %-28s %s", state, label, detail)
  end
  return string.format("[%s] %s", state, label)
end

local function mason_path(...)
  return vim.fs.joinpath(vim.fn.stdpath "data", "mason", ...)
end

local function parser_paths(name)
  local parser_dir = vim.fs.joinpath(vim.fn.stdpath "data", "lazy", "nvim-treesitter", "parser")
  return {
    vim.fs.joinpath(parser_dir, name .. ".so"),
    vim.fs.joinpath(parser_dir, name .. ".dll"),
    vim.fs.joinpath(parser_dir, name .. ".dylib"),
  }
end

local function has_executable(tools)
  for _, tool in ipairs(tools) do
    if executable(tool) then
      return true, tool
    end
  end
  return false
end

local function dotnet_sdk_major()
  if not executable "dotnet" then
    return 0
  end
  local out = vim.fn.systemlist { "dotnet", "--list-sdks" }
  if vim.v.shell_error ~= 0 then
    return 0
  end
  local highest = 0
  for _, line in ipairs(out) do
    local major = tonumber(line:match "^(%d+)%.")
    if major and major > highest then
      highest = major
    end
  end
  return highest
end

local function roslyn_version()
  local manifest = mason_path("packages", "roslyn", "mason-receipt.json")
  if not readable(manifest) then
    return nil
  end
  local raw = table.concat(vim.fn.readfile(manifest), "\n")
  local ok, parsed = pcall(vim.json.decode, raw)
  if not ok or type(parsed) ~= "table" then
    return nil
  end
  return parsed.primary_source and parsed.primary_source.id or nil
end

local function collect()
  local lines = {
    "Neovim Config Health",
    "====================",
    "",
    "Platform",
    "--------",
    status_line("Native Windows", platform.is_windows),
    status_line("WSL", platform.is_wsl),
    status_line("Linux (native)", platform.is_linux),
    status_line(
      "Neovim >= 0.12",
      vim.fn.has "nvim-0.12" == 1,
      vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
    ),
    "",
    "Core Tools",
    "----------",
  }

  for _, tool in ipairs {
    { "git", "required by lazy.nvim" },
    { "rg", "required by grep pickers" },
    { "fd", "recommended by file pickers" },
    { "dotnet", "required by Roslyn" },
    { "node", "required by JS tooling" },
    { "npm", "required by JS tooling" },
  } do
    table.insert(lines, status_line(tool[1], executable(tool[1]), tool[2]))
  end

  local sdk_major = dotnet_sdk_major()
  table.insert(
    lines,
    status_line(
      "dotnet SDK >= 8",
      sdk_major >= 8,
      sdk_major > 0 and ("highest installed: " .. sdk_major) or "no SDKs found"
    )
  )

  table.insert(lines, "")
  table.insert(lines, "Windows Shell / Clipboard")
  table.insert(lines, "-------------------------")
  if platform.is_windows then
    table.insert(lines, status_line("pwsh", executable "pwsh", "PowerShell 7+ (preferred shell)"))
    table.insert(lines, status_line("powershell", executable "powershell", "PowerShell 5 (fallback)"))
    local shell = vim.opt.shell:get()
    table.insert(
      lines,
      status_line("vim shell is pwsh", shell == "pwsh" or shell == "powershell", "current: " .. shell)
    )
  elseif platform.is_wsl then
    table.insert(
      lines,
      status_line("win32yank.exe", executable "win32yank.exe", "required for Windows clipboard bridge")
    )
  else
    table.insert(lines, "Native Linux: no Windows-specific shell/clipboard checks.")
  end

  table.insert(lines, "")
  table.insert(lines, "Build Tools")
  table.insert(lines, "-----------")
  local compiler_ok, compiler = has_executable { "cc", "gcc", "clang", "cl" }
  table.insert(lines, status_line("cmake", executable "cmake", "needed by some native plugins"))
  table.insert(lines, status_line("C compiler", compiler_ok, compiler or "needed by nvim-treesitter"))

  table.insert(lines, "")
  table.insert(lines, ".NET / Mason")
  table.insert(lines, "-------------")
  local netcoredbg_ok, netcoredbg_path = has_any {
    vim.fn.exepath "netcoredbg",
    mason_path("bin", "netcoredbg"),
    mason_path("bin", "netcoredbg.cmd"),
    mason_path("bin", "netcoredbg.exe"),
    mason_path("packages", "netcoredbg", "libexec", "netcoredbg", "netcoredbg"),
    mason_path("packages", "netcoredbg", "netcoredbg", "netcoredbg.exe"),
  }
  table.insert(lines, status_line("netcoredbg", netcoredbg_ok, netcoredbg_path or "debug nearest .NET test"))

  local csharpier_ok, csharpier_path = has_any {
    vim.fn.exepath "csharpier",
    mason_path("bin", "csharpier"),
    mason_path("bin", "csharpier.cmd"),
  }
  table.insert(lines, status_line("csharpier", csharpier_ok, csharpier_path or "C# formatter"))

  local roslyn_dir_ok = vim.fn.isdirectory(mason_path("packages", "roslyn")) == 1
  table.insert(lines, status_line("roslyn package", roslyn_dir_ok, mason_path("packages", "roslyn")))

  local rv = roslyn_version()
  if rv then
    table.insert(lines, status_line("roslyn version", true, rv))
  end

  local razor_ok, razor_path = has_any(parser_paths "razor")
  table.insert(lines, status_line("razor parser", razor_ok, razor_path or "nvim-treesitter parser"))

  return lines
end

function M.run()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "text"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, collect())
  vim.api.nvim_set_current_buf(buf)
end

function M.check()
  local health = vim.health or require("health")
  health.start("Neovim Config Health")
  for _, line in ipairs(collect()) do
    health.info(line)
  end
end

return M
