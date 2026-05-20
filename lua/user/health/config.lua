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

local function collect()
  local lines = {
    "Neovim Config Health",
    "====================",
    "",
    "Platform",
    "--------",
    status_line("Native Windows", vim.g.is_windows == true),
    status_line("WSL", vim.g.is_wsl == true),
    status_line(
      "Neovim >= 0.11",
      vim.fn.has "nvim-0.11" == 1,
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

  table.insert(lines, "")
  table.insert(lines, "Windows Shell / Clipboard")
  table.insert(lines, "-------------------------")
  if vim.g.is_windows then
    table.insert(lines, status_line("pwsh", executable "pwsh", "preferred ToggleTerm shell"))
    table.insert(lines, status_line("powershell", executable "powershell", "fallback ToggleTerm shell"))
  elseif vim.g.is_wsl then
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
  local razor_ok, razor_path = has_any(parser_paths "razor")
  table.insert(lines, status_line("csharpier", csharpier_ok, csharpier_path or "C# formatter"))
  table.insert(
    lines,
    status_line(
      "roslyn package",
      vim.fn.isdirectory(mason_path("packages", "roslyn")) == 1,
      mason_path("packages", "roslyn")
    )
  )
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

return M
