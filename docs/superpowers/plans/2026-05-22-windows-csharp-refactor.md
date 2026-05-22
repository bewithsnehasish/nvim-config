# Windows + C# Refactor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Strip Python/Java/notebook footprint, eliminate dead code, restructure into `core/` + `lsp/` + `lang/` modules, fully support native Windows, and commit to Neovim 0.12+ as the baseline (unlocking Razor cohosting).

**Architecture:** Three new module roots — `lua/core/` (platform, options, keymaps, health), `lua/lsp/` (capabilities + per-server configs), `lua/lang/dotnet/` (LSP+DAP+test for .NET). `lua/plugins/` stays as lazy.nvim specs that delegate `config` bodies to these modules.

**Tech Stack:** Neovim 0.12+, lazy.nvim, mason-lspconfig, conform.nvim, roslyn.nvim, neotest, netcoredbg, nvim-cmp, snacks.nvim.

**Spec:** `docs/superpowers/specs/2026-05-22-windows-csharp-refactor-design.md`

**Working branch:** `windows` (no PR yet — commit per task; can be squashed/rebased at the end).

**Verification strategy:** After every task, run `nvim --headless -c "lua pcall(require, 'core.options')" -c "qa"` (or similar smoke command shown per task) to confirm the config loads without errors. After major milestones, open Neovim interactively and run the listed smoke command.

**Commit policy:** No `Co-Authored-By: Claude …` trailer. Conventional commits (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).

---

## Task 0: Prerequisites — install Neovim 0.12+

**Files:** none (environment check)

- [ ] **Step 1: Check current Neovim version**

Run: `nvim --version | head -1`
Expected: `NVIM v0.12.0` or higher.

- [ ] **Step 2: If < 0.12, install on the active host before continuing**

**WSL (Ubuntu/Debian):**
```bash
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update && sudo apt install -y neovim
```
If the PPA doesn't have 0.12, grab the AppImage:
```bash
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage
chmod +x nvim-linux-x86_64.appimage
sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
```

**Native Windows (PowerShell):**
```powershell
winget upgrade Neovim.Neovim
# or: scoop update neovim
```

- [ ] **Step 3: Re-verify**

Run: `nvim --version | head -1`
Expected: `NVIM v0.12.0` or higher. STOP and resolve if not.

- [ ] **Step 4: No commit** — environment-only step.

---

## Task 1: Fix `vim.loop` → `vim.uv` in bootstrap and color highlight

**Files:**
- Modify: `init.lua:3`
- Modify: `lua/plugins/colors-highlight.lua:36`

- [ ] **Step 1: Edit `init.lua`**

Replace `vim.loop.fs_stat(lazypath)` with `vim.uv.fs_stat(lazypath)`.

Old:
```lua
if not vim.loop.fs_stat(lazypath) then
```
New:
```lua
if not vim.uv.fs_stat(lazypath) then
```

- [ ] **Step 2: Edit `lua/plugins/colors-highlight.lua`**

Replace line 36.

Old:
```lua
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
```
New:
```lua
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
```

- [ ] **Step 3: Smoke-test**

Run: `nvim --headless -c "lua print(vim.uv ~= nil)" -c "qa"`
Expected: prints `true`, exit 0.

Run: `rg -n "vim\.loop" /home/derek/.config/nvim --type lua`
Expected: zero matches.

- [ ] **Step 4: Commit**

```bash
git add init.lua lua/plugins/colors-highlight.lua
git commit -m "refactor: replace deprecated vim.loop with vim.uv"
```

---

## Task 2: Create `lua/core/platform.lua`

**Files:**
- Create: `lua/core/platform.lua`

- [ ] **Step 1: Create the platform module**

Create file `lua/core/platform.lua` with:

```lua
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

-- Mirror to vim.g so legacy callers (and some plugins) can still read it
vim.g.is_windows = M.is_windows
vim.g.is_wsl = M.is_wsl

-- Best interactive shell for this OS. ToggleTerm reads this; core.setup_shell
-- also wires it into vim.opt.shell on Windows.
local function detect_shell()
  if M.is_windows then
    if vim.fn.executable "pwsh" == 1 then return "pwsh" end
    if vim.fn.executable "powershell" == 1 then return "powershell" end
    return "cmd.exe"
  end
  return nil -- nil = inherit the user's $SHELL on WSL/Linux/Mac
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
  if not M.is_windows then return end

  if M.shell == "pwsh" or M.shell == "powershell" then
    vim.opt.shell = M.shell
    -- PowerShell flags that produce predictable, parseable output:
    --   -NoLogo            : suppress banner
    --   -NoProfile         : don't load user profile (faster, deterministic)
    --   -ExecutionPolicy   : allow signed local scripts (needed by some tools)
    --   -Command [...]     : run the next argument as a single command and force UTF-8 I/O
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned "
      .. "-Command [Console]::InputEncoding=[Console]::OutputEncoding="
      .. "[System.Text.Encoding]::UTF8;"
    -- These redir/pipe patterns preserve exit codes, which Conform & gitsigns rely on.
    vim.opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    vim.opt.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
end

return M
```

- [ ] **Step 2: Smoke-test the module loads in isolation**

Run:
```bash
nvim --headless -c "lua local p = require('core.platform'); print(p.is_windows, p.is_wsl, p.is_linux, p.shell)" -c "qa"
```
Expected: prints something like `false  true  false  nil` on WSL (no error).

- [ ] **Step 3: Commit**

```bash
git add lua/core/platform.lua
git commit -m "feat(core): add platform module for OS detection, clipboard, and shell"
```

---

## Task 3: Migrate `vim-options.lua` → `core/options.lua` (drop OS/clipboard/Neovide blocks)

**Files:**
- Create: `lua/core/options.lua`
- Delete: `lua/vim-options.lua`
- Modify: `init.lua` (update require path)

- [ ] **Step 1: Write the new `core/options.lua`**

Create `lua/core/options.lua`:

