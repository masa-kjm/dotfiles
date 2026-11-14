-- Group names for the <Leader> prefixes (keep in sync with the scheme in README.md).
-- Individual mappings are described by their own `desc`.
local wk = require('which-key')

wk.setup({
  preset = 'modern',
  delay = 300,
  win = { border = 'rounded' },
  spec = {
    { '<Leader>f', group = 'find' },
    { '<Leader>g', group = 'git' },
    { '<Leader>s', group = 'session' },
    { '<Leader>b', group = 'buffer' },
    { '<Leader>bc', group = 'close' },
    { '<Leader>t', group = 'task' },
    { '<Leader>i', group = 'agent', mode = { 'n', 'x' } },
  },
})
