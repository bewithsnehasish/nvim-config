return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    config = function()
      local treesitter = require "nvim-treesitter"
      treesitter.setup()

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

      -- On main branch, install() COMPILES parsers into install_dir and links their
      -- queries there. That compile is broken on this machine (toolchain selects a
      -- non-working cl.exe instead of mingw gcc, and main exposes no compiler
      -- override). We instead use the plugin's precompiled bundled parsers, whose
      -- matching queries live in <plugin>/runtime/queries — same checkout, same
      -- version. nvim only searches queries/ at rtp roots, and <plugin>/runtime is
      -- not one, so expose it explicitly. If the compiler is ever fixed, replace
      -- this with `treesitter.install(ensure_installed)` and drop the rtp append.
      local ok_ts = vim.tbl_filter(function(lang)
        return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", false) == 0
      end, ensure_installed)
      if #ok_ts > 0 then
        pcall(treesitter.install, ok_ts) -- only try to build genuinely-missing parsers
      end
      vim.opt.runtimepath:append(vim.fn.stdpath "data" .. "/lazy/nvim-treesitter/runtime")

      -- main branch does not auto-start highlighting; without this autocmd there is none
      local max_filesize = 100 * 1024
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TSHighlight", { clear = true }),
        callback = function(args)
          local buf = args.buf
          if vim.b[buf].large_file or vim.b[buf].hlchunk_disabled then
            return
          end
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return
          end
          pcall(vim.treesitter.start, buf)
        end,
      })

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
      "xml",
    },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
      aliases = {
        razor = "html",
      },
    },
  },
}