```lua
-- Core Neovim options. Calls into core.platform for anything OS-specific.
local platform = require "core.platform"

-- Ensure .mjs/.cjs files are treated as javascript so ESLint LSP attaches
vim.filetype.add {
  extension = {
    mjs = "javascript",
    cjs = "javascript",
  },
}

vim.cmd "set expandtab"
vim.cmd "set tabstop=2"
vim.cmd "set softtabstop=2"
vim.cmd "set shiftwidth=2"

-- 800ms: balances CursorHold diagnostic float responsiveness vs constant firing
vim.o.updatetime = 800

vim.g.mapleader = " "
vim.g.background = "light"
vim.g.enabled_extra_plugins = {
  "bqf",
  "cellular-automaton",
  "eyeliner",
  "mini-animate",
  "navbuddy",
  "neotab",
  "ufo",
  "ui",
}

vim.opt.swapfile = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

platform.setup_clipboard()
platform.setup_shell()

-- Disable expensive features for files >= 500 KB to prevent editor freezing
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("LargeFilePerf", { clear = true }),
  callback = function(ev)
    local ok, stats = pcall(vim.uv.fs_stat, ev.match)
    if ok and stats and stats.size > 500 * 1024 then
      vim.b[ev.buf].large_file = true
      vim.b[ev.buf].hlchunk_disabled = true
      vim.b[ev.buf].miniindentscope_disable = true
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.signcolumn = "no"
      vim.opt_local.colorcolumn = ""
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("Osc52YankNotify", { clear = true }),
  callback = function()
    if vim.v.event.operator == "y" and (vim.v.event.regname == "+" or vim.v.event.regname == "*") then
      vim.notify(
        "Yanked to system clipboard",
        vim.log.levels.INFO,
        { timeout = 500, title = "Clipboard", icon = "📋" }
      )
    end
  end,
})

vim.api.nvim_create_user_command("ConfigHealth", function()
  require("core.health").run()
end, { desc = "Show config-specific health checks" })

-- Clear search highlight with <Esc>. Frees <leader>h for the gitsigns hunk namespace.
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
vim.wo.number = true

vim.g.user_emmet_settings = {
  javascript = { extends = "html" },
  typescriptreact = { extends = "html" },
  javascriptreact = { extends = "html" },
  blade = { extends = "html, php" },
  ejs = { extends = "html, javascript" },
  php = { extends = "html, javascript ,css" },
}

vim.api.nvim_set_keymap("i", "<C-y>,", "<Plug>(emmet-expand-abbr)", {})
```

Note: dropped the 43-line commented Neovide block; dropped inline OS detection + clipboard (moved to `core.platform`); `core.health.run` replaces the old `user.health.config.run` (Task 12 will create that module — keep the require path as written and Task 12 will move the file).

- [ ] **Step 2: Update `init.lua` to require the new path**

Old:
```lua
require "vim-options"
require("lazy").setup "plugins"

--Load Keymaps plugins in the interface
require "keymaps"
```
New:
```lua
require "core.options"
require("lazy").setup "plugins"

--Load Keymaps plugins in the interface
require "keymaps"
```

- [ ] **Step 3: Delete the old file**

```bash
git rm lua/vim-options.lua
```

- [ ] **Step 4: Smoke-test (will WARN about missing core.health — that's fine, fixed in Task 12)**

Run:
```bash
nvim --headless -c "lua require('core.options'); print('options OK')" -c "qa" 2>&1 | tail -5
```
Expected: `options OK` printed. May see a `core.health` lazy-require message — ignore.

- [ ] **Step 5: Commit**

```bash
git add init.lua lua/core/options.lua
git commit -m "refactor(core): migrate vim-options.lua to core/options.lua, drop Neovide deadcode"
```

---

## Task 4: Migrate `keymaps.lua` → `core/keymaps.lua` and drop broken Java keymaps

**Files:**
- Create: `lua/core/keymaps.lua`
- Delete: `lua/keymaps.lua`
- Modify: `init.lua`

- [ ] **Step 1: Write the new `core/keymaps.lua`**

Create `lua/core/keymaps.lua` — same as old `keymaps.lua` minus lines 43-47 (broken Java keymaps that reference non-existent `:JavaProjectImport`/etc commands):

```lua
local opts = { noremap = true, silent = true }

-- Move line up
vim.api.nvim_set_keymap("n", "<M-k>", ":m .-2<CR>==", opts)
vim.api.nvim_set_keymap("i", "<M-k>", "<Esc>:m .-2<CR>==gi", opts)
vim.api.nvim_set_keymap("v", "<M-k>", ":m '<-2<CR>gv=gv", opts)

-- Move line down
vim.api.nvim_set_keymap("n", "<M-j>", ":m .+1<CR>==", opts)
vim.api.nvim_set_keymap("i", "<M-j>", "<Esc>:m .+1<CR>==gi", opts)
vim.api.nvim_set_keymap("v", "<M-j>", ":m '>+1<CR>gv=gv", opts)

-- Delete word backward in insert mode
vim.api.nvim_set_keymap("i", "<C-b>", "<C-o>db", opts)

-- Word wrap toggle
vim.api.nvim_set_keymap("n", "<leader>wr", ":lua vim.wo.wrap = not vim.wo.wrap<CR>", opts)

-- Paste from system clipboard
vim.api.nvim_set_keymap("n", "<C-v>", '"+p', opts)
vim.api.nvim_set_keymap("i", "<C-v>", "<C-R>+", opts)
vim.api.nvim_set_keymap("v", "<C-v>", '"+p', opts)

-- DAP keymaps
vim.api.nvim_set_keymap("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dr", "<cmd>DapContinue<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dT", "<cmd>DapTerminate<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dso", "<cmd>DapStepOver<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dsi", "<cmd>DapStepInto<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dsu", "<cmd>DapStepOut<CR>", opts)

vim.api.nvim_create_user_command("DapOpenSidebar", function()
  local widgets = require "dap.ui.widgets"
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end, {})
vim.api.nvim_set_keymap("n", "<leader>dus", "<cmd>DapOpenSidebar<CR>", opts)

-- Buffer & Tab Navigation (Bufferline)
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>",
  { desc = "Go to next buffer", noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>",
  { desc = "Go to previous buffer", noremap = true, silent = true })

vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>",
  { desc = "Close current buffer", noremap = true, silent = true })
vim.keymap.set("n", "<leader>X", "<cmd>BufferLineCloseOthers<CR>",
  { desc = "Close all OTHER buffers", noremap = true, silent = true })

vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>",
  { desc = "Pin/Unpin current buffer", noremap = true, silent = true })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLinePick<CR>",
  { desc = "Pick buffer by letter", noremap = true, silent = true })

vim.keymap.set("n", "<leader>c", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<leader>c", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>cc", '"+yy', { desc = "Copy line to system clipboard" })
```

- [ ] **Step 2: Update `init.lua`**

Old:
```lua
--Load Keymaps plugins in the interface
require "keymaps"
```
New:
```lua
--Load Keymaps plugins in the interface
require "core.keymaps"
```

- [ ] **Step 3: Delete old file**

```bash
git rm lua/keymaps.lua
```

- [ ] **Step 4: Smoke-test**

Run:
```bash
nvim --headless -c "lua require('core.keymaps'); print('keymaps OK')" -c "qa"
```
Expected: `keymaps OK`, no `Vim(map):` errors.

- [ ] **Step 5: Commit**

```bash
git add init.lua lua/core/keymaps.lua
git commit -m "refactor(core): migrate keymaps to core/keymaps.lua, drop broken Java keymaps"
```

---

## Task 5: Remove Python from mason.lua

**Files:**
- Modify: `lua/plugins/mason.lua`

- [ ] **Step 1: Drop pyright + ruff from ensure_installed**

Old (mason.lua:62-64):
```lua
        -- Python
        "pyright", -- FIXED: Removed duplicate
        "ruff",
```
New: delete those three lines entirely (including the `-- Python` comment).

- [ ] **Step 2: Drop pyright + ruff from skip_servers**

Old (mason.lua:82-83):
```lua
            "pyright", -- Custom setup in lspconfig
            "ruff", -- Custom setup in lspconfig
```
New: delete those two lines.

- [ ] **Step 3: Drop black, isort, debugpy, djlint from mason-tool-installer**

Old (mason.lua:122-127):
```lua
        "black",
        "isort",
        "csharpier",

        -- Django (if you use it)
        "djlint",
```
New:
```lua
        "csharpier",
```

Old (mason.lua:140):
```lua
        -- Python debugger
        "debugpy",
```
New: delete those two lines.

- [ ] **Step 4: Smoke-test**

Run:
```bash
nvim --headless -c "lua print('mason cfg parses')" -c "qa" 2>&1 | grep -i error || echo CLEAN
```
Expected: prints `CLEAN`.

Run: `rg -n "pyright|ruff|black|isort|debugpy|djlint" lua/plugins/mason.lua`
Expected: zero matches.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/mason.lua
git commit -m "refactor(mason): drop Python tools (pyright, ruff, black, isort, debugpy, djlint)"
```

---

## Task 6: Remove Python from lspconfig.lua

**Files:**
- Modify: `lua/plugins/lspconfig.lua`

- [ ] **Step 1: Drop `find_local_python` helper (lines 37-49)**

Delete from `lspconfig.lua`:

```lua
      local function find_local_python(root)
        local candidates = {
          root .. "/.venv/bin/python",
          root .. "/.venv/Scripts/python.exe",
          root .. "/.venv/Scripts/python",
        }

        for _, candidate in ipairs(candidates) do
          if vim.fn.executable(candidate) == 1 then
            return candidate
          end
        end
      end

```

- [ ] **Step 2: Drop pyright + ruff server_configs blocks (lines 368-398)**

Delete:

```lua
        pyright = {
          filetypes = { "python" },
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "basic",
              },
            },
          },
          before_init = function(_, config)
            local path = vim.fn.getcwd()
            local venv = find_local_python(path)
            if venv then
              config.settings.python.pythonPath = venv
            end
          end,
        },

        ruff = {
          filetypes = { "python" },
          settings = {
            ruff = { enable = true },
          },
          on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false
            custom_on_attach(client, bufnr)
          end,
        },

