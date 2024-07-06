-- plugins.lua

return {
	-- Markdown support
	{
		"plasticboy/vim-markdown",
		ft = { "markdown" },
	},
	{
		"vim-pandoc/vim-pandoc",
		ft = { "markdown" },
	},
	{
		"dhruvasagar/vim-table-mode",
		ft = { "markdown" },
	},
	{
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		ft = { "markdown" },
		config = function()
			vim.g.mkdp_auto_start = 1
		end,
	},

	-- Documentation and notes
	{
		"vimwiki/vimwiki",
		config = function()
			vim.g.vimwiki_list = {
				{
					path = "~/vimwiki/",
					syntax = "markdown",
					ext = ".md",
				},
			}
		end,
	},
	{
		"kristijanhusak/orgmode.nvim",
		ft = { "org" },
		config = function()
			require("orgmode").setup({})
		end,
	},
}
