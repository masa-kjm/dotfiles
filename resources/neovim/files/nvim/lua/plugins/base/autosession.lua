local keymap = require('utils').keymap

require('auto-session').setup({
  auto_create = false,
  -- auto_save = true,
  session_lens = {
    picker = 'fzf',
  },
})
keymap('n', '<Leader>sl', '<cmd>SessionSearch<CR>', { desc = 'List sessions' })
keymap('n', '<Leader>ss', '<cmd>SessionSave<CR>', { desc = 'Save session' })
