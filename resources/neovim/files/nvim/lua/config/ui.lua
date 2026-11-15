-- ui2: experimental redesign of the message and cmdline UI (see :help ui2).
-- It replaces the hit-enter prompt and makes vim.notify messages show up in a message window
-- (nvim-notify replacement). Use `g<` to open recent messages in the pager.
require('vim._core.ui2').enable({
  msg = {
    targets = 'msg',
    msg = { timeout = 4000 },
  },
})
