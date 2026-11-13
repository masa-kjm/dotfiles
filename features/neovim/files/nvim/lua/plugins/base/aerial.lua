local keymap = require('utils').keymap

require('aerial').setup({
  layout = {
    default_direction = 'prefer_right',
  },
  keymaps = {
    ['<CR>'] = 'actions.jump',
    ['l'] = 'actions.jump',
  },
})
-- gO stays the built-in document symbols; the outline lives under <Leader>o
keymap('n', '<Leader>o', '<cmd>AerialToggle!<CR>', { desc = 'Toggle outline' })
keymap('n', ']o', '<cmd>AerialNext<CR>', { desc = 'Next outline symbol' })
keymap('n', '[o', '<cmd>AerialPrev<CR>', { desc = 'Previous outline symbol' })
