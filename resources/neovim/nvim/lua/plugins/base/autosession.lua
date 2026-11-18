local keymap = require('utils').keymap

require('auto-session').setup({
  auto_create = false,
  -- auto_save = true,
  session_lens = {
    picker = 'fzf',
  },
})
keymap('n', '<Leader>sl', '<cmd>AutoSession search<CR>', { desc = 'List sessions' })
keymap('n', '<Leader>ss', '<cmd>AutoSession save<CR>', { desc = 'Save session' })
