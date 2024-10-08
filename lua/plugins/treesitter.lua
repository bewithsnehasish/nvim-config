local config = function()
  require("nvim-treesitter.configs").setup {
    build = ":TSUpdate",
    indent = {
      enable = true,
    },
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    ensure_installed = {
      "vim",
      "regex",
      "rust",
      "markdown",
      "json",
      "javascript",
      "typescript",
      "yaml",
      "html",
      "css",
      "bash",
      "lua",
      "dockerfile",
      "solidity",
      "gitignore",
      "python",
      "vue",
      "svelte",
      "toml",
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-s>",
        node_incremental = "<C-s>",
        scope_incremental = false,
        node_decremental = "<BS>",
      },
    },
    -- Add the missing fields
    modules = {},
    sync_install = false,
    ignore_install = {},
  }
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    config = config,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
