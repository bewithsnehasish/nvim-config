return {
  cmd = { "graphql-lsp", "server", "-m", "stream" },
  filetypes = { "graphql", "typescriptreact", "javascriptreact" },
  root_dir = require("lspconfig.util").root_pattern(".graphqlrc*", ".graphql.config.*", "graphql.config.*"),
}
