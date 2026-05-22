local parsers = {
  "javascript", "typescript", "tsx", "c_sharp", "razor",
  "html", "css", "svelte", "json", "yaml",
  "markdown", "markdown_inline", "lua", "php", "bash",
  "dockerfile", "gitignore", "toml", "xml", "vue", "graphql",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if ok and type(ts.install) == "function" then
        pcall(ts.install, parsers)
      end
    end,
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if not ok then
        return
      end
      pcall(ts.setup, { install_dir = vim.fn.stdpath "data" .. "/site" })

      pcall(vim.treesitter.language.register, "razor", "cshtml")

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local stat_ok, stat = pcall(vim.uv.fs_stat, fname)
          -- 100 KB cap — bigger files freeze the highlighter
          if (stat_ok and stat and stat.size > 100 * 1024) or vim.b[bufnr].large_file then
            return
          end
          local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
          if lang then
            pcall(vim.treesitter.start, bufnr, lang)
          end
        end,
      })
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      pcall(function()
        require("nvim-ts-autotag").setup {
          opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = true,
          },
        }
      end)
    end,
  },
}
