return {
  filetypes = {
    "html",
    "javascriptreact",
    "javascript",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
    "astro",
    "php",
    "blade",
    "razor",
  },
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "classList", "ngClass" },
      classFunctions = { "cva", "cx", "cn", "clsx", "twMerge", "twJoin" },
      experimental = {
        -- tagged templates (twin.macro / styled-components) — classFunctions can't match these
        classRegex = {
          { "tw`([^`]*)", "tw.+(?:'|\"|`)?([^\"'`]*)(?:'|\"|`)?" },
          { "tw\\.[^`]+`([^`]*)", "tw\\.[^`]+.+`([^`]*)`" },
          { "tw\\([^)]*\\)`([^`]*)", "tw\\([^)]*\\).+`([^`]*)`" },
        },
      },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning",
      },
      validate = true,
    },
  },
}
