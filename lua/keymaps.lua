-- keymaps.lua
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
vim.api.nvim_set_keymap("i", "<C-b>", "<C-o>db", { noremap = true, silent = true })

-- Word Wrapper
vim.api.nvim_set_keymap("n", "<leader>wr", ":lua vim.wo.wrap = not vim.wo.wrap<CR>", opts)
