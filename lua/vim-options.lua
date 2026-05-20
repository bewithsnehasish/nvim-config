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

-- OS detection — set once at startup, consumed by clipboard, shell, and path logic.
-- is_windows: native Windows Neovim (nvim-qt, neovide, wezterm on Windows, etc.)
-- is_wsl:     Neovim running inside WSL2 (Linux kernel + Windows host)
local is_windows = vim.fn.has "win32" == 1
local is_wsl = vim.fn.has "wsl" == 1
vim.g.is_windows = is_windows
vim.g.is_wsl = is_wsl

-- Clipboard strategy:
--   Native Windows → Neovim handles the clipboard automatically; no config needed.
--   WSL            → win32yank.exe bridges to the Windows host clipboard.
--   Native Linux   → Neovim auto-detects xsel / xclip / wl-copy; no config needed.
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
      -- Treesitter is disabled per-buffer via its own disable callback (100KB limit)
      -- illuminate and hlchunk check vim.b.large_file themselves
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("Osc52YankNotify", { clear = true }),
  callback = function()
    -- Only notify if it was yanked to the system clipboard (+) or (*)
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
  require("user.health.config").run()
end, { desc = "Show config-specific health checks" })

-- Clear search highlight with <Esc> (a no-op otherwise in normal mode).
-- Frees up <leader>h to be exclusive to the gitsigns hunk namespace.
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
vim.wo.number = true

-- In your init.lua or a separate Lua file for plugin configuration
vim.g.user_emmet_settings = {
  javascript = {
    extends = "html",
  },
  typescriptreact = {
    extends = "html",
  },
  javascriptreact = {
    extends = "html",
  },
  blade = {
    extends = "html, php",
  },
  ejs = {
    extends = "html, javascript",
  },
  php = {
    extends = "html, javascript ,css",
  },
}

-- if vim.g.neovide then
--   vim.o.guifont = "Maple Mono NF:h17"
--   vim.opt.linespace = 0
--   vim.g.neovide_scale_factor = 1.0
--   vim.g.neovide_text_gamma = 0.0
--   vim.g.neovide_text_contrast = 0.5
--   vim.g.neovide_padding_top = 0
--   vim.g.neovide_padding_bottom = 0
--   vim.g.neovide_padding_right = 0
--   vim.g.neovide_padding_left = 0
--
--   -- Helper function for transparency formatting
--   local alpha = function()
--     return string.format("%x", math.floor((255 * vim.g.transparency) or 0.8))
--   end
--   vim.g.transparency = 0.8
--   vim.g.neovide_background_color = "#0f1117" .. alpha()
--
--   vim.g.neovide_window_blurred = true
--   vim.g.neovide_floating_blur_amount_x = 2.0
--   vim.g.neovide_floating_blur_amount_y = 2.0
--
--   vim.g.neovide_floating_shadow = true
--   vim.g.neovide_floating_z_height = 10
--   vim.g.neovide_light_angle_degrees = 45
--   vim.g.neovide_light_radius = 5
--   vim.g.neovide_transparency = 0.8
--   vim.g.neovide_show_border = true
--   vim.g.neovide_position_animation_length = 0.15
--   vim.g.neovide_scroll_animation_length = 0.3
--   vim.g.neovide_scroll_animation_far_lines = 1
--   vim.g.neovide_hide_mouse_when_typing = false
--   vim.g.neovide_underline_stroke_scale = 1.0
--   vim.g.neovide_theme = "auto"
--   vim.g.experimental_layer_grouping = false
--   vim.g.neovide_refresh_rate = 120
--   vim.g.neovide_refresh_rate_idle = 5
--   vim.g.neovide_no_idle = true
--   vim.g.neovide_confirm_quit = true
--   vim.g.neovide_detach_on_quit = "always_quit"
--   vim.g.neovide_fullscreen = true
--   vim.g.neovide_remember_window_size = true
-- end

-- Optionally, you can map <C-y>, to trigger Emmet expansion in insert mode
vim.api.nvim_set_keymap("i", "<C-y>,", "<Plug>(emmet-expand-abbr)", {})
