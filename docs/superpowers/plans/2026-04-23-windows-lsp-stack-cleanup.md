# Windows-Centric Config + LSP Stack Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the config natively Windows-first with OS auto-detection, eliminate LSP server overload on React/PHP/Razor files, fix Roslyn performance on large .NET codebases, and update the README to reflect the actual React + C# .NET + PHP CodeIgniter stack.

**Architecture:** Single unified config with a `vim.g.is_windows` / `vim.g.is_wsl` flag set once in `vim-options.lua` and consumed wherever OS-specific behavior is needed (clipboard, shell). LSP scoping is fixed by removing incorrect filetypes from `emmet_ls` and `html` servers. Roslyn gets `openFiles` scope + `filewatching = "roslyn"` for large solution performance.

**Tech Stack:** Neovim 0.11+, lazy.nvim, mason.nvim, typescript-tools.nvim, roslyn.nvim, intelephense, conform.nvim

---

## Files Modified

| File | What changes |
|---|---|
| `lua/vim-options.lua` | Add `is_windows`/`is_wsl` flags; make clipboard OS-aware |
| `lua/plugins/toggleterminal.lua` | Windows shell: `pwsh` → `powershell` → nil fallback |
| `lua/plugins/lspconfig.lua` | Remove JSX/TSX from `emmet_ls`; remove PHP/razor/cshtml from `html`; fix intelephense paths |
| `lua/plugins/dotnet.lua` | Roslyn `openFiles` scope; `filewatching = "roslyn"`; fix `<leader>d` → `<leader>ld` keymap collision |
| `README.md` | Full rewrite: actual stack, Windows setup, all keymaps, platform notes |

---

## Task 1: OS Detection + Clipboard

**Files:**
- Modify: `lua/vim-options.lua` (top of file, before clipboard block)

### What this fixes
Currently `vim.g.clipboard` is always set to win32yank, which errors on native Windows Neovim (clipboard works natively there). On WSL it's correct. On plain Linux it's unnecessary.

- [ ] **Step 1: Add OS flags and fix clipboard in `vim-options.lua`**

Replace the entire `vim.g.clipboard` block (lines 49-60) with:

```lua
-- OS detection — set once, consumed by clipboard, shell, and path configs
local is_windows = vim.fn.has "win32" == 1
local is_wsl = vim.fn.has "wsl" == 1
vim.g.is_windows = is_windows
vim.g.is_wsl = is_wsl

-- Clipboard:
--   Native Windows → Neovim handles clipboard automatically (no config needed)
--   WSL            → win32yank.exe bridges to the Windows clipboard
--   Native Linux   → Neovim auto-detects xsel/xclip/wl-copy (no config needed)
if is_wsl then
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
```

- [ ] **Step 2: Verify in Neovim**

Open Neovim (in WSL to test WSL path, or Windows to test Windows path):
```
:lua print(vim.g.is_windows, vim.g.is_wsl)
:lua print(vim.g.clipboard and vim.g.clipboard.name or "native")
```
Expected on WSL: `false  true` / `win32yank-wsl`
Expected on Windows: `true  false` / `native`

- [ ] **Step 3: Commit**

```bash
git add lua/vim-options.lua
git commit -m "feat: OS-aware clipboard and detection flags (Windows-first)"
```

---

## Task 2: ToggleTerm Windows Shell

**Files:**
- Modify: `lua/plugins/toggleterminal.lua` (inside `require("toggleterm").setup { ... }`)

### What this fixes
`shell = nil` defers to `vim.o.shell`. On native Windows that is `cmd.exe` — terrible for development. Should use PowerShell 7 (`pwsh`) with fallback to Windows PowerShell 5 (`powershell`).

- [ ] **Step 1: Replace `shell = nil` in toggleterm setup**

```lua
-- Shell selection: pwsh (PS7) → powershell (PS5) → system default
local function pick_shell()
  if vim.g.is_windows then
    if vim.fn.executable "pwsh" == 1 then
      return "pwsh"
    elseif vim.fn.executable "powershell" == 1 then
      return "powershell"
    end
  end
  return nil -- inherits vim.o.shell (bash/zsh on Linux/WSL)
end

require("toggleterm").setup {
  -- ... existing options ...
  shell = pick_shell(),
  -- ... rest of options ...
}
```

Place the `pick_shell` function before `require("toggleterm").setup { ... }` (around line 70).
Replace `shell = nil,` with `shell = pick_shell(),`.

