return {
  -- before_init so schemastore.nvim is only required when the server starts
  before_init = function(_, config)
    local ok, schemastore = pcall(require, "schemastore")
    if ok then
      config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
          schemaStore = { enable = false },
        },
      })
    end
  end,
}
