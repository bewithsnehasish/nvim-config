# Blackvortex Neovim Configuration

A fast, modular Neovim configuration for full-stack development: **React/TypeScript**, **C# / ASP.NET Core**, and **PHP / CodeIgniter 4**. Powered by `lazy.nvim`.

---

## Platform Support

| Platform | Status | Notes |
|---|---|---|
| **Windows (native)** | Primary | Clipboard handled automatically; ToggleTerm uses PowerShell |
| **WSL2** | Supported | Clipboard via `win32yank.exe`; shell inherits bash/zsh |
| **Linux (native)** | Supported | Clipboard auto-detected (xsel / xclip / wl-copy) |

### Windows Prerequisites

| Tool | Install |
|---|---|
| Neovim 0.11+ | `winget install Neovim.Neovim` or Scoop |
| PowerShell 7 | `winget install Microsoft.PowerShell` |
| Git for Windows | Required by lazy.nvim |
| ripgrep | `winget install BurntSushi.ripgrep.MSVC` |
| fd | `winget install sharkdp.fd` |
| .NET SDK | Required by Roslyn (C# LSP) — [dotnet.microsoft.com](https://dotnet.microsoft.com) |
| Nerd Font | Set in your terminal for icons (e.g. JetBrainsMono Nerd Font) |

### WSL2 Prerequisites

```bash
# Clipboard bridge (copy win32yank.exe from Windows side)
cp /mnt/c/path/to/win32yank.exe ~/.local/bin/ && chmod +x ~/.local/bin/win32yank.exe

# Search tools
sudo apt install ripgrep fd-find
```

---

## Architecture

```text
~/.config/nvim/
├── init.lua              # Bootstraps lazy.nvim; loads vim-options + keymaps
├── lua/
│   ├── vim-options.lua   # Core settings, OS detection flags, large-file guard
│   ├── keymaps.lua       # Global keybindings (DAP, bufferline, clipboard)
│   ├── plugins.lua       # Auto-loader: discovers all .lua files in plugins/
│   ├── user/
│   │   ├── icons.lua           # Shared icon table
│   │   └── lsp/on_attach.lua   # Shared LSP keymaps (gd, gr, gi, K, …)
│   └── plugins/          # One file per plugin (auto-loaded)
│       └── extras/       # Optional plugins — enabled via vim.g.enabled_extra_plugins
```

Any `.lua` file dropped into `lua/plugins/` is auto-loaded.
Files in `lua/plugins/extras/` load only when listed in `vim.g.enabled_extra_plugins` inside `vim-options.lua`.

---

## LSP Stack

Servers are tightly scoped — each filetype gets only what it needs:

| Filetype | Active servers |
|---|---|
| `.ts` / `.tsx` (React) | typescript-tools · eslint¹ · biome² · tailwindcss³ |
| `.js` / `.jsx` | typescript-tools · eslint¹ · biome² · tailwindcss³ |
| `.cs` (C#) | roslyn |
| `.razor` / `.cshtml` | roslyn · tailwindcss³ |
| `.php` (CodeIgniter) | intelephense · tailwindcss³ |
| `.blade.php` | intelephense · tailwindcss³ |
| `.html` | html · tailwindcss³ |
| `.css` / `.scss` | cssls · tailwindcss³ |
| `.py` | pyright · ruff |
| `.lua` | lua_ls |

¹ Only when `.eslintrc*` or `eslint.config.*` found in root  
² Only when `biome.json` found in root  
³ Only when `tailwind.config.*` or `tailwindcss` in `package.json` found in root

**Roslyn diagnostics** are scoped to open files by default (prevents freezing large
solutions on attach). Switch to full-solution analysis with `:Roslyn restart` after
changing `dotnet_analyzer_diagnostics_scope` to `"fullSolution"` in `dotnet.lua`.

---

## Keymaps

`<leader>` = `<Space>`

### General & Window Navigation

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Navigate splits / Tmux panes |
| `<M-k>` / `<M-j>` | Move line up / down (Normal, Insert, Visual) |
| `<C-b>` | Delete word backward (Insert) |
| `<C-v>` | Paste from system clipboard |
| `<leader>c` / `<leader>cc` | Copy selection / Copy line to clipboard |
| `<leader>wr` | Toggle word wrap |
| `<leader>h` | Clear search highlight |

### Buffer Navigation

| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>x` | Close current buffer |
| `<leader>X` | Close all other buffers |
| `<leader>bp` | Toggle buffer pin |
| `<leader>bo` | Pick buffer by letter |
| `<leader>bb` | Fuzzy-find open buffers |

### File Explorer (neo-tree)

| Key | Action |
|---|---|
| `<leader>e` | Toggle Neo-tree (right side) |
| `<leader>n` | Focus Neo-tree |
| `<leader>bf` | Buffers in floating Neo-tree |
| `<leader>fs` | Filesystem in floating Neo-tree |
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
| `K` | Hover / peek fold |
| `<leader>ca` | Code Action |
| `<leader>rn` | Rename symbol (inc-rename) |
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
| `]d` / `[d` | Next / previous diagnostic |

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

Formatter priority per filetype: **Biome** (if `biome.json`) → **prettierd** → LSP fallback.
PHP uses `php-cs-fixer`. Python uses `isort` + `black`. Lua uses `stylua`.

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
| `<C-\>` | Toggle floating terminal |
| `<M-1>` | Horizontal terminal |
| `<M-2>` | Vertical terminal |
| `<M-3>` | Floating terminal |

---

## Stack Notes

### React / TypeScript
- **LSP**: `typescript-tools.nvim` — native tsserver API (no LSP adapter overhead)
- **Formatting**: Biome (if `biome.json` present) → prettierd fallback
- **Linting**: ESLint (projects with `.eslintrc*`) or Biome (projects with `biome.json`)
- **Emmet**: Tab expansion works in JSX/TSX via `cmp-emmet-vim`; no separate emmet LSP attached

### C# / ASP.NET Core
- **LSP**: `roslyn.nvim` — install server via `:MasonInstall roslyn`
- **Diagnostics**: Open files only by default; full-solution available via `:Roslyn restart`
- **File watching**: Delegated to Roslyn server (`filewatching = "roslyn"`)
- **Debugger**: `netcoredbg` via Mason + nvim-dap
- **Razor / CSHTML**: Fully handled by Roslyn — no separate html LSP attached

### PHP / CodeIgniter 4
- **LSP**: `intelephense` — auto-indexes `vendor/` from `composer.json` root
- **Formatting**: `php-cs-fixer` via conform.nvim
- **Stubs**: Full standard PHP extension stubs included; CI4 framework indexed via vendor
- **No special setup needed** — intelephense finds CodeIgniter through Composer autoloader
