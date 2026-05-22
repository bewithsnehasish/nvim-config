return {
  root_dir = require("lspconfig.util").root_pattern("biome.json", "biome.jsonc"),
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
  },
}
