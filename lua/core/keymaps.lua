local opts = { noremap = true, silent = true }

-- Move line up
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("i", "<M-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Move line down
vim.keymap.set("n", "<M-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("i", "<M-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true })
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })

-- Delete word backward in insert mode
vim.keymap.set("i", "<C-b>", "<C-o>db", { desc = "Delete word backward", silent = true })

-- Word wrap toggle
vim.keymap.set("n", "<leader>wr", function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle word wrap", silent = true })

-- Paste from system clipboard
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste from system clipboard", silent = true })
vim.keymap.set("i", "<C-v>", "<C-R>+", { desc = "Paste from system clipboard", silent = true })
vim.keymap.set("v", "<C-v>", '"+p', { desc = "Paste selection from system clipboard", silent = true })

-- DAP keymaps
vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "DAP Toggle Breakpoint", silent = true })
vim.keymap.set("n", "<leader>dr", "<cmd>DapContinue<CR>", { desc = "DAP Continue", silent = true })
vim.keymap.set("n", "<leader>dT", "<cmd>DapTerminate<CR>", { desc = "DAP Terminate", silent = true })
vim.keymap.set("n", "<leader>dso", "<cmd>DapStepOver<CR>", { desc = "DAP Step Over", silent = true })
vim.keymap.set("n", "<leader>dsi", "<cmd>DapStepInto<CR>", { desc = "DAP Step Into", silent = true })
vim.keymap.set("n", "<leader>dsu", "<cmd>DapStepOut<CR>", { desc = "DAP Step Out", silent = true })

vim.api.nvim_create_user_command("DapOpenSidebar", function()
  local widgets = require "dap.ui.widgets"
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end, {})
vim.keymap.set("n", "<leader>dus", "<cmd>DapOpenSidebar<CR>", { desc = "DAP Open Sidebar", silent = true })

-- Buffer & Tab Navigation (Bufferline)
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer", silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to previous buffer", silent = true })


vim.keymap.set("n", "<leader>X", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close all OTHER buffers", silent = true })

vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Pin/Unpin current buffer", silent = true })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer by letter", silent = true })

vim.keymap.set("n", "<leader>c", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<leader>c", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>cc", '"+yy', { desc = "Copy line to system clipboard" })

-- Copy current active file path
vim.keymap.set("n", "yp", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path and path ~= "" then
    vim.fn.setreg("+", path)
    vim.notify("Copied active file path: " .. path, vim.log.levels.INFO, { title = "Clipboard" })
  else
    vim.notify("No active file open", vim.log.levels.WARN, { title = "Clipboard" })
  end
end, { desc = "Copy active file path", silent = true })




