return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "huijiro/blink-cmp-supermaven",
    },
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = {
          function(cmp)
            if cmp.is_visible() and cmp.get_selected_item() then
              return cmp.accept()
            end
            return false
          end,
          "fallback",
        },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
        kind_icons = {
          Supermaven = "󰛔 ",
        },
      },
      sources = {
        -- blink handles LSP, path, snippets, and buffer natively!
        default = { "lsp", "path", "snippets", "buffer", "supermaven" },
        providers = {
          supermaven = {
            name = "supermaven",
            module = "blink-cmp-supermaven",
            score_offset = 100,
            async = true,
          },
        },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
          },
        },
        -- blink handles ghost text natively
        ghost_text = { enabled = true },
      },
      signature = {
        enabled = true,
        window = {
          border = "rounded",
        },
      },
    },
  },
  {
    "supermaven-inc/supermaven-nvim",
    opts = {
      keymaps = {
        accept_suggestion = "<C-l>",
        clear_suggestion = "<C-]>",
        accept_word = "<M-l>",
      },
      ignore_filetypes = { cpp = true },
      color = {
        suggestion_color = "#7b8496",
        cterm = 244,
      },
      log_level = "info",
      disable_inline_completion = false, -- Supermaven provides its own inline ghost text
      disable_keymaps = false,
    },
  },
}
