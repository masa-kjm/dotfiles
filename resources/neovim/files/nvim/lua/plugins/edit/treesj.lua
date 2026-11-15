local keymap = require('utils').keymap

require('treesj').setup({
  ---@type boolean Use default keymaps (<space>m - toggle, <space>j - join, <space>s - split)
  use_default_keymaps = false,
})
keymap('n', '<Leader>M', function()
  require('treesj').toggle({ split = { recursive = true } })
end, { desc = 'Toggle split / join (recursive)' })
