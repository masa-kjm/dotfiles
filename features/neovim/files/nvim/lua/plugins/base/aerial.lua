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
keymap('n', 'gO', '<cmd>AerialToggle!<CR>', { desc = 'Aerial toggle' })
keymap('n', ']o', '<cmd>AerialNext<CR>', { desc = '' })
keymap('n', '[o', '<cmd>AerialPrev<CR>', { desc = '' })
