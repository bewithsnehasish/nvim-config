# Windows + C# Refactor — Design

**Date:** 2026-05-22
**Scope:** Option B (Clean + structure) · Commit to Neovim 0.12+ · Remove Java entirely
**Target branch:** `windows`

---

## Goals

1. Strip Python, Jupyter notebook, and Java footprint so the config matches the actually-used stack (React/TS · C#/.NET · PHP).
2. Eliminate dead code that's been accumulating (commented-out `coc.lua`, `formatter.lua`, terminal duplicate, Neovide block).
3. Make Windows a first-class target — not just WSL — by fixing the shell, the deprecated `vim.loop` calls, and the healthcheck.
4. Promote `dotnet.lua` from "one big plugin file" to a proper language module with LSP + DAP + format + test co-located.
5. Split the 667-line `lspconfig.lua` so per-language work touches per-language files.
6. Commit to Neovim 0.12+ as the baseline, which unlocks proper Razor co-hosting through `roslyn.nvim`.

## Non-goals

- Adopting LazyVim's layout wholesale.
- Adding `easy-dotnet.nvim` (`:DotnetRun`, `:DotnetTest`, etc.) — deferred. The current `neotest-dotnet` + `netcoredbg` + `:Roslyn` stack covers test/debug; build/run can live in a terminal for now.
- Adding Ruby/Go/Rust support speculatively.
- Touching anything in `lua/plugins/extras/`. Those are opt-in and untouched.

---

## Final directory layout

```text
~/.config/nvim/
├── init.lua                       # bootstraps lazy.nvim, calls core/lsp/lang init
├── lua/
│   ├── core/
│   │   ├── platform.lua           # NEW — OS detection, native Windows shell, clipboard
│   │   ├── options.lua            # WAS vim-options.lua (renamed; loses OS/clipboard bits)
│   │   ├── keymaps.lua            # WAS keymaps.lua (loses dead Java keymaps)
│   │   └── health.lua             # WAS user/health/config.lua (registered as vim.health.* too)
│   ├── lsp/
│   │   ├── on_attach.lua          # WAS user/lsp/on_attach.lua
│   │   └── servers/               # NEW — one file per server config
│   │       ├── lua_ls.lua
│   │       ├── html.lua
│   │       ├── cssls.lua
│   │       ├── jsonls.lua
│   │       ├── bashls.lua
│   │       ├── tailwindcss.lua
│   │       ├── prismals.lua
│   │       ├── emmet_ls.lua
│   │       ├── eslint.lua
│   │       ├── intelephense.lua
│   │       ├── graphql.lua
│   │       └── biome.lua          # typescript_tools stays inline in lspconfig.lua
                                   # — it's not a regular lspconfig server
│   ├── lang/
│   │   └── dotnet/
│   │       ├── init.lua           # roslyn.nvim setup (was plugins/dotnet.lua config body)
│   │       ├── dap.lua            # WAS user/dap/netcoredbg.lua
│   │       └── neotest.lua        # NEW — neotest-dotnet adapter, extracted from testing.lua
│   ├── plugins.lua                # unchanged auto-loader
│   └── plugins/
│       ├── lspconfig.lua          # SLIM — just lazy spec; config = require("lsp").setup()
│       ├── dotnet.lua             # SLIM — just lazy spec; config = require("lang.dotnet").setup()
│       ├── testing.lua            # neotest spec; adapters list pulls from lang.dotnet.neotest
│       ├── … (all other plugin specs unchanged)
│       └── extras/                # untouched
├── docs/
│   └── superpowers/specs/2026-05-22-windows-csharp-refactor-design.md
└── README.md                      # bumped to Neovim 0.12+ + new tree
```

**Plugin auto-loader contract:** `lua/plugins/*.lua` continues to return lazy specs. Everything under `lua/core/`, `lua/lsp/`, `lua/lang/` is plain Lua modules called from plugin `config` functions. This keeps `plugins.lua` ignorant of the reorg.

---

## Removal list (final)

### Delete files

| Path | Reason |
|---|---|
| `lua/plugins/notebook.lua` | `ipynb.nvim` — explicit user removal |
| `lua/plugins/coc.lua` | 62 lines, all commented out |
| `lua/plugins/formatter.lua` | `none-ls`, fully commented; conform owns formatting |
| `lua/user/lsp/on_attach.lua` | moves to `lua/lsp/on_attach.lua` |
| `lua/user/dap/netcoredbg.lua` | moves to `lua/lang/dotnet/dap.lua` |
| `lua/user/health/config.lua` | moves to `lua/core/health.lua` |
| `lua/user/` (empty dir) | gone after migrations |

### Trim from existing files

| File | Removal |
|---|---|
| `lua/plugins/mason.lua:63-64` | `"pyright"`, `"ruff"` |
| `lua/plugins/mason.lua:82-83` | matching entries in `skip_servers` |
| `lua/plugins/mason.lua:122-123` | `"black"`, `"isort"` |
| `lua/plugins/mason.lua:127` | `"djlint"` (Django) |
| `lua/plugins/mason.lua:131` | `"google-java-format"` (Java) |
| `lua/plugins/mason.lua:140` | `"debugpy"` (Python DAP) |
| `lua/plugins/lspconfig.lua:37-49` | `find_local_python` helper |
| `lua/plugins/lspconfig.lua:368-398` | `pyright` + `ruff` server config blocks |
| `lua/plugins/lspconfig.lua:642` | `"python"` from omnifunc filetype list |
| `lua/plugins/conform-formatter.lua:20` | `python = { "isort", "black" }` |
| `lua/plugins/conform-formatter.lua:23` | `htmldjango = { "djlint" }` |
| `lua/plugins/conform-formatter.lua:51` | `java = { "google-java-format" }` |
| `lua/plugins/conform-formatter.lua:71-76` | isort/black formatter overrides |
| `lua/plugins/conform-formatter.lua:87-89` | csharpier args override (conform default already correct) |
| `lua/plugins/testing.lua:14` | `nvim-neotest/neotest-python` dep |
| `lua/plugins/testing.lua:62-65` | `neotest-python` adapter |
| `lua/plugins/treesitter.lua:26-27` | `"python"`, `"htmldjango"` from ensure_installed |
| `lua/plugins/treesitter.lua:41` | `"java"` from ensure_installed |
| `lua/plugins/treesitter.lua:51` | `ignore_install = { "ipynb" }` (no longer needed) |
| `lua/plugins/treesitter.lua:56` | `additional_vim_regex_highlighting = { "htmldjango" }` → `nil` |
| `lua/plugins/treesitter.lua:73` | `disable = { "htmldjango" }` → `nil` |
| `lua/plugins/treesitter.lua:95-104` | Django filetype autocmd |
| `lua/plugins/treesitter.lua:128` | `"htmldjango"` from autotag filetypes |
| `lua/plugins/toggleterminal.lua:139-266` | 127-line commented duplicate |
| `lua/vim-options.lua:128-170` | commented Neovide block |
| `lua/keymaps.lua:43-47` | broken Java keymaps (`:JavaProjectImport`, etc.) |

---

## Structural changes

### 1. `lua/core/platform.lua` (NEW)

Single source of truth for "what OS am I on, how do I shell out, where's the clipboard." Eliminates duplicated detection in `vim-options.lua`, `toggleterminal.lua`, `neo-tree.lua`, and `health.lua`.

```lua
-- API:
--   M.is_windows          (boolean)
--   M.is_wsl              (boolean)
--   M.is_linux            (boolean — native, not WSL)
--   M.is_mac              (boolean)
--   M.shell               (string — best interactive shell for this OS)
--   M.setup_clipboard()   (called once by core.options)
--   M.setup_shell()       (called once by core.options — sets vim.opt.shell* on Windows)
```

**Critical: `setup_shell()` on Windows**

Currently `vim.opt.shell` defaults to `cmd.exe` on Windows. Conform, LazyGit, gitsigns, `:!` shell-outs all inherit this. Set up PowerShell as the Vim job shell:

```lua
if M.is_windows and vim.fn.executable("pwsh") == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.opt.shellredir   = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"
  vim.opt.shellpipe    = "2>&1 | %%{ \"$_\" } | tee %s; exit $LastExitCode"
  vim.opt.shellquote   = ""
  vim.opt.shellxquote  = ""
end
```

`toggleterminal.lua` keeps its own `pick_shell()` (different concern: interactive REPL vs `:!` plumbing) but reads `vim.g.shell_kind` from `core.platform` to stay consistent.

### 2. `lua/lsp/servers/<name>.lua` (NEW per-server files)

Per-server configs split out of the 667-line `lspconfig.lua`. Each file returns a plain config table (filetypes, settings, root_dir, optional handlers). `plugins/lspconfig.lua` scans the directory at startup and registers each one via `vim.lsp.config(name, cfg) ; vim.lsp.enable(name)`.

**No `vim.lsp.config or fallback` branching** — Neovim 0.12+ baseline guarantees the native API, so the existing fallback ladders in `lspconfig.lua` are removed.

The LSP chassis — capabilities construction, diagnostic config + highlights, the `custom_on_attach` builder (formatter handoff + diagnostic floats + CursorHold), the `typescript-tools` special-case setup, the omnifunc autocmd — **stays inside `plugins/lspconfig.lua`'s `config` function**. Splitting it into a separate `lsp/init.lua` module would add an indirection layer with no second consumer and break the "plugin spec + its setup live together" rule. The win we're after is "touching a server config doesn't drag the whole 667-line file into context" — the per-server split achieves that.

`typescript_tools` doesn't follow the regular lspconfig pattern (its own `setup{}` function), so it stays inline in `plugins/lspconfig.lua` rather than in `lsp/servers/`.

### 3. `lua/lang/dotnet/` (NEW module)

- `init.lua` — what `plugins/dotnet.lua` config body does today: filetype patterns, `vim.lsp.config("roslyn", …)`, `require("roslyn").setup{…}`, the Roslyn-specific `on_attach`. **Razor cohosting enabled** (default on Neovim 0.12+ with recent roslyn-language-server).
- `dap.lua` — netcoredbg adapter setup, OS-aware path resolution (already uses `vim.fs.joinpath`, just moved).
- `neotest.lua` — returns the `neotest-dotnet` adapter block. `plugins/testing.lua` imports it: `require("lang.dotnet.neotest").adapter()`.

### 4. `plugins/lspconfig.lua` and `plugins/dotnet.lua` slimmed

Each becomes ~15 lines: dependencies, events/filetypes, and `config = function() require("lsp").setup() end`.

---

## Neovim 0.12+ commitments

- **README & `:ConfigHealth`** require 0.12.0. Drop the `vim.lsp.config or fallback` ladder at `lspconfig.lua:142-168` and `lspconfig.lua:629-635`.
- **Razor co-hosting** enabled in `lang/dotnet/init.lua` — Roslyn drives Razor instead of the deprecated `rzls.nvim`. Per upstream README this requires `roslyn-language-server >= 5.8.0-1.26262.10`; the Mason Crashdummyy registry already ships current.
- **`vim.loop` → `vim.uv`** at `init.lua:3` and `plugins/colors-highlight.lua:36`.
- **Bootstrap path** — `init.lua` switches `vim.loop.fs_stat` to `vim.uv.fs_stat` (the only call before plugins load, so cannot use `core.platform`).

---

## Healthcheck improvements (`core/health.lua`)

In addition to the existing checks:

- **`dotnet --list-sdks`** parsed; warn if no SDK ≥ 8 installed (Roslyn requires 8+; recommend 10).
- **`pwsh -v`** version captured on Windows; warn if < 7.
- **`vim.opt.shell:get()`** on Windows; report whether `pwsh` is actually wired up.
- **`roslyn-language-server` version** read from Mason manifest; warn if < 5.8.0-1.26262.10 (Razor cohost threshold).
- **`treesitter razor parser`** check already present — keep.
- Register as `:checkhealth myconfig` in addition to `:ConfigHealth` (provider table at `M.check`).

---

## Migration order (informs the implementation plan)

The implementation plan that follows this spec will land in this order so each step leaves the editor in a working state:

1. Create `core/platform.lua` + migrate `vim-options.lua` → `core/options.lua` + delete commented blocks. Verify `:source $MYVIMRC` clean.
2. Native Windows shell setup added inside `core/platform.setup_shell()`.
3. `vim.loop` → `vim.uv` swap (3 sites).
4. Delete Python footprint (mason, lspconfig blocks, conform, testing adapter, treesitter ensure_installed, notebook plugin file).
5. Delete Java footprint (mason formatter, conform, broken keymaps in `keymaps.lua`).
6. Delete dead code (coc, formatter, toggleterm dup, neovide block).
7. Move `user/health/config.lua` → `core/health.lua`; add SDK + pwsh + shell + roslyn version checks.
8. Move `user/lsp/on_attach.lua` → `lsp/on_attach.lua`; update `dotnet.lua` and `lspconfig.lua` require paths.
9. Split `lspconfig.lua`: extract each server config into `lsp/servers/<name>.lua`; build `lsp/init.lua` dispatcher; slim plugin spec.
10. Move dotnet: `user/dap/netcoredbg.lua` → `lang/dotnet/dap.lua`; extract neotest adapter → `lang/dotnet/neotest.lua`; move plugin config body → `lang/dotnet/init.lua`; slim `plugins/dotnet.lua`.
11. Enable Razor cohosting; drop `vim.lsp.config or fallback` branches.
12. Update README (prereqs: 0.12+, new tree, removed sections).
13. Smoke-test: `:checkhealth`, `:ConfigHealth`, open a `.cs` file, `:Roslyn target`, `:Mason`, `:Lazy sync`.

Each step gets its own commit so any regression is easy to bisect.

---

## Risks & mitigations

| Risk | Mitigation |
|---|---|
| User hasn't actually upgraded Neovim 0.12+ yet on Windows | `core/health.lua` will refuse to load servers and print a clear "install Neovim 0.12+" notification rather than silently breaking. |
| `roslyn-language-server` version too old in Mason cache | After reinstall, healthcheck warns and a one-liner reinstall command is in README. |
| `setup_shell()` on Windows breaks an obscure shell-out in some plugin | Gate the shell config behind `vim.g.use_pwsh_shell = true` (default `true`); a user can flip it off in `core/options.lua` if a plugin misbehaves. |
| Splitting `lspconfig.lua` introduces an `on_attach`/capabilities mismatch | All servers go through `lsp/init.lua` which constructs capabilities once and passes the same `on_attach` builder. Per-server overrides happen inside each `servers/<name>.lua`. |
| `neotest-dotnet` adapter extraction breaks the testing.lua adapter list | `lang/dotnet/neotest.lua` returns the existing block verbatim; `testing.lua` just does `table.insert(adapters, require("lang.dotnet.neotest").adapter())`. |

## Verification (smoke test per migration step)

- `nvim --headless "+checkhealth myconfig" +qa` runs clean on the WSL host.
- `:Lazy sync` and `:Mason` show no missing packages and no extra Python/Java tools.
- Opening `Program.cs` attaches Roslyn within ~10s; `gd`/`gr`/`<leader>ca` work.
- Opening a `.razor` file attaches Roslyn (cohost) and treesitter razor parser highlights.
- `:Format` on a `.cs` file invokes csharpier and writes formatted output.
- `<leader>td` on a `[Test]` method launches netcoredbg.
- On Windows: `:!git status` works (no cmd.exe quoting errors), `:LazyGit` opens.
- On WSL: yank to `"+` lands in Windows clipboard via win32yank (unchanged).
