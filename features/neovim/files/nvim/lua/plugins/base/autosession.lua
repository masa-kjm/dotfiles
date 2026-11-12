local keymap = require('utils').keymap

require('auto-session').setup({
  auto_create = false,
  -- auto_save = true,
  session_lens = {
    picker = 'fzf',
  },
})
keymap('n', '<leader>fw', '<cmd>SessionSearch<CR>', { desc = 'Session search' })
keymap('n', '<leader>ws', '<cmd>SessionSave<CR>', { desc = 'Save session' })
