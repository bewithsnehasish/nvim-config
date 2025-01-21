return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" }, -- LSP source
    { "hrsh7th/cmp-emoji", event = "InsertEnter" }, -- Emoji source
    { "hrsh7th/cmp-buffer", event = "InsertEnter" }, -- Buffer source
    { "hrsh7th/cmp-path", event = "InsertEnter" }, -- Path source
    { "hrsh7th/cmp-cmdline", event = "InsertEnter" }, -- Command-line source
    { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" }, -- LuaSnip integration
    {
      "L3MON4D3/LuaSnip",
      event = "InsertEnter",
      dependencies = { "rafamadriz/friendly-snippets" }, -- Predefined snippets
    },
    { "hrsh7th/cmp-nvim-lua" }, -- Neovim Lua API source
    { "dcampos/cmp-emmet-vim" }, -- Emmet source for nvim-cmp
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true }, -- Tailwind CSS colorizer
  },
  config = function()
    local cmp = require "cmp"
    local luasnip = require "luasnip"

    -- Extend filetypes for LuaSnip
    luasnip.filetype_extend("javascriptreact", { "html", "css" })
    luasnip.filetype_extend("typescriptreact", { "html", "css" })
    luasnip.filetype_extend("javascript", { "html", "css" })
    luasnip.filetype_extend("yaml", { "markdown" })
    luasnip.filetype_extend("ini", { "sh" })
    luasnip.filetype_extend("conf", { "sh" })

    -- Load VSCode-style snippets
    require("luasnip/loaders/from_vscode").lazy_load()

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
    local icons = require "plugins.user.icons"

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
          elseif require("supermaven-nvim.completion_preview").has_suggestion() then
            require("supermaven-nvim.completion_preview").on_accept_suggestion() -- Accept Supermaven suggestion
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
      },
      formatting = {
        fields = { "kind", "abbr", "menu" }, -- Fields to display in completion menu
        format = function(entry, vim_item)
          vim_item.kind = icons.kind[vim_item.kind] -- Set icon for completion item
          vim_item.menu = ({
            nvim_lsp = "",
            nvim_lua = "",
            luasnip = "",
            buffer = "",
            path = "",
            emoji = "",
            emmet_vim = "Emmet", -- Add Emmet to the menu
          })[entry.source.name]

          -- Customize icons for specific sources
          if entry.source.name == "emoji" then
            vim_item.kind = icons.misc.Smiley
            vim_item.kind_hl_group = "CmpItemKindEmoji"
          elseif entry.source.name == "cmp_tabnine" then
            vim_item.kind = icons.misc.Robot
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          elseif entry.source.name == "supermaven" then
            vim_item.kind = ""
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          end

          -- Apply Tailwind CSS colorizer formatting
          return require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
        end,
      },
      sources = {
        { name = "copilot" }, -- GitHub Copilot
        { name = "supermaven" }, -- Supermaven
        { name = "nvim_lsp" }, -- LSP
        { name = "luasnip" }, -- LuaSnip snippets
        { name = "cmp_tabnine" }, -- TabNine
        { name = "nvim_lua" }, -- Neovim Lua API
        { name = "buffer" }, -- Buffer completions
        { name = "path" }, -- Path completions
        { name = "emoji" }, -- Emoji completions
        { name = "emmet_vim" }, -- Emmet completions
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
        ghost_text = false, -- Disable ghost text
      },
    }
  end,
}
