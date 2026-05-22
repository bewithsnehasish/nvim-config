-- Single source of truth for OS detection, native shell, and clipboard.
-- Consumed by core.options (which calls setup_clipboard + setup_shell once at startup)
-- and by any plugin file that needs to branch on platform.

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
  return nil
end

M.shell = detect_shell()

function M.setup_clipboard()
  -- Native Windows: Neovim handles clipboard via the win32 API automatically.
  -- Native Linux/Mac: Neovim auto-detects xsel / xclip / wl-copy / pbcopy.
  -- WSL: bridge to the Windows host via win32yank.exe.
  if M.is_wsl then
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
  end
end

function M.setup_shell()
  -- Only Windows needs explicit shell configuration. WSL/Linux/Mac inherit
  -- a sensible $SHELL that already knows POSIX quoting.
  if not M.is_windows then
    return
  end

  if M.shell == "pwsh" or M.shell == "powershell" then
    vim.opt.shell = M.shell
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned "
      .. "-Command [Console]::InputEncoding=[Console]::OutputEncoding="
      .. "[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    vim.opt.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
end

return M
