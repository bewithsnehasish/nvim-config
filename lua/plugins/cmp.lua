return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- LSP source
    "hrsh7th/cmp-emoji", -- Emoji source
    "hrsh7th/cmp-buffer", -- Buffer source
    "hrsh7th/cmp-path", -- Path source
    "hrsh7th/cmp-cmdline", -- Command-line source
    "saadparwaiz1/cmp_luasnip", -- LuaSnip integration
    {
      "L3MON4D3/LuaSnip",
      dependencies = { "rafamadriz/friendly-snippets" }, -- Predefined snippets
    },
    { "hrsh7th/cmp-nvim-lua" }, -- Neovim Lua API source
    { "dcampos/cmp-emmet-vim" }, -- Emmet source for nvim-cmp
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true }, -- Tailwind CSS colorizer
    { "mattn/emmet-vim" }, -- Emmet plugin for HTML/CSS expansion
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
        disable_inline_completion = false,
        disable_keymaps = false,
      },
    },
  },
  config = function()
    local cmp = require "cmp"
    local luasnip = require "luasnip"

    -- Extend filetypes for LuaSnip
    luasnip.filetype_extend("php", { "html", "css" })
    luasnip.filetype_extend("blade", { "html", "css", "php" })
    -- luasnip.filetype_extend("javascriptreact", { "html", "css" })
    -- luasnip.filetype_extend("typescriptreact", { "html", "css" })
    -- luasnip.filetype_extend("javascript", { "html", "css" })
    -- luasnip.filetype_extend("yaml", { "markdown" })
    -- luasnip.filetype_extend("ini", { "sh" })
    -- luasnip.filetype_extend("conf", { "sh" })

    -- Load VSCode-style snippets
    require("luasnip/loaders/from_vscode").lazy_load()

    -- Add custom snippets for JSX/TSX components
    luasnip.add_snippets("javascriptreact", {
      luasnip.parser.parse_snippet("component", "<$1></$1>"),
    })

    luasnip.add_snippets("typescriptreact", {
      luasnip.parser.parse_snippet("component", "<$1></$1>"),
    })

    -- Custom highlight groups
    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { fg = "#CA42F0" })
    vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })
    vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#6CC644" })

    -- Helper function to check backspace
    local check_backspace = function()
      local col = vim.fn.col "." - 1
      return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
    end

    -- Icons for completion menu
    local icons = require "user.icons"

    -- Setup nvim-cmp
    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body) -- Expand snippets using LuaSnip
        end,
      },
      mapping = cmp.mapping.preset.insert {
        ["<C-k>"] = cmp.mapping.select_prev_item(), -- Navigate to previous item
        ["<C-j>"] = cmp.mapping.select_next_item(), -- Navigate to next item
        ["<Down>"] = cmp.mapping.select_next_item(), -- Navigate down
        ["<Up>"] = cmp.mapping.select_prev_item(), -- Navigate up
        ["<C-b>"] = cmp.mapping.scroll_docs(-1), -- Scroll docs up
        ["<C-f>"] = cmp.mapping.scroll_docs(1), -- Scroll docs down
        ["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion
        ["<CR>"] = cmp.mapping.confirm { select = true }, -- Confirm selection
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item() -- Select next item in completion menu
          elseif luasnip.expandable() then
            luasnip.expand() -- Expand snippet
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump() -- Jump to next snippet placeholder
          elseif check_backspace() then
            fallback() -- Fallback to default behavior
          else
            fallback()
          end
        end, { "i", "s" }), -- Map Tab in insert and select modes
        ["<C-y>"] = cmp.mapping(function(_)
          -- Emmet expansion via feedkeys (emmet-vim is Vimscript, not a Lua module)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-y>,", true, true, true), "n", true)
        end, { "i", "s" }), -- Map Ctrl+y to Emmet expansion
      },
      formatting = {
        fields = { "kind", "abbr", "menu" }, -- Fields to display in completion menu
        format = function(entry, vim_item)
          vim_item.kind = icons.kind[vim_item.kind] -- Set icon for completion item
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            luasnip = "[Snippet]",
            buffer = "[Buffer]",
            path = "[Path]",
            emoji = "[Emoji]",
            emmet_vim = "[Emmet]", -- Add Emmet to the menu
            supermaven = "[Supermaven]", -- Add Supermaven to the menu
          })[entry.source.name]

          -- Customize icons for specific sources
          if entry.source.name == "emoji" then
            vim_item.kind = icons.misc.Smiley
            vim_item.kind_hl_group = "CmpItemKindEmoji"
          elseif entry.source.name == "cmp_tabnine" then
            vim_item.kind = icons.misc.Robot
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          elseif entry.source.name == "supermaven" then
            vim_item.kind = icons.misc.Robot
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          end

          -- Apply Tailwind CSS colorizer formatting
          return require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
        end,
      },
      sources = {
        { name = "path" },
        { name = "supermaven" },
        { name = "emmet_vim" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "nvim_lua" },
        -- keyword_length=3: only trigger after 3 chars; max_item_count=8: cap results
        -- prevents scanning the entire buffer on every keystroke in large files
        { name = "buffer", keyword_length = 3, max_item_count = 8 },
        { name = "emoji" },
      },
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      window = {
        completion = {
          border = "rounded", -- Rounded border for completion menu
          scrollbar = false,
        },
        documentation = {
          border = "rounded", -- Rounded border for documentation
        },
      },
      experimental = {
        -- Disabled: Supermaven already renders inline ghost text.
        -- Having both enabled causes double rendering and visual conflicts.
        ghost_text = false,
      },
    }

    -- Autopairs integration: tells autopairs when cmp confirms a completion so it
    -- doesn't add a second closing bracket on top of what LSP already inserted.
    -- Without this: selecting `useState` inserts `useState()` then autopairs adds `)` → `useState())`.
    local autopairs_ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
    if autopairs_ok then
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end

    -- Command-line completion (cmp-cmdline is already a dependency but was never configured)
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources(
        { { name = "path" } },
        { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
      ),
    })
  end,
}
