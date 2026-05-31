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

-- Disable unused legacy providers to speed up startup time
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

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
vim.opt.showtabline = 2

local tabline_group = vim.api.nvim_create_augroup("TablineVisibility", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  group = tabline_group,
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    if ft == "snacks_dashboard" or ft == "alpha" or ft == "lazy" or ft == "mason" then
      vim.opt.showtabline = 0
    else
      vim.opt.showtabline = 2
    end
  end,
})

local dashboard_group = vim.api.nvim_create_augroup("DashboardOnEmpty", { clear = true })
vim.api.nvim_create_autocmd("BufDelete", {
  group = dashboard_group,
  callback = function(ev)
    local bufs = vim.tbl_filter(function(buf)
      if not (vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted) then
        return false
      end
      if buf == ev.buf then
        return false
      end
      local ft = vim.bo[buf].filetype
      if ft == "snacks_dashboard" or ft == "alpha" then
        return false
      end
      local name = vim.api.nvim_buf_get_name(buf)
      local modified = vim.bo[buf].modified
      if name == "" and not modified and ft == "" then
        return false
      end
      return true
    end, vim.api.nvim_list_bufs())

    if #bufs == 0 then
      vim.schedule(function()
        local cur_ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
        if cur_ft ~= "snacks_dashboard" and cur_ft ~= "alpha" then
          require("snacks").dashboard.open()
        end
      end)
    end
  end,
})

platform.setup_clipboard()
platform.setup_shell()



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

vim.keymap.set("i", "<C-y>,", "<Plug>(emmet-expand-abbr)", { desc = "Emmet: expand abbreviation" })
