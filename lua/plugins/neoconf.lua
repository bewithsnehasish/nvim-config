return {
  "folke/neoconf.nvim",
  cmd = "Neoconf",
  -- Priority loading to ensure it's loaded before LSP
  priority = 1000,
  -- Load neoconf before any other LSP-related plugins
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("neoconf").setup {
      -- name of the local settings files
      local_settings = ".neoconf.json",
      -- name of the global settings file in your Neovim config directory
      global_settings = "neoconf.json",
      -- import existing settings from other plugins
      import = {
        vscode = true, -- local .vscode/settings.json
        coc = true, -- global/local coc-settings.json
        nlsp = true, -- global/local nlsp-settings.nvim json settings
      },
      -- send new configuration to lsp clients when changing json settings
      live_reload = true,
      -- set the filetype to jsonc for settings files
      filetype_jsonc = true,
      plugins = {
        -- configures lsp clients with settings
        lspconfig = {
          enabled = true,
        },
        -- configures jsonls to get completion in .nvim.settings.json files
        jsonls = {
          enabled = true,
          -- only show completion in json settings for configured lsp servers
          configured_servers_only = true,
        },
        -- configures lua_ls to get completion of lspconfig server settings
        lua_ls = {
          -- enable lua_ls annotations in your neovim config directory
          enabled_for_neovim_config = true,
          enabled = false,
        },
      },
    }
  end,
}
