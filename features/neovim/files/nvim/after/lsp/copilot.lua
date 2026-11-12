-- Inline completion is enabled in config/lsp.lua. Use `:LspCopilotSignIn` (nvim-lspconfig) to sign in.
-- Install: `@github/copilot-language-server` (npm feature).
---@type vim.lsp.Config
return {
  cmd = { 'copilot-language-server', '--stdio' },
  root_markers = { '.git' },
  init_options = {
    editorInfo = { name = 'Neovim', version = tostring(vim.version()) },
    editorPluginInfo = { name = 'Neovim', version = tostring(vim.version()) },
  },
}
