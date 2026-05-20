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
| CMake | `winget install Kitware.CMake` |
| C compiler | Visual Studio Build Tools or LLVM/MSYS2; required by nvim-treesitter |
| .NET SDK | Required by Roslyn (C# LSP) — [dotnet.microsoft.com](https://dotnet.microsoft.com) |
| Nerd Font | Set in your terminal for icons (e.g. JetBrainsMono Nerd Font) |

Run `:ConfigHealth` after installation to verify Windows/WSL shell, clipboard,
Mason, Roslyn, DAP, and treesitter prerequisites.

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
| `<Esc>` | Clear search highlight (normal mode) |

### Discoverability (which-key)

`which-key` shows all available keymaps grouped by namespace as you type `<leader>`.
Uses the **modern** preset (clean bottom popup) with named groups (`Find`, `Git`, `LSP`, …)
and per-keymap icons.

| Key | Action |
|---|---|
| `<leader>` | Wait → see all leader groups |
| `<leader>?` | Show buffer-local keymaps only (LSP-attached buffers reveal `gd`, `gr`, …) |
| `<leader>K` | Browse all leader keymaps (loop mode — keeps panel open) |

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

### Fuzzy Finding (snacks.nvim picker)

Picker layouts: `default` (centered float with right-side preview) for files/buffers,
`ivy` (full-width bottom panel) for grep and LSP references — gives readable previews
on wide code blocks.

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>fl` | Resume last search |
| `<leader>fc` | Change colorscheme |
| `<leader>fb` | Git branches |
| `<leader>fp` | Projects |
| `<leader>fh` | Help tags |
| `<leader>fk` | Search keymaps by description |

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

### Trouble (panel for diagnostics / references / lists)

| Key | Action |
|---|---|
| `<leader>xx` | Workspace diagnostics |
| `<leader>xb` | Buffer diagnostics |
| `<leader>xr` | LSP references panel |
| `<leader>xd` | LSP definitions panel |
| `<leader>xi` | LSP info panel (right side) |
| `<leader>xq` | Quickfix list |
| `<leader>xl` | Location list |

### Search & Replace (Spectre)

| Key | Action |
|---|---|
| `<leader>sr` | Project-wide search & replace |
| `<leader>sw` | Search word under cursor (Visual: search selection) |
| `<leader>sf` | Search & replace in current file |

### Harpoon (instant jump to marked files)

Mark 2–4 files you're actively editing, then jump between them with one keystroke.
Marks persist per project. Namespaced under `<leader>j` ("jump") to keep `<leader>h`
exclusive to gitsigns hunks.

| Key | Action |
|---|---|
| `<leader>ja` | Add (mark) current file |
| `<leader>jj` | Toggle quick menu |
| `<leader>jt` | Browse marks in snacks picker (with preview) |
| `<leader>1` … `<leader>4` | Jump to slot 1–4 |
| `<leader>jn` / `<leader>jp` | Cycle next / previous |

### Reference Highlighting (vim-illuminate)

Auto-highlights the word under the cursor and lets you jump between occurrences.

| Key | Action |
|---|---|
| `]r` / `[r` | Next / previous reference of word under cursor |

### C# / Roslyn

| Key | Action |
|---|---|
| `<leader>ct` | Select Roslyn solution target |
| `<leader>cR` | Restart Roslyn |

### Code Folding (nvim-ufo)

Powered by LSP + treesitter. Folded blocks show a line count: `▶ public class OrgService {··· 23 lines`

| Key | Action |
|---|---|
| `za` | Toggle fold under cursor (collapse / expand) |
| `zc` / `zo` | Close / open fold under cursor |
| `zM` | Close ALL folds in file |
| `zR` | Open ALL folds in file |
| `zm` / `zr` | Close / open folds one level at a time |
| `zj` / `zk` | Jump to next / previous fold |
| `[z` / `]z` | Jump to start / end of current fold |

### Formatting (conform.nvim)

| Key | Action |
|---|---|
| `<leader>mp` | Format file or range |
| `<leader>mf` | Toggle auto-format on save |

Formatter priority per filetype: **Biome** (if `biome.json`) → **prettierd** → LSP fallback.
PHP uses `php-cs-fixer`. Python uses `isort` + `black`. Lua uses `stylua`.
**C# / Razor / CSHTML** use `csharpier` (installed via Mason); falls back to Roslyn LSP if missing.

### Debugging (nvim-dap)

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dr` | Continue |
| `<leader>dT` | Terminate |
| `<leader>dso` | Step over |
| `<leader>dsi` | Step into |
| `<leader>dsu` | Step out |
| `<leader>de` | Evaluate expression |

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
- **Formatting**: `csharpier` via conform.nvim (passes `--stdin-path` so `.csharpierrc` resolves correctly)
- **Diagnostics**: Open files only by default; full-solution available via `:Roslyn restart`
- **File watching**: Delegated to Roslyn server (`filewatching = "roslyn"`)
- **Debugger**: `netcoredbg` via Mason + nvim-dap; `<leader>td` debugs nearest .NET test through neotest
- **Razor / CSHTML**: Roslyn handles LSP; treesitter uses the Razor parser and autotag is enabled for Razor markup
- **Version note**: newer upstream `roslyn.nvim` Razor co-hosting guidance targets Neovim 0.12+; this config currently runs on Neovim 0.11.x

### PHP / CodeIgniter 4
- **LSP**: `intelephense` — auto-indexes `vendor/` from `composer.json` root
- **Formatting**: `php-cs-fixer` via conform.nvim
- **Stubs**: Full standard PHP extension stubs included; CI4 framework indexed via vendor
- **No special setup needed** — intelephense finds CodeIgniter through Composer autoloader
