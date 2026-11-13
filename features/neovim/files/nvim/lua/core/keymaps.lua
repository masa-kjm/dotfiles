-- Shared keymaps (also loaded in VSCode, so no plugin commands here).
local map = vim.keymap.set

map({ 'n', 'x' }, 'J', '5j', { desc = 'Move 5 lines down' })
map({ 'n', 'x' }, 'K', '5k', { desc = 'Move 5 lines up' })
map({ 'n', 'x' }, '<Leader>m', '%', { desc = 'Jump to matching pair' })

map('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
map('n', '<C-Right>', '<cmd>vertical resize +4<CR>', { desc = 'Increase window width' })
map('n', '<C-Left>', '<cmd>vertical resize -4<CR>', { desc = 'Decrease window width' })

map('n', 'n', 'nzz', { desc = 'Next match (centered)' })
map('n', 'N', 'Nzz', { desc = 'Previous match (centered)' })
map('n', '*', '*zz', { desc = 'Search word forward (centered)' })
map('n', '#', '#zz', { desc = 'Search word backward (centered)' })
map('n', '<Leader>/', ':noh<CR>', { desc = 'Clear search highlight' })

map('n', ']q', ':cnext<CR>', { desc = 'Next quickfix item' })
map('n', '[q', ':cprev<CR>', { desc = 'Previous quickfix item' })

-- <C-n> / <C-p> (buffer cycling) are defined by bufferline
map('n', '<C-q>', '<cmd>bd<CR>', { desc = 'Delete buffer' })

-- Built-in undo tree (bundled with Neovim, loaded on demand)
map('n', '<Leader>u', function()
  vim.cmd.packadd('nvim.undotree')
  require('undotree').open()
end, { desc = 'Undo tree' })
