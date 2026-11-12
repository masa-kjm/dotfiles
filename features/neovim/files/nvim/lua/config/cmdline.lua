-- Command-line autocompletion (see :help cmdline-autocompletion).
-- Suggestions appear as you type after ':', '/' or '?'; nothing is selected until <Tab> / arrow keys are used.
vim.opt.wildmode = 'noselect:lastused,full'
vim.opt.wildoptions = 'pum'

vim.api.nvim_create_autocmd('CmdlineChanged', {
  group = vim.api.nvim_create_augroup('CmdlineAutocomplete', { clear = true }),
  pattern = { ':', '/', '?' },
  callback = function()
    vim.fn.wildtrigger()
  end,
})

-- Keep history navigation on <Up> / <Down> while the menu is open
vim.keymap.set('c', '<Up>', function()
  return vim.fn.wildmenumode() == 1 and '<C-E><Up>' or '<Up>'
end, { expr = true })
vim.keymap.set('c', '<Down>', function()
  return vim.fn.wildmenumode() == 1 and '<C-E><Down>' or '<Down>'
end, { expr = true })
