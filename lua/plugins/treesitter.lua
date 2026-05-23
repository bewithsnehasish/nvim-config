return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Pinned to master branch for now. main branch requires a config rewrite
    -- (no more nvim-treesitter.configs.setup{}; per-FT autocmd registration).
    -- On Neovim 0.12 master throws a few non-fatal errors; we mitigate by:
    --   * dropping illuminate's "treesitter" provider (see vim-illuminate.lua)
    --   * lower file-size threshold for highlight (100KB) to skip giant files
    branch = "master",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      local status, treesitter = pcall(require, "nvim-treesitter.configs")
      if not status then
        status, treesitter = pcall(require, "nvim-treesitter")
      end

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
          "javascript",
          "typescript",
          "tsx",
          "c_sharp",
          "razor",
          "html",
          "css",
          "svelte",
          "json",
          "yaml",
          "php",
          "bash",
          "dockerfile",
          "gitignore",
          "toml",
          "xml",
          "vue",
          "graphql",
          "regex",
        },
        auto_install = true,
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
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

      vim.treesitter.language.register("razor", "cshtml")
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
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "razor",
          "cshtml",
        },
      }
    end,
  },
}