- [ ] **Step 2: Verify on Windows**

Open a ToggleTerm terminal (`<C-\>`) and run:
```
$PSVersionTable
```
Expected: PowerShell version info (not cmd.exe prompt).

On WSL/Linux: open terminal, should still use bash/zsh.

- [ ] **Step 3: Commit**

```bash
git add lua/plugins/toggleterminal.lua
git commit -m "feat: use PowerShell on Windows in ToggleTerm (pwsh → powershell fallback)"
```

---

## Task 3: LSP Server Scoping

**Files:**
- Modify: `lua/plugins/lspconfig.lua` (server_configs table)

### What this fixes

**Before** (servers attaching per filetype):
| File type | Servers | Count |
|---|---|---|
| `.tsx` | typescript-tools + eslint + biome + tailwindcss + **emmet_ls** | **5** |
| `.php` | intelephense + **html** + tailwindcss + **emmet_ls** | **4** |
| `.razor` | roslyn + **html** + tailwindcss | **3** |

**After:**
| File type | Servers | Count |
|---|---|---|
| `.tsx` | typescript-tools + eslint/biome + tailwindcss | **3** |
| `.php` | intelephense + tailwindcss | **2** |
| `.razor` | roslyn + tailwindcss | **2** |

**Three changes in `server_configs`:**

- [ ] **Step 1: Remove JSX/TSX from emmet_ls filetypes**

Find `emmet_ls = {` block. Change:
```lua
emmet_ls = {
  filetypes = {
    "html",
    "htmldjango",
    "javascriptreact",   -- REMOVE: typescript-tools handles completions
    "typescriptreact",   -- REMOVE: typescript-tools handles completions
    "css",
    "scss",
    "sass",
    "svelte",
    "vue",
    "php",
    "blade",
  },
```
To:
```lua
emmet_ls = {
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
```

- [ ] **Step 2: Remove PHP/Razor/CSHTML from html server filetypes**

Find `html = { filetypes = { ... } }`. Change:
```lua
html = { filetypes = { "html", "htmldjango", "blade", "razor", "cshtml" } },
```
To:
```lua
-- "razor"/"cshtml" removed: roslyn handles Razor HTML completely
-- "php" removed: intelephense handles embedded HTML in PHP files
html = { filetypes = { "html", "htmldjango", "blade" } },
```

- [ ] **Step 3: Fix intelephense includePaths for CodeIgniter**

Find `intelephense = {` block. Change:
```lua
intelephense = {
  filetypes = { "php", "blade" },
  settings = {
    intelephense = {
      environment = {
        includePaths = {
          "vendor/laravel/framework/src",   -- REMOVE: Laravel-specific, irrelevant for CodeIgniter
        },
      },
      files = {
        maxSize = 5000000,
      },
    },
  },
},
```
To:
```lua
intelephense = {
  filetypes = { "php", "blade" },
  settings = {
    intelephense = {
      files = {
        maxSize = 5000000,
      },
      -- CodeIgniter 4 is installed via Composer; intelephense indexes vendor/ automatically.
      -- No custom includePaths needed.
      stubs = {
        "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core",
        "ctype", "curl", "date", "dba", "dom", "enchant", "exif",
        "FFI", "fileinfo", "filter", "fpm", "ftp", "gd", "gettext",
        "gmp", "hash", "iconv", "imap", "intl", "json", "ldap",
        "libxml", "mbstring", "meta", "mysqli", "oci8", "odbc",
        "openssl", "pcntl", "pcre", "PDO", "pdo_ibm", "pdo_mysql",
        "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar", "posix",
        "pspell", "readline", "Reflection", "session", "SimpleXML",
        "soap", "sockets", "sodium", "SPL", "sqlite3", "standard",
        "superglobals", "sysvmsg", "sysvsem", "sysvshm", "tidy",
        "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter",
        "xsl", "Zend OPcache", "zip", "zlib",
      },
    },
  },
},
```

- [ ] **Step 4: Verify server counts in Neovim**

Open a `.tsx` file, then:
```
:LspInfo
```
Expected: typescript-tools + tailwindcss (+ eslint if .eslintrc exists). **No emmet_ls.**

Open a `.php` file:
```
:LspInfo
```
Expected: intelephense (+ tailwindcss if tailwind.config present). **No html server.**

Open a `.razor` file:
```
:LspInfo
```
Expected: roslyn (+ tailwindcss if applicable). **No html server.**

