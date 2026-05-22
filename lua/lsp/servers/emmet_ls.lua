return {
  -- "javascriptreact"/"typescriptreact" intentionally omitted: typescript-tools
  -- already provides JSX completions and emmet_ls conflicts with them. Emmet tab
  -- expansion in JSX/TSX still works via cmp-emmet-vim.
  filetypes = {
    "html",
    "css",
    "scss",
    "sass",
    "svelte",
    "vue",
    "php",
    "blade",
  },
  init_options = {
    html = {
      options = {
        ["bem.enabled"] = true,
        ["jsx.enabled"] = true,
      },
    },
  },
}
