return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter" },
    { "hrsh7th/cmp-emoji", event = "InsertEnter" },
    { "hrsh7th/cmp-buffer", event = "InsertEnter" },
    { "hrsh7th/cmp-path", event = "InsertEnter" },
    { "hrsh7th/cmp-cmdline", event = "InsertEnter" },
    { "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
    {
      "L3MON4D3/LuaSnip",
      event = "InsertEnter",
      dependencies = { "rafamadriz/friendly-snippets" },
    },
    { "hrsh7th/cmp-nvim-lua" },
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
  },
  config = function()
    local cmp = require "cmp"
    local luasnip = require "luasnip"
    -- luasnip.filetype_extend("javascriptreact", { "html", "css" })
    -- luasnip.filetype_extend("typescriptreact", { "html", "css" })
    -- luasnip.filetype_extend("javascript", { "html", "css" })
    -- luasnip.filetype_extend("yaml", { "markdown" })
    -- luasnip.filetype_extend("ini", { "sh" })
    -- luasnip.filetype_extend("conf", { "sh" })
    --
    require("luasnip/loaders/from_vscode").lazy_load()

    vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
    vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { fg = "#CA42F0" })
    vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })
    vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", { fg = "#6CC644" })

    local check_backspace = function()
      local col = vim.fn.col "." - 1
      return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
    end

    local icons = require "plugins.user.icons"

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert {
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<Down>"] = cmp.mapping.select_next_item(),
        ["<Up>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-1),
        ["<C-f>"] = cmp.mapping.scroll_docs(1),
        ["<C-Space>"] = cmp.mapping.complete(),
        -- ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif require("supermaven-nvim.completion_preview").has_suggestion() then
            require("supermaven-nvim.completion_preview").on_accept_suggestion()
          elseif luasnip.expandable() then
            luasnip.expand()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif check_backspace() then
            fallback()
          else
            fallback()
          end
        end, { "i", "s" }),
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = icons.kind[vim_item.kind]
          vim_item.menu = ({
            nvim_lsp = "",
            nvim_lua = "",
            luasnip = "",
            buffer = "",
            path = "",
            emoji = "",
          })[entry.source.name]

          if entry.source.name == "emoji" then
            vim_item.kind = icons.misc.Smiley
            vim_item.kind_hl_group = "CmpItemKindEmoji"
          end

          if entry.source.name == "cmp_tabnine" then
            vim_item.kind = icons.misc.Robot
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          end

          if entry.source.name == "supermaven" then
            vim_item.kind = ""
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          end

          -- Apply tailwindcss-colorizer-cmp formatting
          return require("tailwindcss-colorizer-cmp").formatter(entry, vim_item)
        end,
      },
      sources = {
        { name = "copilot" },
        { name = "supermaven" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "cmp_tabnine" },
        { name = "nvim_lua" },
        { name = "buffer" },
        { name = "path" },
        { name = "emoji" },
      },
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      window = {
        completion = {
          border = "rounded",
          scrollbar = false,
        },
        documentation = {
          border = "rounded",
        },
      },
      experimental = {
        ghost_text = false,
      },
    }
  end,
}
