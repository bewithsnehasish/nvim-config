-- Core Neovim options. Calls into core.platform for anything OS-specific.
local platform = require "core.platform"

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

-- Restore :LspInfo (nvim-lspconfig removed it; their replacement is :checkhealth lspconfig).
vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then
    vim.notify("No LSP attached to this buffer", vim.log.levels.WARN, { title = "LSP" })
    return
  end
  local lines = { "LSP clients on " .. vim.api.nvim_buf_get_name(0), "" }
  for _, c in ipairs(clients) do
    table.insert(lines, string.format("• %s (id=%d)", c.name, c.id))
    table.insert(lines, "    root: " .. (c.root_dir or "—"))
    local cmd = c.config.cmd
    table.insert(lines, "    cmd:  " .. (type(cmd) == "table" and table.concat(cmd, " ") or tostring(cmd)))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LspInfo" })
end, { desc = "List active LSP clients on this buffer" })

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
