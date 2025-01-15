local opts = { noremap = true, silent = true }

-- Move line up
vim.api.nvim_set_keymap("n", "<M-k>", ":m .-2<CR>==", opts)
vim.api.nvim_set_keymap("i", "<M-k>", "<Esc>:m .-2<CR>==gi", opts)
vim.api.nvim_set_keymap("v", "<M-k>", ":m '<-2<CR>gv=gv", opts)

-- Move line down
vim.api.nvim_set_keymap("n", "<M-j>", ":m .+1<CR>==", opts)
vim.api.nvim_set_keymap("i", "<M-j>", "<Esc>:m .+1<CR>==gi", opts)
vim.api.nvim_set_keymap("v", "<M-j>", ":m '>+1<CR>gv=gv", opts)

-- Define the custom keybinding for deleting a word backward in insert mode
vim.api.nvim_set_keymap("i", "<C-b>", "<C-o>db", opts)

-- Word Wrapper
vim.api.nvim_set_keymap("n", "<leader>wr", ":lua vim.wo.wrap = not vim.wo.wrap<CR>", opts)

-- Paste From System Clipboard
-- Normal mode
vim.api.nvim_set_keymap("n", "<C-v>", '"+p', opts)
-- Insert mode
vim.api.nvim_set_keymap("i", "<C-v>", "<C-R>+", opts)
-- Visual mode
vim.api.nvim_set_keymap("v", "<C-v>", '"+p', opts)

-- DAP (Debugger) keymaps
vim.api.nvim_set_keymap("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dr", "<cmd>DapContinue<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dt", "<cmd>DapTerminate<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dso", "<cmd>DapStepOver<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dsi", "<cmd>DapStepInto<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>dsu", "<cmd>DapStepOut<CR>", opts)

-- DAP UI Widgets (using a function requires a different approach)
vim.api.nvim_create_user_command("DapOpenSidebar", function()
  local widgets = require "dap.ui.widgets"
  local sidebar = widgets.sidebar(widgets.scopes)
  sidebar.open()
end, {})
vim.api.nvim_set_keymap("n", "<leader>dus", "<cmd>DapOpenSidebar<CR>", opts)

-- Java keymaps
vim.api.nvim_set_keymap(
  "n",
  "<leader>jb",
  "<cmd>JavaBuildBuildWorkspace<CR>",
  { noremap = true, desc = "Build workspace" }
)
vim.api.nvim_set_keymap("n", "<leader>jr", "<cmd>JavaRunnerRunMain<CR>", { noremap = true, desc = "Run main class" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>jt",
  "<cmd>JavaTestRunCurrentClass<CR>",
  { noremap = true, desc = "Run current test class" }
)
