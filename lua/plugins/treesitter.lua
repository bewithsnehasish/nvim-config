return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      local status, treesitter = pcall(require, "nvim-treesitter.configs")
      if not status then
        vim.notify(
          "Failed to load nvim-treesitter: " .. tostring(treesitter),
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Treesitter Error", icon = "❌" }
        )
        return
      end

      treesitter.setup {
        ensure_installed = {
          "python",
          "htmldjango",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "svelte",
          "json",
          "yaml",
          "markdown",
          "markdown_inline",
          "lua",
          "java",
          "php",
          "bash",
          "dockerfile",
          "gitignore",
          "toml",
          "vue",
        },
        auto_install = true,
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "htmldjango" }, -- Enhance Django template highlighting
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            local disabled = { "neo-tree", "help", "terminal", "" }
            if
              vim.tbl_contains(disabled, lang)
              or vim.b[buf].hlchunk_disabled
              or (ok and stats and stats.size > max_filesize)
            then
              return true
            end
            return false
          end,
        },
        indent = {
          enable = true,
          disable = { "htmldjango" }, -- Prevent hlchunk errors in Django templates
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<leader>ss", -- Avoid terminal conflicts
            node_incremental = "<leader>ss",
            scope_incremental = "<leader>sS",
            node_decremental = "<leader>sd",
          },
        },
      }

      -- Re-enable injections for Django template compatibility
      local enabled_injections = { "javascript", "typescript", "tsx" }
      for _, lang in ipairs(enabled_injections) do
        pcall(vim.treesitter.query.set, lang, "injections", nil)
      end

      -- Filetype detection for Django templates
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*.html", "*.djhtml" },
        group = vim.api.nvim_create_augroup("DjangoFiletype", { clear = true }),
        callback = function()
          local path = vim.fn.expand "%:p"
          if path:match "templates/" or path:match "%.djhtml$" then
            vim.bo.filetype = "htmldjango"
          end
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local status, autotag = pcall(require, "nvim-ts-autotag")
      if not status then
        vim.notify(
          "Failed to load nvim-ts-autotag: " .. tostring(autotag),
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Autotag Error", icon = "❌" }
        )
        return
      end
      autotag.setup {
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
        filetypes = {
          "html",
          "htmldjango", -- Support Django templates
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
        },
      }
    end,
  },
}
