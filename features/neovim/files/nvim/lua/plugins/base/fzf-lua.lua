local keymap = require('utils').keymap
local fzf = require('fzf-lua')

fzf.setup({
  winopts = {
    height = 0.99,
    width = 0.99,
    preview = {
      layout = 'vertical',
      vertical = 'up:60%',
    },
  },
  files = {
    path_shorten = false,
    fd_opts = [[--color=never --type f --hidden --follow --exclude .git --exclude node_modules]],
  },
  grep = {
    rg_opts = table.concat({
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '-uu',
      '-g "!.git"',
      '-g "!node_modules"',
      '-e',
    }, ' '),
  },
})

-- Use fzf-lua for vim.ui.select (replaces dressing.nvim)
fzf.register_ui_select()

keymap('n', '<Leader>fn', fzf.files, { desc = 'Find files' })
keymap('n', '<Leader>fa', fzf.live_grep, { desc = 'Live grep' })
keymap('n', '<Leader>fh', fzf.helptags, { desc = 'Help tags' })
keymap('n', '<Leader>fb', fzf.buffers, { desc = 'Buffers' })
keymap('n', '<Leader>fm', fzf.marks, { desc = 'Marks' })
keymap('n', '<Leader>f:', fzf.command_history, { desc = 'Command history' })
keymap('n', '<Leader>fs', fzf.lsp_document_symbols, { desc = 'Document symbols' })
keymap('n', '<Leader>fq', fzf.quickfix_stack, { desc = 'Quickfix history' })
keymap('n', '<Leader>fd', fzf.diagnostics_workspace, { desc = 'Diagnostics' })
keymap('n', '<Leader>ff', fzf.blines, { desc = 'Fuzzy find in current buffer' })
keymap('n', '<Leader>fgc', fzf.git_commits, { desc = 'Git commits' })
keymap('n', '<Leader>fgs', fzf.git_status, { desc = 'Git status' })
keymap('n', '<Leader>fr', fzf.resume, { desc = 'Resume last picker' })
