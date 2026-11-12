-- LSP setup on top of the built-in client. Per-server settings live in nvim/after/lsp/<server>.lua.
-- nvim-lspconfig only supplies default server definitions.

local servers = {
  'lua_ls',
  'rust_analyzer',
  'ts_ls',
  'eslint',
  'pylsp',
  'copilot',
}

vim.lsp.config('*', {
  root_markers = { '.git' },
})

vim.lsp.enable(servers)

-- Keymaps that the Nvim defaults (grn, gra, grr, gri, grt, gO, ]d, [d, <C-S>) do not cover.
local function set_buffer_keymaps(bufnr)
  local function map(lhs, rhs, desc)
    -- Not utils.keymap: this runs once per attached client and would warn about duplicates
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
  end
  map('gd', vim.lsp.buf.definition, 'LSP: definition')
  map('gD', vim.lsp.buf.declaration, 'LSP: declaration')
  map('<Leader>k', vim.lsp.buf.hover, 'LSP: hover')
  map('<Leader>ae', vim.diagnostic.open_float, 'Diagnostics: open float')
end

local function enable_inline_completion(bufnr)
  vim.lsp.inline_completion.enable(true, { bufnr = bufnr })

  -- Fall back to the original key when there is no candidate (e.g. <C-y> confirms the pum).
  vim.keymap.set('i', '<C-y>', function()
    if not vim.lsp.inline_completion.get() then
      return '<C-y>'
    end
  end, { buffer = bufnr, expr = true, desc = 'Accept inline completion' })
  vim.keymap.set('i', '<M-]>', function()
    vim.lsp.inline_completion.select({ count = 1 })
  end, { buffer = bufnr, desc = 'Next inline completion' })
  vim.keymap.set('i', '<M-[>', function()
    vim.lsp.inline_completion.select({ count = -1 })
  end, { buffer = bufnr, desc = 'Previous inline completion' })
end

-- Servers only advertise symbols such as '.' as trigger characters, so autotrigger would not fire
-- while typing identifiers. Add every identifier character to complete as you type.
local function extend_trigger_characters(client)
  local provider = client.server_capabilities.completionProvider
  if not provider then
    return
  end
  local chars = vim.split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_', '')
  provider.triggerCharacters = vim.list_extend(provider.triggerCharacters or {}, chars)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    set_buffer_keymaps(bufnr)

    local methods = vim.lsp.protocol.Methods
    if client:supports_method(methods.textDocument_completion, bufnr) then
      extend_trigger_characters(client)
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end
    if client:supports_method(methods.textDocument_inlineCompletion, bufnr) then
      enable_inline_completion(bufnr)
    end
  end,
})