- [ ] **Step 5: Commit**

```bash
git add lua/plugins/lspconfig.lua
git commit -m "fix: scope LSP servers correctly — remove emmet_ls from TSX, html from PHP/Razor"
```

---

## Task 4: Roslyn Performance + Keymap Fix

**Files:**
- Modify: `lua/plugins/dotnet.lua`

### What this fixes
1. `"fullSolution"` scope makes Roslyn analyze **every** `.cs` file on attach — causes freeze on large codebases. The correct value is `"openFiles"` (verified from roslyn.nvim docs; note: NOT `"openFilesOnly"`).
2. `filewatching` defaults to `"auto"` which uses libuv inotify on Linux/WSL. Setting `"roslyn"` delegates file watching to the Roslyn server which is more efficient.
3. `<leader>d` in this file collides with DAP keymaps (`<leader>db`, `<leader>dr`) — must be `<leader>ld` to match lspconfig.lua.
4. Code lens refresh on `CursorHold` fires every 800 ms while idle — change to `BufEnter + InsertLeave` only.

- [ ] **Step 1: Fix diagnostics scope values**

Find the `["csharp|background_analysis"]` block. Change:
```lua
["csharp|background_analysis"] = {
  dotnet_analyzer_diagnostics_scope = "fullSolution",
  dotnet_compiler_diagnostics_scope = "fullSolution",
},
```
To:
```lua
-- "openFiles": only analyze open files. Required for large solutions — "fullSolution"
-- causes Roslyn to index the entire repo on attach, freezing the editor.
-- To get full-solution diagnostics temporarily, use :Roslyn restart after changing back.
["csharp|background_analysis"] = {
  dotnet_analyzer_diagnostics_scope = "openFiles",
  dotnet_compiler_diagnostics_scope = "openFiles",
},
```

- [ ] **Step 2: Set filewatching to roslyn**

Find `require("roslyn").setup {`. Change:
```lua
require("roslyn").setup {
  broad_search = true,
  lock_target = false,
  silent = true,
}
```
To:
```lua
require("roslyn").setup {
  -- "roslyn": delegates file watching to the Roslyn server (more efficient than libuv).
  -- "auto" would use libuv on Linux/WSL which is slower for large .NET solutions.
  filewatching = "roslyn",
  broad_search = true,
  lock_target = false,
  silent = true,
}
```

- [ ] **Step 3: Fix code lens refresh events**

Find the `create_autocmd` block for code lens. Change:
```lua
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
```
To:
```lua
-- CursorHold removed: fires every 800ms while idle, causes constant server round-trips.
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
```

- [ ] **Step 4: Fix keymap collision `<leader>d` → `<leader>ld`**

Find in `roslyn_on_attach`:
```lua
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
```
Change to:
```lua
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
```

Also find:
```lua
vim.keymap.set("n", "<leader>dD", function()
```
Change to:
```lua
vim.keymap.set("n", "<leader>lD", function()
```

- [ ] **Step 5: Verify in Neovim**

Open a `.cs` file, then check:
```
:LspInfo
```
Expected: roslyn attached, no other LSP on plain `.cs` file.

Check keymaps don't conflict:
```
:map <leader>d
```
Expected: only DAP-related maps (db, dr, dT, dso, dsi, dsu) — no diagnostic float on bare `<leader>d`.

- [ ] **Step 6: Commit**

```bash
git add lua/plugins/dotnet.lua
git commit -m "perf: Roslyn openFiles scope + roslyn filewatcher; fix <leader>d DAP collision"
```

---

## Task 5: README Rewrite

**Files:**
- Modify: `README.md`

### What this updates
- Title reflects actual stack: React/TypeScript + C# .NET + PHP CodeIgniter
- Platform Support section (Windows native, WSL, Linux)
- LSP section with server counts per filetype
- All missing keymaps added: `<leader>ld`, `<leader>lD`, `<leader>lr`, `<leader>li`, `<leader>lh`, `<leader>ls`, `<leader>lw`, Hunk keymaps
- Windows-specific setup instructions (PowerShell, .NET SDK, win32yank)
- Stack-specific notes updated (remove Django references from the main stack)

- [ ] **Step 1: Rewrite README.md**

Full content (replace entire file):

