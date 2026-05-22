local M = {}

local has_win32 = vim.fn.has "win32" == 1
local has_wsl = vim.fn.has "wsl" == 1
local has_mac = vim.fn.has "mac" == 1

M.is_windows = has_win32
M.is_wsl = has_wsl
M.is_mac = has_mac
M.is_linux = not has_win32 and not has_wsl and not has_mac

vim.g.is_windows = M.is_windows
vim.g.is_wsl = M.is_wsl

local function detect_shell()
  if M.is_windows then
    if vim.fn.executable "pwsh" == 1 then
      return "pwsh"
    end
    if vim.fn.executable "powershell" == 1 then
      return "powershell"
    end
    return "cmd.exe"
  end
end

M.shell = detect_shell()

function M.setup_clipboard()
  if M.is_wsl and vim.fn.executable "win32yank.exe" == 1 then
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
      cache_enabled = 0,
    }
  elseif M.is_wsl then
    vim.schedule(function()
      vim.notify(
        "win32yank.exe not found — Windows clipboard bridge disabled",
        vim.log.levels.WARN,
        { title = "Clipboard" }
      )
    end)
  end
end

function M.setup_shell()
  if not M.is_windows or vim.g.use_pwsh_shell == false then
    return
  end
  if M.shell ~= "pwsh" and M.shell ~= "powershell" then
    return
  end
  vim.opt.shell = M.shell
  -- $PSStyle exists only on pwsh (PowerShell 7+), not on Windows powershell 5.1
  local pwsh7_only = M.shell == "pwsh" and "$PSStyle.OutputRendering='plaintext';" or ""
  vim.opt.shellcmdflag = "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned "
    .. "-Command [Console]::InputEncoding=[Console]::OutputEncoding="
    .. "[System.Text.Encoding]::UTF8;"
    .. pwsh7_only
  vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  vim.opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object -FilePath %s; exit $LastExitCode'
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

return M