```

- [ ] **Step 3: Drop "python" from omnifunc filetype list**

Old (lspconfig.lua:641-660):
```lua
        pattern = {
          "python",
          "lua",
          ...
```
New:
```lua
        pattern = {
          "lua",
          ...
```
(only the `"python",` line goes; preserve the rest).

- [ ] **Step 4: Smoke-test**

Run:
```bash
nvim --headless -c "lua require('lspconfig')" -c "qa" 2>&1 | grep -i error || echo CLEAN
```
Expected: `CLEAN`.

Run: `rg -n "python|pyright|ruff" lua/plugins/lspconfig.lua`
Expected: zero matches.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/lspconfig.lua
git commit -m "refactor(lsp): remove pyright, ruff, and Python venv helper"
```

---

## Task 7: Remove Python from conform-formatter.lua

**Files:**
- Modify: `lua/plugins/conform-formatter.lua`

- [ ] **Step 1: Drop python, htmldjango, java filetypes**

Old (conform-formatter.lua:18-23):
```lua
        formatters_by_ft = {
          -- Python
          python = { "isort", "black" },

          -- Django
          htmldjango = { "djlint" },

          -- Web Development (React/React Native focused)
```
New:
```lua
        formatters_by_ft = {
          -- Web Development (React/React Native focused)
```

Old (conform-formatter.lua:51):
```lua
          java = { "google-java-format" },
```
New: delete that line.

- [ ] **Step 2: Drop isort + black formatter overrides**

Old (conform-formatter.lua:71-76):
```lua
          isort = {
            prepend_args = { "--profile", "black" },
          },
          black = {
            prepend_args = { "--line-length", "100" },
          },
```
New: delete those six lines.

- [ ] **Step 3: Drop the csharpier override (conform's default is already correct)**

Old (conform-formatter.lua:85-89):
```lua
          -- Override to always pass --stdin-path so csharpier resolves .csharpierrc
          -- relative to the file regardless of whether it's a global or Mason install.
          csharpier = {
            args = { "format", "--stdin-path", "$FILENAME" },
          },
```
New: delete those five lines. Conform's bundled csharpier formatter already passes `--stdin-path "$FILENAME"` and handles both standalone-binary and `dotnet tool` install forms.

- [ ] **Step 4: Smoke-test**

Run:
```bash
nvim --headless -c "lua require('conform')" -c "qa" 2>&1 | grep -i error || echo CLEAN
```
Expected: `CLEAN`.

Run: `rg -n "python|isort|black|djlint|java|google-java-format" lua/plugins/conform-formatter.lua`
Expected: zero matches.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/conform-formatter.lua
git commit -m "refactor(conform): drop Python/Java/Django formatters and redundant csharpier override"
```

---

## Task 8: Remove Python from testing.lua

**Files:**
- Modify: `lua/plugins/testing.lua`

- [ ] **Step 1: Drop neotest-python from dependencies**

Old (testing.lua:14):
```lua
      "nvim-neotest/neotest-python",
```
New: delete that line.

- [ ] **Step 2: Drop the neotest-python adapter**

Old (testing.lua:62-65):
```lua
          require "neotest-python" {
            dap = { justMyCode = false },
            runner = "pytest",
          },
```
New: delete those four lines.

- [ ] **Step 3: Smoke-test**

Run: `rg -n "python|pytest" lua/plugins/testing.lua`
Expected: zero matches.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/testing.lua
git commit -m "refactor(neotest): drop Python adapter"
```

---

## Task 9: Remove Python/Django from treesitter.lua

**Files:**
- Modify: `lua/plugins/treesitter.lua`

- [ ] **Step 1: Drop python, htmldjango, java from ensure_installed**

Old (treesitter.lua:25-50):
```lua
        ensure_installed = {
          "python",
          "htmldjango",
          "javascript",
          ...
          "java",
          ...
        },
```
New: remove `"python"`, `"htmldjango"`, `"java"` entries (preserve the rest).

- [ ] **Step 2: Drop the ipynb ignore line**

Old (treesitter.lua:51):
```lua
        ignore_install = { "ipynb" }, -- No treesitter parser exists for ipynb (notebooks are JSON)
```
New: delete that line.

- [ ] **Step 3: Remove htmldjango references in highlight + indent**

Old (treesitter.lua:54-74):
```lua
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "htmldjango" }, -- Enhance Django template highlighting
          disable = function(lang, buf)
            ...
          end,
        },
        indent = {
          enable = true,
          disable = { "htmldjango" }, -- Prevent hlchunk errors in Django templates
        },
```
New (drop both Django comments + entries):
```lua
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang, buf)
            ...
          end,
        },
        indent = {
          enable = true,
        },
```

- [ ] **Step 4: Drop the Django filetype autocmd**

Old (treesitter.lua:94-104):
```lua
      -- Filetype detection for Django templates
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.html", "*.djhtml" },
        group = vim.api.nvim_create_augroup("DjangoFiletype", { clear = true }),
        callback = function()
          local path = vim.fn.expand "%:p"
          if path:match "templates/" or path:match "%.djhtml$" then
            vim.bo.filetype = "htmldjango"
          end
        end,
      })
```
New: delete those eleven lines.

- [ ] **Step 5: Drop htmldjango from autotag**

Old (treesitter.lua:126-138):
```lua
        filetypes = {
          "html",
          "htmldjango", -- Support Django templates
          "javascript",
          ...
        },
```
New: remove the `"htmldjango",` line (preserve the rest).

- [ ] **Step 6: Smoke-test**

Run:
```bash
nvim --headless -c "lua require('nvim-treesitter.configs')" -c "qa" 2>&1 | grep -i error || echo CLEAN
```
Expected: `CLEAN`.

Run: `rg -n "python|django|htmldjango|ipynb|java" lua/plugins/treesitter.lua`
Expected: zero matches (`"java"` from `"javascript"` may match — make sure regex is word-bounded: `rg -n '\b(python|django|htmldjango|ipynb|java)\b' lua/plugins/treesitter.lua`).

- [ ] **Step 7: Commit**

```bash
git add lua/plugins/treesitter.lua
git commit -m "refactor(treesitter): drop Python/Django/Java parsers and htmldjango wiring"
```

---

## Task 10: Delete notebook plugin

**Files:**
- Delete: `lua/plugins/notebook.lua`

- [ ] **Step 1: Remove the file**

```bash
git rm lua/plugins/notebook.lua
```

- [ ] **Step 2: Smoke-test**

Run:
```bash
nvim --headless -c "lua print('OK')" -c "qa" 2>&1 | grep -i error || echo CLEAN
```
Expected: `CLEAN`.

- [ ] **Step 3: Commit**

```bash
git commit -m "chore: remove notebook (ipynb.nvim) plugin"
```

---

## Task 11: Delete dead code files

**Files:**
- Delete: `lua/plugins/coc.lua`
- Delete: `lua/plugins/formatter.lua`
- Modify: `lua/plugins/toggleterminal.lua` (drop lines 139-266, the 127-line commented duplicate)

- [ ] **Step 1: Delete coc.lua and formatter.lua**

```bash
git rm lua/plugins/coc.lua lua/plugins/formatter.lua
```

- [ ] **Step 2: Trim toggleterminal.lua**

Open `lua/plugins/toggleterminal.lua` and delete everything from line 139 (the line `-- return {`) through the end of file. Keep lines 1-138 (the active config + augroup blocks).

After the edit, the file ends with:

```lua
      function _G.set_terminal_keymaps()
        vim.api.nvim_buf_set_keymap(0, "t", "<m-h>", [[<C-\><C-n><C-W>h]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<m-j>", [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<m-k>", [[<C-\><C-n><C-W>k]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<m-l>", [[<C-\><C-n><C-W>l]], opts)
      end
    end,
  },
}
```

- [ ] **Step 3: Verify line counts**

Run: `wc -l lua/plugins/toggleterminal.lua`
Expected: 138.

- [ ] **Step 4: Smoke-test**

Run:
```bash
nvim --headless -c "lua print('OK')" -c "qa" 2>&1 | grep -i error || echo CLEAN
```
Expected: `CLEAN`.

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/toggleterminal.lua
git commit -m "chore: delete dead code (coc.lua, formatter.lua, toggleterm duplicate)"
```

---

## Task 12: Migrate health → `core/health.lua` + add SDK/pwsh/shell/roslyn checks

**Files:**
- Create: `lua/core/health.lua`
- Delete: `lua/user/health/config.lua`
- Delete: `lua/user/health/` (empty directory)

- [ ] **Step 1: Write the new module**

Create `lua/core/health.lua` (mostly the old file with added checks):

```lua
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

-- Read `dotnet --list-sdks` and return the highest major version found, or 0.
local function dotnet_sdk_major()
  if not executable "dotnet" then return 0 end
  local out = vim.fn.systemlist { "dotnet", "--list-sdks" }
  if vim.v.shell_error ~= 0 then return 0 end
  local highest = 0
  for _, line in ipairs(out) do
    local major = tonumber(line:match "^(%d+)%.")
    if major and major > highest then
      highest = major
    end
  end
  return highest
end

-- Parse roslyn version from Mason's installed package manifest.
local function roslyn_version()
  local manifest = mason_path("packages", "roslyn", "mason-receipt.json")
  if not readable(manifest) then return nil end
  local raw = table.concat(vim.fn.readfile(manifest), "\n")
  local ok, parsed = pcall(vim.json.decode, raw)
  if not ok or type(parsed) ~= "table" then return nil end
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

  -- .NET SDK version
  local sdk_major = dotnet_sdk_major()
  table.insert(lines, status_line(
    "dotnet SDK >= 8",
    sdk_major >= 8,
    sdk_major > 0 and ("highest installed: " .. sdk_major) or "no SDKs found"
  ))

  table.insert(lines, "")
  table.insert(lines, "Windows Shell / Clipboard")
  table.insert(lines, "-------------------------")
  if platform.is_windows then
    local pwsh_ok = executable "pwsh"
    table.insert(lines, status_line("pwsh", pwsh_ok, "PowerShell 7+ (preferred shell)"))
    table.insert(lines, status_line("powershell", executable "powershell", "PowerShell 5 (fallback)"))
    local shell = vim.opt.shell:get()
    table.insert(lines, status_line(
      "vim shell is pwsh",
      shell == "pwsh" or shell == "powershell",
      "current: " .. shell
    ))
  elseif platform.is_wsl then
    table.insert(lines, status_line(
      "win32yank.exe", executable "win32yank.exe", "required for Windows clipboard bridge"
    ))
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

return M
```

- [ ] **Step 2: Delete old health file and dir**

```bash
git rm lua/user/health/config.lua
rmdir lua/user/health 2>/dev/null || true
```

- [ ] **Step 3: Smoke-test**

Run:
```bash
nvim --headless -c "lua local lines = require('core.health'); print(type(lines.run))" -c "qa"
```
Expected: `function`.

Open Neovim interactively and run `:ConfigHealth`. Expected: buffer opens listing platform/Core Tools/Windows Shell/etc., with the new `dotnet SDK >= 8` line.

- [ ] **Step 4: Commit**

```bash
git add lua/core/health.lua
git commit -m "refactor(health): move to core/health.lua, add dotnet SDK + pwsh shell + roslyn version checks"
```

---

## Task 13: Migrate on_attach → `lsp/on_attach.lua`

**Files:**
- Create: `lua/lsp/on_attach.lua`
- Delete: `lua/user/lsp/on_attach.lua`
- Modify: `lua/plugins/dotnet.lua` (one require path)
- Modify: `lua/plugins/lspconfig.lua` (one require path)

- [ ] **Step 1: Move the file**

```bash
mkdir -p lua/lsp
git mv lua/user/lsp/on_attach.lua lua/lsp/on_attach.lua
rmdir lua/user/lsp 2>/dev/null || true
rmdir lua/user 2>/dev/null || true
```

- [ ] **Step 2: Update require in dotnet.lua**

Old (`lua/plugins/dotnet.lua:18`):
```lua
      local on_attach = require "user.lsp.on_attach"
```
New:
```lua
      local on_attach = require "lsp.on_attach"
```

- [ ] **Step 3: Update require in lspconfig.lua**

Old (`lua/plugins/lspconfig.lua:35`):
```lua
      local on_attach = require "user.lsp.on_attach"
```
New:
```lua
      local on_attach = require "lsp.on_attach"
```

- [ ] **Step 4: Smoke-test**

Run:
```bash
nvim --headless -c "lua print(type(require('lsp.on_attach')))" -c "qa"
```
Expected: `function`.

Run: `rg -n "user\.lsp\.on_attach|user/lsp/on_attach" /home/derek/.config/nvim`
Expected: zero matches.

- [ ] **Step 5: Commit**

```bash
git add lua/lsp/on_attach.lua lua/plugins/dotnet.lua lua/plugins/lspconfig.lua
git commit -m "refactor(lsp): move on_attach to lua/lsp/ (out of legacy user/ namespace)"
```

---

## Task 14: Drop `vim.lsp.config or fallback` branches in lspconfig.lua

**Files:**
- Modify: `lua/plugins/lspconfig.lua`

We've committed to Neovim 0.12+ — `vim.lsp.config` and `vim.lsp.enable` are always present, so the fallback branches are dead weight.

- [ ] **Step 1: Replace the handler-setup ladder**

Old (`lspconfig.lua:142-168`):
```lua
      -- FIX 9: Replaced vim.lsp.with (deprecated in 0.11+) with plain handler functions
      if vim.lsp.config then
        vim.lsp.config("*", {
          handlers = {
            ["textDocument/hover"] = function(err, result, ctx, config)
              return vim.lsp.handlers.hover(
                err,
                result,
                ctx,
                vim.tbl_extend("force", config or {}, { border = "rounded" })
              )
            end,
            ["textDocument/signatureHelp"] = function(err, result, ctx, config)
              return vim.lsp.handlers.signature_help(
                err,
                result,
                ctx,
                vim.tbl_extend("force", config or {}, { border = "rounded" })
              )
            end,
          },
        })
      else
        -- Fallback for Neovim < 0.11 (vim.lsp.with is NOT deprecated there)
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] =
          vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
      end
```
New:
```lua
      vim.lsp.config("*", {
        handlers = {
          ["textDocument/hover"] = function(err, result, ctx, config)
            return vim.lsp.handlers.hover(
              err,
              result,
              ctx,
              vim.tbl_extend("force", config or {}, { border = "rounded" })
            )
          end,
          ["textDocument/signatureHelp"] = function(err, result, ctx, config)
            return vim.lsp.handlers.signature_help(
              err,
              result,
              ctx,
              vim.tbl_extend("force", config or {}, { border = "rounded" })
            )
          end,
        },
      })
```

- [ ] **Step 2: Replace the per-server registration ladder**

Old (`lspconfig.lua:619-637`):
```lua
      -- Apply each server config
      for server_name, config in pairs(server_configs) do
        local default_config = {
          capabilities = capabilities,
          on_attach = config.on_attach or custom_on_attach,
          flags = { debounce_text_changes = 150 },
        }

        local final_config = vim.tbl_deep_extend("force", default_config, config)

        if vim.lsp.config then
          -- Neovim 0.11+ native API
          vim.lsp.config(server_name, final_config)
          vim.lsp.enable(server_name)
        else
          -- Fallback for Neovim < 0.11
          require("lspconfig")[server_name].setup(final_config)
        end
      end
```
New:
```lua
      -- Apply each server config (Neovim 0.12+ native API)
      for server_name, config in pairs(server_configs) do
        local default_config = {
          capabilities = capabilities,
          on_attach = config.on_attach or custom_on_attach,
          flags = { debounce_text_changes = 150 },
        }
        local final_config = vim.tbl_deep_extend("force", default_config, config)
        vim.lsp.config(server_name, final_config)
        vim.lsp.enable(server_name)
      end
```

- [ ] **Step 3: Smoke-test**

Run:
```bash
nvim --headless -c "lua require('lspconfig')" -c "qa" 2>&1 | grep -i error || echo CLEAN
```
Expected: `CLEAN`.

- [ ] **Step 4: Commit**

```bash
git add lua/plugins/lspconfig.lua
git commit -m "refactor(lsp): drop pre-0.12 fallback branches (vim.lsp.config now baseline)"
```

---

## Task 15: Split `lspconfig.lua` server configs into `lsp/servers/*.lua`

**Files:**
- Create: `lua/lsp/servers/lua_ls.lua`
- Create: `lua/lsp/servers/html.lua`
- Create: `lua/lsp/servers/cssls.lua`
- Create: `lua/lsp/servers/jsonls.lua`
- Create: `lua/lsp/servers/bashls.lua`
- Create: `lua/lsp/servers/tailwindcss.lua`
- Create: `lua/lsp/servers/prismals.lua`
- Create: `lua/lsp/servers/emmet_ls.lua`
- Create: `lua/lsp/servers/eslint.lua`
- Create: `lua/lsp/servers/intelephense.lua`
- Create: `lua/lsp/servers/graphql.lua`
- Create: `lua/lsp/servers/biome.lua`
- Modify: `lua/plugins/lspconfig.lua` (replace `server_configs` table with directory scan)

Each server file returns a single table. The plugin file (`plugins/lspconfig.lua`) scans the directory.

- [ ] **Step 1: Create `lua/lsp/servers/lua_ls.lua`**

```lua
return {
  filetypes = { "lua" },
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "require", "P", "R" },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}
```

- [ ] **Step 2: Create `lua/lsp/servers/html.lua`**

```lua
return {
  filetypes = { "html", "htmldjango", "blade" },
}
```

(Note: `htmldjango` stays in the filetype list — html-lsp can still attach to those buffers even though we removed the Django plugin. If you'd rather drop it, swap to `{ "html", "blade" }`.)

- [ ] **Step 3: Create `lua/lsp/servers/cssls.lua`**

```lua
return {}
```

- [ ] **Step 4: Create `lua/lsp/servers/jsonls.lua`**

```lua
return {
  -- on_new_config: defers schemastore require until the server actually starts,
  -- so lazy-loading of schemastore.nvim is preserved.
  on_new_config = function(new_config)
    local ok, schemastore = pcall(require, "schemastore")
    if ok then
      new_config.settings = new_config.settings or {}
      new_config.settings.json = new_config.settings.json or {}
      new_config.settings.json.schemas = schemastore.json.schemas()
      new_config.settings.json.validate = { enable = true }
    end
  end,
}
```

- [ ] **Step 5: Create `lua/lsp/servers/bashls.lua`**

```lua
return {}
```

- [ ] **Step 6: Create `lua/lsp/servers/tailwindcss.lua`**

```lua
return {
  filetypes = {
    "html",
    "htmldjango",
    "javascriptreact",
    "javascript",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
    "astro",
    "php",
    "blade",
    "razor",
    "cshtml",
  },
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "classList", "ngClass" },
      experimental = {
        classRegex = {
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
        },
      },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning",
      },
      validate = true,
    },
  },
}
```

- [ ] **Step 7: Create `lua/lsp/servers/prismals.lua`**

```lua
return {
  settings = {
    prisma = {
      validate = true,
      hover = true,
      completions = { enabled = true },
    },
  },
}
```

- [ ] **Step 8: Create `lua/lsp/servers/emmet_ls.lua`**

```lua
return {
  -- "javascriptreact"/"typescriptreact" removed: typescript-tools already
  -- provides JSX completions and emmet_ls conflicts with its completion items.
  -- Emmet tab expansion in JSX/TSX still works via cmp-emmet-vim.
  filetypes = {
    "html",
    "htmldjango",
    "css",
    "scss",
    "sass",
    "svelte",
    "vue",
    "php",
    "blade",
  },
  init_options = {
    html = {
      options = {
        ["bem.enabled"] = true,
        ["jsx.enabled"] = true,
      },
    },
  },
}
```

- [ ] **Step 9: Create `lua/lsp/servers/eslint.lua`**

```lua
return {
  -- Scoped by root_dir so eslint and biome don't both activate
  -- on the same project simultaneously.
  root_dir = require("lspconfig.util").root_pattern(
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.json",
    ".eslintrc.cjs",
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts"
  ),
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
  },
  settings = {
    codeAction = {
      disableRuleComment = { enable = true, location = "separateLine" },
      showDocumentation = { enable = true },
    },
    codeActionOnSave = { enable = false, mode = "all" },
    format = false,
    nodePath = "",
    onIgnoredFiles = "off",
    packageManager = "npm",
    quiet = false,
    rulesCustomizations = {},
    run = "onSave",
    useESLintClass = false,
    validate = "on",
    workingDirectory = { mode = "auto" },
  },
}
```

- [ ] **Step 10: Create `lua/lsp/servers/intelephense.lua`**

```lua
return {
  filetypes = { "php", "blade" },
  settings = {
    intelephense = {
      files = {
        maxSize = 5000000,
      },
      -- CodeIgniter 4 is Composer-based; intelephense indexes vendor/ automatically.
      -- These stubs cover PHP core + all standard extensions used in CI4 projects.
      stubs = {
        "apache", "bcmath", "bz2", "calendar", "Core", "ctype", "curl",
        "date", "dom", "exif", "fileinfo", "filter", "ftp", "gd", "gettext",
        "gmp", "hash", "iconv", "intl", "json", "libxml", "mbstring", "meta",
        "mysqli", "openssl", "pcntl", "pcre", "PDO", "pdo_mysql", "pdo_pgsql",
        "pdo_sqlite", "pgsql", "Phar", "posix", "readline", "Reflection",
        "session", "SimpleXML", "soap", "sockets", "sodium", "SPL", "sqlite3",
        "standard", "superglobals", "tokenizer", "xml", "xmlreader",
        "xmlwriter", "xsl", "zip", "zlib",
      },
    },
  },
}
```

- [ ] **Step 11: Create `lua/lsp/servers/graphql.lua`**

```lua
return {
  cmd = { "graphql-lsp", "server", "-m", "stream" },
  filetypes = { "graphql", "typescriptreact", "javascriptreact" },
  root_dir = require("lspconfig.util").root_pattern(
    ".graphqlrc*", ".graphql.config.*", "graphql.config.*"
  ),
}
```

- [ ] **Step 12: Create `lua/lsp/servers/biome.lua`**

```lua
return {
  root_dir = require("lspconfig.util").root_pattern("biome.json", "biome.jsonc"),
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
  },
}
```

- [ ] **Step 13: Replace the `server_configs` table in `lspconfig.lua` with a directory scan**

Old (`lspconfig.lua:350-617`):
```lua
      -- 7. Server Configurations
      local server_configs = {
        ...
        biome = {
          ...
        },
      }
```

New (replace that entire ~270-line block with the loader below):
```lua
      -- 7. Server Configurations — one file per server under lua/lsp/servers/
      local server_configs = {}
      local servers_dir = vim.fs.joinpath(vim.fn.stdpath "config", "lua", "lsp", "servers")
      for _, fname in ipairs(vim.fn.readdir(servers_dir, [[v:val =~ '\.lua$']])) do
        local name = fname:gsub("%.lua$", "")
        local ok, spec = pcall(require, "lsp.servers." .. name)
        if ok then
          server_configs[name] = spec
        else
          vim.notify(
            "Failed to load LSP server config: " .. name .. "\n" .. tostring(spec),
            vim.log.levels.ERROR
          )
        end
      end
```

- [ ] **Step 14: Smoke-test**

Run:
```bash
nvim --headless -c "lua for _, n in ipairs({'lua_ls','html','cssls','jsonls','bashls','tailwindcss','prismals','emmet_ls','eslint','intelephense','graphql','biome'}) do assert(require('lsp.servers.' .. n), n .. ' failed') end print('all servers loaded')" -c "qa"
```
Expected: `all servers loaded`.

Open Neovim interactively, run `:LspInfo` on a `.lua` file. Expected: `lua_ls` attached.

- [ ] **Step 15: Commit**

```bash
git add lua/lsp/servers/ lua/plugins/lspconfig.lua
git commit -m "refactor(lsp): split lspconfig.lua server configs into per-server files under lua/lsp/servers/"
```

---

## Task 16: Create `lang/dotnet/dap.lua` (move netcoredbg helper)

**Files:**
- Create: `lua/lang/dotnet/dap.lua`
- Delete: `lua/user/dap/netcoredbg.lua` (and `lua/user/dap/`, `lua/user/` if empty)
- Modify: `lua/plugins/testing.lua:21` (require path)

- [ ] **Step 1: Move the file**

```bash
mkdir -p lua/lang/dotnet
git mv lua/user/dap/netcoredbg.lua lua/lang/dotnet/dap.lua
rmdir lua/user/dap 2>/dev/null || true
rmdir lua/user 2>/dev/null || true
```

- [ ] **Step 2: Update require path in testing.lua**

Old (`testing.lua:21`):
```lua
      require("user.dap.netcoredbg").setup_adapter(dap)
```
New:
```lua
      require("lang.dotnet.dap").setup_adapter(dap)
```

- [ ] **Step 3: Smoke-test**

Run: `rg -n "user\.dap|user/dap" /home/derek/.config/nvim`
Expected: zero matches.

Run:
```bash
nvim --headless -c "lua print(type(require('lang.dotnet.dap').setup_adapter))" -c "qa"
```
Expected: `function`.

- [ ] **Step 4: Commit**

```bash
git add lua/lang/dotnet/dap.lua lua/plugins/testing.lua
git commit -m "refactor(dotnet): move netcoredbg DAP helper to lua/lang/dotnet/dap.lua"
```

---

## Task 17: Extract neotest-dotnet adapter into `lang/dotnet/neotest.lua`

**Files:**
- Create: `lua/lang/dotnet/neotest.lua`
- Modify: `lua/plugins/testing.lua`

- [ ] **Step 1: Create the adapter module**

Create `lua/lang/dotnet/neotest.lua`:

```lua
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
```

- [ ] **Step 2: Replace inline adapter in testing.lua**

Old (`testing.lua:43-50`):
```lua
        adapters = {
          require "neotest-dotnet" {
            discovery_root = "solution",
            dap = {
              justMyCode = false,
              adapter_name = "netcoredbg",
            },
          },
          require "neotest-phpunit" {
```
New:
```lua
        adapters = {
          require("lang.dotnet.neotest").adapter(),
          require "neotest-phpunit" {
```

- [ ] **Step 3: Smoke-test**

Run:
```bash
nvim --headless -c "lua print(type(require('lang.dotnet.neotest').adapter))" -c "qa"
```
Expected: `function`.

- [ ] **Step 4: Commit**

```bash
git add lua/lang/dotnet/neotest.lua lua/plugins/testing.lua
git commit -m "refactor(dotnet): extract neotest-dotnet adapter into lang/dotnet/neotest.lua"
```

---

## Task 18: Move `plugins/dotnet.lua` body into `lang/dotnet/init.lua` and enable Razor cohosting

**Files:**
- Create: `lua/lang/dotnet/init.lua`
- Modify: `lua/plugins/dotnet.lua` (slim to plugin spec)

The current `plugins/dotnet.lua` is 123 lines. We split it: the lazy spec (~15 lines) stays in `plugins/dotnet.lua`, and the actual configuration moves to `lang/dotnet/init.lua`.

Razor cohosting on Neovim 0.12+ with current Roslyn is **enabled by default** — no explicit setting required. The current `roslyn.setup{}` call already works; we just remove the README caveat in Task 20.

- [ ] **Step 1: Create `lua/lang/dotnet/init.lua`**

```lua
-- Roslyn LSP + Razor cohosting setup for C# / Razor / CSHTML.
-- Called from plugins/dotnet.lua config body.

local M = {}

function M.setup()
  vim.filetype.add {
    pattern = {
      [".*%.razor"] = "razor",
      [".*%.cshtml"] = "cshtml",
    },
  }

  local on_attach = require "lsp.on_attach"
  local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  local capabilities = cmp_nvim_lsp_ok
      and cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
    or vim.lsp.protocol.make_client_capabilities()

  local function roslyn_on_attach(client, bufnr)
    on_attach(client, bufnr)

    local opts = { buffer = bufnr, noremap = true, silent = true }

    -- Diagnostic floats — kept under <leader>l namespace to stay out of <leader>d (DAP).
    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "]d", function()
      vim.diagnostic.jump { count = 1, float = true }
    end, opts)
    vim.keymap.set("n", "[d", function()
      vim.diagnostic.jump { count = -1, float = true }
    end, opts)
    vim.keymap.set("n", "<leader>lD", function()
      local diags = vim.diagnostic.get(bufnr)
      print(vim.inspect(#diags > 0 and diags or "No diagnostics"))
    end, opts)

    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    if client.server_capabilities.codeLensProvider then
      local group = vim.api.nvim_create_augroup("RoslynCodeLens" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.codelens.refresh,
      })
      -- Roslyn needs a few seconds to index the solution before codelens data is ready.
      vim.defer_fn(vim.lsp.codelens.refresh, 4000)
    end

    vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.refresh, vim.tbl_extend("force", opts, {
      desc = "Refresh code lens",
    }))
  end

  vim.lsp.config("roslyn", {
    capabilities = capabilities,
    on_attach = roslyn_on_attach,
    settings = {
      ["csharp|background_analysis"] = {
        -- openFiles keeps Roslyn from indexing the entire solution on attach,
        -- which freezes Neovim for minutes on large repos.
        -- :Roslyn restart after flipping to "fullSolution" temporarily.
        dotnet_analyzer_diagnostics_scope = "openFiles",
        dotnet_compiler_diagnostics_scope = "openFiles",
      },
      ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
        dotnet_enable_tests_code_lens = true,
      },
      ["csharp|completion"] = {
        dotnet_show_completion_items_from_unimported_namespaces = true,
        dotnet_show_name_completion_suggestions = true,
      },
      ["csharp|formatting"] = {
        dotnet_organize_imports_on_format = true,
      },
      ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_implicit_object_creation = true,
        csharp_enable_inlay_hints_for_implicit_variable_types = true,
        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
        csharp_enable_inlay_hints_for_types = true,
        dotnet_enable_inlay_hints_for_object_creation_parameters = true,
        dotnet_enable_inlay_hints_for_other_parameters = true,
        dotnet_enable_inlay_hints_for_parameters = true,
        dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      },
      ["csharp|symbol_search"] = {
        dotnet_search_reference_assemblies = true,
      },
    },
  })

  require("roslyn").setup {
    -- "roslyn": file watching is delegated to the Roslyn server itself — more
    -- efficient than libuv inotify, especially under WSL2 and on large solutions.
    filewatching = "roslyn",
    -- Default to narrow solution discovery; flip to true only for repos where
    -- projects live outside the solution root.
    broad_search = false,
    lock_target = false,
    silent = true,
    -- Razor cohosting is enabled by default on Neovim 0.12+ with
    -- roslyn-language-server >= 5.8.0-1.26262.10 — no explicit flag needed.
  }
end

return M
```

- [ ] **Step 2: Slim `lua/plugins/dotnet.lua`**

Replace the entire file with:

```lua
return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor", "cshtml" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("lang.dotnet").setup()
    end,
    keys = {
      { "<leader>ct", "<cmd>Roslyn target<cr>", desc = "Roslyn target" },
      { "<leader>cR", "<cmd>Roslyn restart<cr>", desc = "Roslyn restart" },
    },
  },
}
```

- [ ] **Step 3: Smoke-test**

Run:
```bash
nvim --headless -c "lua print(type(require('lang.dotnet').setup))" -c "qa"
```
Expected: `function`.

- [ ] **Step 4: Commit**

```bash
git add lua/lang/dotnet/init.lua lua/plugins/dotnet.lua
git commit -m "refactor(dotnet): move Roslyn config body into lang/dotnet/init.lua, slim plugin spec"
```

---

## Task 19: Use `core.platform` in `neo-tree.lua` (replace direct `vim.g` reads)

**Files:**
- Modify: `lua/plugins/neo-tree.lua:193`

- [ ] **Step 1: Replace the inline detection**

Old (`neo-tree.lua:193`):
```lua
          use_libuv_file_watcher = vim.g.is_windows and not vim.g.is_wsl,
```
New:
```lua
          use_libuv_file_watcher = require("core.platform").is_windows,
```

(`core.platform.is_windows` is true only for native Windows, false on WSL — so the `and not vim.g.is_wsl` clause becomes redundant.)

- [ ] **Step 2: Smoke-test**

Run:
```bash
nvim --headless -c "lua print(require('core.platform').is_windows)" -c "qa"
```
Expected: `false` (on WSL) or `true` (on native Windows). No error.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/neo-tree.lua
git commit -m "refactor(neo-tree): use core.platform.is_windows instead of vim.g"
```

---

## Task 20: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Bump Neovim prereq to 0.12+**

Find and replace in `README.md`:
- `Neovim 0.11+` → `Neovim 0.12+`
- The line `Neovim 0.11+ \| \`winget install Neovim.Neovim\` or Scoop` → `Neovim 0.12+ \| \`winget install Neovim.Neovim\` or Scoop`

- [ ] **Step 2: Remove the Razor cohosting caveat**

Find the **Version note** block at the bottom of the C# section:
```
- **Version note**: newer upstream `roslyn.nvim` Razor co-hosting guidance targets Neovim 0.12+; this config currently runs on Neovim 0.11.x
```
Delete that bullet line. Razor cohosting is now active.

- [ ] **Step 3: Update the Architecture tree**

Replace the existing tree block (around line 46-58) with:

```text
~/.config/nvim/
├── init.lua                  # Bootstraps lazy.nvim, loads core modules
├── lua/
│   ├── core/                 # Platform detection, options, keymaps, health
│   │   ├── platform.lua      # OS detection, native Windows shell, clipboard
│   │   ├── options.lua       # Core vim options
│   │   ├── keymaps.lua       # Global keymaps (DAP, buffers, clipboard)
│   │   └── health.lua        # :ConfigHealth checks
│   ├── lsp/                  # LSP scaffolding
│   │   ├── on_attach.lua     # Shared LSP keymaps (gd, gr, gi, K, …)
│   │   └── servers/          # One file per server config
│   ├── lang/                 # Per-language modules
│   │   └── dotnet/           # roslyn + netcoredbg + neotest-dotnet
│   ├── plugins.lua           # Auto-loader for everything in plugins/
│   └── plugins/              # One file per plugin (auto-loaded)
│       └── extras/           # Optional plugins (vim.g.enabled_extra_plugins)
```

- [ ] **Step 4: Remove `.py`, Python, and Django references from the LSP table**

Find the LSP table (around line 68). Remove the rows for `.py` and any Django/`htmldjango` mentions. The Python row to delete:

```
| `.py` | pyright · ruff |
```

- [ ] **Step 5: Remove Python/Django mentions from the Formatting section**

Find the conform.nvim section (around line 250-258). Remove sentences referencing Python (`isort`, `black`) and Django (`djlint`):
- `Python uses \`isort\` + \`black\`.` → delete.

- [ ] **Step 6: Smoke-test**

Run: `rg -n -i "python|django|jupyter|notebook|pyright|ruff|isort|black|java" README.md`
Expected: zero relevant matches (a stray match in unrelated context — e.g. `javascript` — is fine; review each).

- [ ] **Step 7: Commit**

```bash
git add README.md
git commit -m "docs: update README for Neovim 0.12+ baseline, new tree layout, drop Python/Java"
```

---

## Task 21: Final smoke test

**Files:** none (verification only)

- [ ] **Step 1: Lazy sync**

Open Neovim interactively. Run `:Lazy sync`.
Expected: all plugins resolve; no errors. `notebook.lua` no longer appears in the plugin list.

- [ ] **Step 2: Mason inventory**

Run `:Mason`.
Expected: installed list does NOT include `pyright`, `ruff`, `black`, `isort`, `debugpy`, `djlint`, `google-java-format`. Click "uninstall" on any that linger from prior runs (or run `:MasonUninstall pyright ruff black isort debugpy djlint google-java-format`).

- [ ] **Step 3: Health check**

Run `:ConfigHealth`.
Expected: all `[OK]` rows for git, rg, fd, dotnet, node, npm; new `[OK] dotnet SDK >= 8` line; on Windows `[OK] vim shell is pwsh`; on WSL `[OK] win32yank.exe`.

Run `:checkhealth nvim-treesitter`.
Expected: all installed parsers report OK; no `python`/`htmldjango`/`java` in the install list.

- [ ] **Step 4: C# round trip**

Open a real `.cs` file in a project with a `.sln`.
Expected:
- Roslyn attaches within ~10s (see `:LspInfo`).
- `gd` jumps to definition.
- `<leader>ld` shows diagnostics.
- `:Format` runs csharpier and reformats.
- Open the file's test, `<leader>td` launches the netcoredbg debugger.

- [ ] **Step 5: Razor round trip**

Open a `.razor` file.
Expected:
- Roslyn attaches (cohosting handles HTML + C#).
- Treesitter razor parser highlights markup.
- `gd` on a method jumps to its C# definition.

- [ ] **Step 6: Windows-only smoke (skip on WSL/Linux)**

On native Windows:
- `:!git status` runs without quoting errors.
- `:LazyGit` opens and closes cleanly.
- `<C-\>` opens a pwsh terminal (not cmd.exe).

- [ ] **Step 7: Final commit (only if anything stragglers were caught)**

```bash
git status
# If clean, no commit. If something needed cleanup:
git commit -m "chore: post-refactor cleanup"
```

---

## Summary

| # | Task | Files touched |
|---|---|---|
| 0 | Install Neovim 0.12+ | env |
| 1 | `vim.loop` → `vim.uv` | init.lua, colors-highlight.lua |
| 2 | Create `core/platform.lua` | new |
| 3 | Migrate options → `core/options.lua` | options + init.lua |
| 4 | Migrate keymaps → `core/keymaps.lua`, drop Java | keymaps + init.lua |
| 5 | Remove Python from mason | mason.lua |
| 6 | Remove Python from lspconfig | lspconfig.lua |
| 7 | Remove Python/Java from conform | conform-formatter.lua |
| 8 | Remove Python from testing | testing.lua |
| 9 | Remove Python/Django/Java from treesitter | treesitter.lua |
| 10 | Delete notebook plugin | notebook.lua |
| 11 | Delete dead code (coc, formatter, toggleterm dup) | 3 files |
| 12 | Migrate health → `core/health.lua` + new checks | health.lua |
| 13 | Migrate `on_attach` → `lsp/on_attach.lua` | 3 files |
| 14 | Drop pre-0.12 fallback branches | lspconfig.lua |
| 15 | Split lspconfig into `lsp/servers/*` | 13 new + lspconfig.lua |
| 16 | Move netcoredbg → `lang/dotnet/dap.lua` | 2 files |
| 17 | Extract neotest adapter → `lang/dotnet/neotest.lua` | 2 files |
| 18 | Move dotnet config → `lang/dotnet/init.lua`, enable Razor cohost | 2 files |
| 19 | Use `core.platform` in `neo-tree.lua` | neo-tree.lua |
| 20 | README update | README.md |
| 21 | Final smoke test | env |

Expect ~21 commits, all small and bisectable.