```markdown
# Blackvortex Neovim Configuration

A fast, modular Neovim configuration for full-stack development — React/TypeScript, C# .NET (Razor), and PHP (CodeIgniter). Powered by `lazy.nvim`.

## Platform Support

| Platform | Status | Notes |
|---|---|---|
| **Windows (native)** | ✅ Primary | Clipboard auto-detected; ToggleTerm uses PowerShell |
| **WSL2** | ✅ Supported | Clipboard via `win32yank.exe`; shell inherits bash/zsh |
| **Linux (native)** | ✅ Supported | Clipboard auto-detected (xsel/xclip/wl-copy) |

### Windows Prerequisites
- [Neovim 0.11+](https://github.com/neovim/neovim/releases) via `winget install Neovim.Neovim` or Scoop
- [PowerShell 7](https://aka.ms/powershell) (`pwsh`) — used by ToggleTerm
- [Git for Windows](https://gitforwindows.org/) — required by lazy.nvim
- [ripgrep](https://github.com/BurntSushi/ripgrep) + [fd](https://github.com/sharkdp/fd) — required by Telescope
- [.NET SDK](https://dotnet.microsoft.com/) — required by Roslyn (C# LSP)
- A [Nerd Font](https://www.nerdfonts.com/) set in your terminal for icons

### WSL Prerequisites
- `win32yank.exe` in PATH (copy from Windows side: `cp /mnt/c/path/to/win32yank.exe ~/.local/bin/`)
- ripgrep + fd: `sudo apt install ripgrep fd-find`

---

## Architecture

```text
~/.config/nvim/
├── init.lua              # Bootstraps lazy.nvim, loads vim-options + keymaps
├── lua/
│   ├── vim-options.lua   # Core settings, OS detection flags, large-file guard
│   ├── keymaps.lua       # Global keybindings (DAP, bufferline, clipboard)
│   ├── plugins.lua       # Auto-loader: discovers all files in plugins/ and extras/
│   ├── user/
│   │   ├── icons.lua     # Shared icon table
│   │   └── lsp/
│   │       └── on_attach.lua  # Shared LSP keymaps (gd, gr, gi, gt, K, etc.)
│   └── plugins/          # One file per plugin
│       └── extras/       # Optional plugins — enabled via vim.g.enabled_extra_plugins
```

Any `.lua` file in `lua/plugins/` is auto-loaded. Extra plugins in `lua/plugins/extras/` load only when their name appears in `vim.g.enabled_extra_plugins` (set in `vim-options.lua`).

---

## LSP Stack

Servers are scoped tightly — each filetype gets only what it needs:

| Filetype | Servers |
|---|---|
| `.ts` / `.tsx` (React) | typescript-tools · eslint (if .eslintrc) · biome (if biome.json) · tailwindcss (if tailwind.config) |
| `.js` / `.jsx` | typescript-tools · eslint/biome · tailwindcss |
| `.cs` (C#) | roslyn |
| `.razor` / `.cshtml` | roslyn · tailwindcss |
| `.php` (CodeIgniter) | intelephense · tailwindcss |
| `.blade.php` | intelephense · tailwindcss |
| `.html` | html · tailwindcss |
| `.py` | pyright · ruff |
| `.lua` | lua_ls |
| `.css` / `.scss` | cssls · tailwindcss |

Roslyn diagnostics are scoped to **open files only** by default (prevents freezing large solutions). Run `:Roslyn restart` if you temporarily need full-solution analysis.

---

## Keymaps

`<leader>` = `<Space>`

### General & Window Navigation
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Navigate splits / Tmux panes |
| `<M-k>` / `<M-j>` | Move line up/down (Normal, Insert, Visual) |
| `<C-b>` | Delete word backward (Insert) |
| `<C-v>` | Paste from system clipboard |
| `<leader>c` / `<leader>cc` | Copy selection / Copy line to clipboard |
| `<leader>wr` | Toggle word wrap |
| `<leader>h` | Clear search highlight |

### Buffer Navigation
| Key | Action |
|---|---|
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<leader>x` | Close current buffer |
| `<leader>X` | Close all other buffers |
| `<leader>bp` | Toggle pin |
| `<leader>bo` | Pick buffer by letter |
| `<leader>bb` | Fuzzy-find open buffers |

### File Explorer (neo-tree)
| Key | Action |
|---|---|
| `<leader>e` | Toggle Neo-tree (right) |
| `<leader>n` | Focus Neo-tree |
| `<leader>bf` | Show buffers in floating Neo-tree |
| `<leader>fs` | Show filesystem in floating Neo-tree |
| `<leader>wp` | Pick window |

