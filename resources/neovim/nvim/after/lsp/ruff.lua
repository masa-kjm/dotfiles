-- Lint / format / code actions. Type information comes from basedpyright, so hover is disabled
-- here to avoid duplicated hover windows.
-- Install: `ruff` (uv feature).
---@type vim.lsp.Config
return {
  cmd = { 'ruff', 'server' },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
