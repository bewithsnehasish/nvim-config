return {
  -- on_new_config: defers schemastore require until the server actually starts,
  -- preserving lazy-loading of schemastore.nvim.
  on_new_config = function(new_config)
    local ok, schemastore = pcall(require, "schemastore")
    if ok then
      new_config.settings = new_config.settings or {}
      new_config.settings.json = new_config.settings.json or {}
      new_config.settings.json.schemas = schemastore.json.schemas()
      new_config.settings.json.validate = { enable = true }
      -- Prevent server from requesting global schema catalog over internet on startup
      new_config.settings.json.schemaStore = { enable = false }
    end
  end,
}
