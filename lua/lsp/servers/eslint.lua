return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
  },
  settings = {
    codeAction = {
      disableRuleComment = { enable = true, location = "separateLine" },
      showDocumentation = { enable = true },
    },
    codeActionOnSave = { enable = true, mode = "all" },
    format = false,
    nodePath = "",
    onIgnoredFiles = "off",
    quiet = false,
    rulesCustomizations = {},
    run = "onType",
    useESLintClass = false,
    validate = "on",
    workingDirectories = { { mode = "auto" } },
  },
}
