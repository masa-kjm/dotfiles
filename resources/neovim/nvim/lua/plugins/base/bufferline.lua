local keymap = require('utils').keymap

require('bufferline').setup({})
keymap('n', '<Leader>l', '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
keymap('n', '<Leader>h', '<cmd>BufferLineCyclePrev<CR>', { desc = 'Previous buffer' })
keymap('n', '<Leader>bp', '<cmd>BufferLineTogglePin<CR>', { desc = 'Toggle buffer pin' })
keymap(
  'n',
  '<Leader>bs',
  '<cmd>BufferLineSortByRelativeDirectory<CR>',
  { desc = 'Sort buffers by directory' }
)
keymap('n', '<Leader>bco', '<cmd>BufferLineCloseOthers<CR>', { desc = 'Close other buffers' })
keymap('n', '<Leader>bcr', '<cmd>BufferLineCloseRight<CR>', { desc = 'Close buffers to the right' })
keymap('n', '<Leader>bcl', '<cmd>BufferLineCloseLeft<CR>', { desc = 'Close buffers to the left' })