### Fuzzy Finding (Telescope)
| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>fl` | Resume last search |
| `<leader>fc` | Change colorscheme |
| `<leader>fb` | Git branches |

### LSP & Code Navigation
| Key | Action |
|---|---|
| `gd` | Go to Definition |
| `gD` | Go to Declaration |
| `gi` | Go to Implementation |
| `gr` | Find References |
| `gt` | Go to Type Definition |
| `gK` | Signature Help |
| `<leader>ca` | Code Action |
| `<leader>rn` | Rename symbol |
| `<leader>ls` | Document symbols |
| `<leader>lw` | Workspace symbols |
| `<leader>lh` | Toggle inlay hints |
| `<leader>lr` | Restart LSP |
| `<leader>li` | LSP info |

### Diagnostics
| Key | Action |
|---|---|
| `<leader>ld` | Open diagnostic float (focusable; yank with `<C-y>`) |
| `<leader>lD` | Inspect raw diagnostics |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |

### C# / Roslyn
| Key | Action |
|---|---|
| `<leader>ct` | Select Roslyn solution target |
| `<leader>cR` | Restart Roslyn |

### Formatting (conform.nvim)
| Key | Action |
|---|---|
| `<leader>mp` | Format file or range |
| `<leader>mf` | Toggle auto-format on save |

### Debugging (nvim-dap)
| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dr` | Continue |
| `<leader>dT` | Terminate |
| `<leader>dso` | Step over |
| `<leader>dsi` | Step into |
| `<leader>dsu` | Step out |
| `<leader>dus` | Open DAP sidebar |

### Testing (neotest)
| Key | Action |
|---|---|
| `<leader>tn` | Run nearest test |
| `<leader>tf` | Run file tests |
| `<leader>ts` | Run full suite |
| `<leader>td` | Debug nearest test |
| `<leader>tt` | Toggle test summary |
| `<leader>to` | Open test output |
| `<leader>tl` | Re-run last test |

### Git (gitsigns + lazygit)
| Key | Action |
|---|---|
| `<leader>gg` | Open LazyGit |
| `]h` / `[h` | Next / previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hS` | Stage buffer |
| `<leader>hR` | Reset buffer |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Toggle line blame |
| `<leader>hd` | Diff this file |

### Terminal (ToggleTerm)
| Key | Action |
|---|---|
| `<C-\>` | Toggle terminal (float) |
| `<M-1>` | Horizontal terminal |
| `<M-2>` | Vertical terminal |
| `<M-3>` | Floating terminal |

---

## Stack Notes

**React / TypeScript**
- LSP: `typescript-tools.nvim` (native tsserver API, no LSP adapter overhead)
- Formatting: Biome (if `biome.json` present) → prettierd fallback
- Linting: ESLint (scoped to projects with `.eslintrc*`) or Biome

**C# / ASP.NET Core**
- LSP: `roslyn.nvim` — requires `roslyn` installed via Mason (`:MasonInstall roslyn`)
- Diagnostics scoped to open files by default; full-solution available via `:Roslyn restart`
- Debugging: `netcoredbg` via Mason + nvim-dap
- Razor/CSHTML: handled entirely by Roslyn (no separate html LSP needed)

**PHP / CodeIgniter 4**
- LSP: `intelephense` — indexes `vendor/` automatically from `composer.json` root
- Formatting: `php-cs-fixer` via conform.nvim
- No additional stubs needed; standard PHP stubs cover CodeIgniter 4 core
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: rewrite README for React/TS + C#.NET + PHP CodeIgniter stack"
```

---

## Self-Review

**Spec coverage check:**
- ✅ OS detection (Task 1)
- ✅ Clipboard Windows-native vs WSL (Task 1)
- ✅ ToggleTerm PowerShell on Windows (Task 2)
- ✅ emmet_ls scoping (Task 3)
- ✅ html server scoping for PHP/Razor (Task 3)
- ✅ intelephense CodeIgniter tuning (Task 3)
- ✅ Roslyn diagnostics scope `openFiles` (Task 4)
- ✅ Roslyn `filewatching = "roslyn"` (Task 4)
- ✅ Code lens CursorHold removed (Task 4)
- ✅ `<leader>d` DAP collision fixed (Task 4)
- ✅ README rewrite (Task 5)

**Placeholder scan:** None found.

**Type consistency:** All keymap changes consistently use `<leader>ld` / `<leader>lD`. Roslyn scope value `"openFiles"` used consistently (not `"openFilesOnly"`).
