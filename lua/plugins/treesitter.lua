return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Migrated to the main branch for Neovim 0.12 compatibility
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = {
      "windwp/nvim-ts-autotag",
    },
    config = function()
      local status, treesitter = pcall(require, "nvim-treesitter")

      if not status then
        vim.notify(
          "Failed to load nvim-treesitter: " .. tostring(treesitter),
          vim.log.levels.ERROR,
          { timeout = 2000, title = "Treesitter Error", icon = "❌" }
        )
        return
      end

      -- The main branch uses a basic setup call without feature tables
      treesitter.setup()

      -- Define parsers to ensure they are installed
      local ensure_installed = {
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
      }

      -- Install missing parsers automatically
      local function is_installed(lang)
        return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) > 0
      end

      local to_install = vim.tbl_filter(function(lang)
        return not is_installed(lang)
      end, ensure_installed)

      if #to_install > 0 then
        pcall(treesitter.install, to_install)
      end

      -- Highlighting is native in Neovim 0.12+. We add a control autocommand to stop it 
      -- for large files or specific disabled filetypes.
      local max_filesize = 100 * 1024 -- 100 KB
      local disabled_langs = { "neo-tree", "help", "terminal", "" }

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("TSHighlightControl", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local filename = vim.api.nvim_buf_get_name(buf)
          
          local ok, stats = pcall(vim.uv.fs_stat, filename)
          if ok and stats and stats.size > max_filesize then
            vim.treesitter.stop(buf)
            return
          end

          local ft = vim.bo[buf].filetype
          if vim.tbl_contains(disabled_langs, ft) or vim.b[buf].hlchunk_disabled then
            vim.treesitter.stop(buf)
            return
          end
        end,
      })

      -- Register cshtml to use razor parser
      vim.treesitter.language.register("razor", "cshtml")

      -- Incremental selection (Neovim 0.12+ native)
      vim.keymap.set("n", "<leader>ss", "van", { desc = "Init incremental selection (outward)", remap = true })
      vim.keymap.set("v", "<leader>ss", "an", { desc = "Increment selection (outward)", remap = true })
      vim.keymap.set("v", "<leader>sd", "in", { desc = "Decrement selection (inward)", remap = true })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = {
      "html",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
      "razor",
      "cshtml",
      "xml",
    },
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
