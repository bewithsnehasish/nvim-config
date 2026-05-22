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
  -- Native Windows: Neovim handles clipboard via the win32 API automatically — leave it alone.
  -- Native Linux/Mac: Neovim auto-detects xsel / xclip / wl-copy / pbcopy.
  -- WSL: bridge to the Windows host via win32yank.exe — but ONLY if it's actually installed.
  --
  -- The is_wsl + executable check is critical: if we set vim.g.clipboard to win32yank
  -- on a system where the binary isn't on PATH, every yank to "+" throws
  -- E475: Invalid value for argument cmd: 'win32yank.exe' is not executable.
  -- That happens on native Windows too if has("wsl") ever misfires, hence the executable gate.
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
    -- On WSL but no win32yank installed: warn once so user knows clipboard won't reach Windows.
    vim.schedule(function()
      vim.notify(
        "win32yank.exe not found on PATH. System clipboard bridge to Windows is disabled.\n"
          .. "Install: cp /mnt/c/path/to/win32yank.exe ~/.local/bin/ && chmod +x ~/.local/bin/win32yank.exe",
        vim.log.levels.WARN,
        { title = "Clipboard" }
      )
    end)
  end
end

function M.setup_shell()
  -- Only Windows needs explicit shell configuration. WSL/Linux/Mac inherit
  -- a sensible $SHELL that already knows POSIX quoting.
  -- Opt-out: set vim.g.use_pwsh_shell = false BEFORE require'core.options' to keep cmd.exe.
  if not M.is_windows then
    return
  end
  if vim.g.use_pwsh_shell == false then
    return
  end

  if M.shell == "pwsh" or M.shell == "powershell" then
    vim.opt.shell = M.shell
    -- Per `:help shell-powershell` (Neovim 0.11+ recommended form, March 2025 update).
    -- $PSStyle is PowerShell 7+ only — guard so we don't break on Windows PowerShell 5.1.
    local pwsh7_only = M.shell == "pwsh" and "$PSStyle.OutputRendering='plaintext';" or ""
    vim.opt.shellcmdflag = "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned "
      .. "-Command [Console]::InputEncoding=[Console]::OutputEncoding="
      .. "[System.Text.Encoding]::UTF8;"
      .. pwsh7_only
    -- Tee-Object (full cmdlet) is more reliable than the `tee` alias, which can be
    -- shadowed or missing in stripped environments.
    vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    vim.opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object -FilePath %s; exit $LastExitCode'
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
end

return M
