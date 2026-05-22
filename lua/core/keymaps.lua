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
vim.keymap.set(
  "n",
  "<Tab>",
  "<cmd>BufferLineCycleNext<CR>",
  { desc = "Go to next buffer", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<S-Tab>",
  "<cmd>BufferLineCyclePrev<CR>",
  { desc = "Go to previous buffer", noremap = true, silent = true }
)

vim.keymap.set("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close current buffer", noremap = true, silent = true })
vim.keymap.set(
  "n",
  "<leader>X",
  "<cmd>BufferLineCloseOthers<CR>",
  { desc = "Close all OTHER buffers", noremap = true, silent = true }
)

vim.keymap.set(
  "n",
  "<leader>bp",
  "<cmd>BufferLineTogglePin<CR>",
  { desc = "Pin/Unpin current buffer", noremap = true, silent = true }
)
vim.keymap.set(
  "n",
  "<leader>bo",
  "<cmd>BufferLinePick<CR>",
  { desc = "Pick buffer by letter", noremap = true, silent = true }
)

vim.keymap.set("n", "<leader>c", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set("v", "<leader>c", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>cc", '"+yy', { desc = "Copy line to system clipboard" })
