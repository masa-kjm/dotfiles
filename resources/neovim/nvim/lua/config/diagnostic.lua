-- Single source of truth for diagnostic display (replaces ALE / lspsaga / custom handlers).
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = { current_line = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '>>',
      [vim.diagnostic.severity.WARN] = '--',
      [vim.diagnostic.severity.INFO] = '..',
      [vim.diagnostic.severity.HINT] = '..',
    },
  },
  float = { source = true },
})
