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

-- OSC 52 write-only provider. Paste reads the last yank instead of querying the
-- terminal: most emulators never answer an OSC 52 read, and a query that gets no
-- reply blocks the UI. See :h clipboard-osc52.
local function osc52_provider()
  local osc52 = require "vim.ui.clipboard.osc52"
  local function from_unnamed()
    return vim.split(vim.fn.getreg '"' or "", "\n")
  end
  return {
    name = "osc52-copy-only",
    copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
    paste = { ["+"] = from_unnamed, ["*"] = from_unnamed },
  }
end

function M.setup_clipboard()
  -- Native provider already works (pbcopy / wl-copy / xclip / win32yank on real
  -- Windows). Only WSL and SSH need help, and both must be set before providers init.
  if M.is_wsl then
    if vim.fn.executable "win32yank.exe" == 1 then
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
    elseif vim.fn.executable "clip.exe" == 1 then
      -- Ships with Windows, no install needed. clip.exe writes; powershell reads.
      -- tr -d '\r' strips the CRs powershell emits (win32yank's --lf equivalent).
      vim.g.clipboard = {
        name = "wsl-clip.exe",
        copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
        paste = {
          ["+"] = 'powershell.exe -NoProfile -NoLogo -Command "Get-Clipboard -Raw" | tr -d "\r"',
          ["*"] = 'powershell.exe -NoProfile -NoLogo -Command "Get-Clipboard -Raw" | tr -d "\r"',
        },
        cache_enabled = 0,
      }
    else
      -- No Windows interop at all (interop disabled in /etc/wsl.conf) — OSC 52
      -- still reaches the host terminal.
      vim.g.clipboard = osc52_provider()
    end
    return
  end

  -- SSH: Nvim auto-enables OSC 52 only when it can detect terminal support, and
  -- tmux/screen inhibit that detection (:h clipboard-osc52). Force it when there's
  -- no local display to talk to, so yanks land on the machine you're sitting at.
  if vim.env.SSH_TTY and not vim.env.DISPLAY and not vim.env.WAYLAND_DISPLAY then
    vim.g.clipboard = osc52_provider()
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
