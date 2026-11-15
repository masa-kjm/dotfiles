-- Type checking / completion / navigation. Lint diagnostics (style, imports) belong to ruff.
-- Install: `basedpyright` (uv feature).
---@type vim.lsp.Config
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  settings = {
    basedpyright = {
      -- Organize imports is handled by ruff
      disableOrganizeImports = true,
      analysis = {
        -- Unused-symbol checks are reported by ruff (F401, F841, ...); avoid duplicate diagnostics
        diagnosticSeverityOverrides = {
          reportUnusedImport = 'none',
          reportUnusedVariable = 'none',
          reportUnusedClass = 'none',
          reportUnusedFunction = 'none',
          reportUnusedExpression = 'none',
        },
      },
    },
  },
}
