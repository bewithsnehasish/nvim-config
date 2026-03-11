# 🌌 Blackvortex Neovim Configuration

A modern, fast, and modular Neovim configuration tailored for full-stack web development (React, TypeScript, Django/Python, PHP) and general programming. Powered by `lazy.nvim`.

## ✨ Core Features
- **Plugin Manager**: `lazy.nvim` with a custom auto-discovery loader.
- **LSP & Formatting**: Fully automated LSP installation via `mason.nvim`, `mason-lspconfig`, and `mason-tool-installer`. Formatting handled strictly by `conform.nvim` (format-on-save).
- **AI Assistance**: Integrated with Supermaven for lightning-fast AI completions.
- **UI & Aesthetics**: Cyberdream colorscheme, `lualine` statusline, `bufferline` (buffer mode), and smooth scroll/animations.
- **File & Search**: `neo-tree` for file browsing, `telescope` with `fzf-native` for fuzzy finding.

## 📂 Architecture & Folder Structure
This config uses a clean, auto-discovering modular architecture.

```text
~/.config/nvim/
├── init.lua              # Bootstraps lazy.nvim and loads core files
├── lua/
│   ├── vim-options.lua   # Core Vim settings (tabs, numbers, etc.)
│   ├── keymaps.lua       # Global and Bufferline keybindings
│   ├── plugins.lua       # Engine that auto-loads all files in plugins/
│   ├── user/             # Shared custom utilities (icons, LSP on_attach)
│   └── plugins/          # 📦 Plugin definitions (One file per plugin)
│       └── extras/       # Optional/UI plugin definitions
```
*Note: Any `.lua` file dropped into `lua/plugins/` or `lua/plugins/extras/` is automatically loaded by the plugin manager.*

---

## ⌨️ Keymaps Cheat Sheet

The `<leader>` key is mapped to `<Space>`.

### 🪟 General & Window Navigation
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Navigate between splits (integrated with Tmux) |
| `<M-k>` / `<M-j>` | Move current line up/down (Normal, Insert, Visual) |
| `<C-b>` | Delete word backward (Insert mode) |
| `<C-v>` | Paste from system clipboard |
| `<leader>wr` | Toggle word wrap |
| `<leader>h` | Clear search highlight (`:nohlsearch`) |

### 📑 Buffer Navigation (`bufferline.nvim`)
| Key | Action |
|---|---|
| `<Tab>` | Go to next buffer |
| `<S-Tab>` | Go to previous buffer |
| `<leader>x` | Close current buffer |
| `<leader>X` | Close all *other* buffers |
| `<leader>bp` | Toggle pin on current buffer |
| `<leader>bo` | Pick a buffer by assigned letter |

### 📁 File Explorer (`neo-tree`)
| Key | Action |
|---|---|
| `<leader>e` | Toggle Neo-tree on the right |
| `<leader>n` | Focus Neo-tree |
| `<leader>bf` | Show buffers in floating Neo-tree |
| `<leader>fs` | Show filesystem in floating Neo-tree |
| `<leader>dt` | Reveal Django `templates` dir |
| `<leader>wp` | Pick window (window-picker) |

### 🔭 Fuzzy Finding (`telescope`)
| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (Find text in project) |
| `<leader>bb` | Find open buffers |
| `<leader>fr` | Recent files |
| `<leader>fc` | Change colorscheme |
| `<leader>fb` | Checkout Git branch |
| `<leader>fl` | Resume last search |

### 🧠 LSP & Code Navigation
| Key | Action |
|---|---|
| `gd` | Go to Definition |
| `gD` | Go to Declaration |
| `gi` | Go to Implementation |
| `gr` | Find References |
| `<leader>rn` | Rename symbol (`inc-rename`) |
| `<leader>ca` | Code Action |
| `<C-k>` | Signature Help |
| `<leader>o` | Open Navbuddy (Breadcrumb outline) |

### ⚠️ Diagnostics
| Key | Action |
|---|---|
| `<leader>d` | Open diagnostic float (focusable, text yankable via `<C-y>`) |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `<leader>dD` | Inspect raw diagnostics data |

### 🪄 Formatting (`conform.nvim`)
| Key | Action |
|---|---|
| `<leader>mp` | Format current file (or visual range) |
| `<leader>mf` | Toggle auto-format on save |

### 🐛 Debugging (`nvim-dap`)
| Key | Action |
|---|---|
| `<leader>db` | Toggle Breakpoint |
| `<leader>dr` | Continue |
| `<leader>dT` | Terminate |
| `<leader>dso` | Step Over |
| `<leader>dsi` | Step Into |
| `<leader>dsu` | Step Out |
| `<leader>dus` | Open DAP UI Sidebar |

### ☕ Java Specific
| Key | Action |
|---|---|
| `<leader>ji` | Import Java project |
| `<leader>jc` | Compile Java project |
| `<leader>jt` | Run Java tests |
| `<leader>jr` | Run Java file |

### 🌳 Git (`lazygit.nvim`)
| Key | Action |
|---|---|
| `<leader>gg` | Open LazyGit |
| `<leader>gf` | LazyGit Filter |
| `<leader>gc` | LazyGit Filter Current File |
