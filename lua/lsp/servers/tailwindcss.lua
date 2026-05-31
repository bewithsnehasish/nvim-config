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
    "cshtml",
  },
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "classList", "ngClass" },
      -- High-performance native handler for completion in helper functions
      classFunctions = { "cva", "cx", "cn", "clsx", "twMerge", "twJoin" },
      experimental = {
        classRegex = {
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "twJoin\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          -- CSS-in-JS / twin.macro / styled-components
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
