return {
  {
    "nvim-java/nvim-java",
    dependencies = {
      "nvim-java/lua-async-await",
      "nvim-java/java-core",
      "nvim-java/java-debug-adapter",
      "nvim-java/java-test",
      "nvim-java/java-dap",
      "williamboman/mason.nvim", -- Ensure mason is loaded
      "mfussenegger/nvim-dap", -- Debug Adapter Protocol (DAP) for Java
    },
    config = function()
      -- Configure nvim-java
      require("java").setup {
        jdtls = {
          -- Use the jdtls installed by mason
          cmd = { vim.fn.stdpath "data" .. "/mason/bin/jdtls" },
        },
        dap = {
          -- Configure Java Debug Adapter Protocol (DAP)
          hotcodereplace = "auto",
        },
      }

      -- Configure DAP for Java
      require("jdtls").setup_dap()

      -- Optional: Add keybindings for Java debugging
      vim.api.nvim_set_keymap(
        "n",
        "<leader>dc",
        "<cmd>lua require('jdtls').test_class()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>dm",
        "<cmd>lua require('jdtls').test_nearest_method()<CR>",
        { noremap = true, silent = true }
      )
    end,
  },
}
