std = "lua51"
read_globals = {
  vim = {                  -- Neovim API (vim.*) is read-only except for these option tables
    fields = {
      g = { other_fields = true, read_only = false },
      b = { other_fields = true, read_only = false },
      w = { other_fields = true, read_only = false },
      t = { other_fields = true, read_only = false },
      o = { other_fields = true, read_only = false },
      go = { other_fields = true, read_only = false },
      bo = { other_fields = true, read_only = false },
      wo = { other_fields = true, read_only = false },
      env = { other_fields = true, read_only = false },
      opt = { other_fields = true, read_only = false },
      opt_local = { other_fields = true, read_only = false },
      opt_global = { other_fields = true, read_only = false },
      notify = { read_only = false },  -- Allows replacing the notification backend
    },
    other_fields = true,
  },
}
unused_args = false        -- Disable warnings for unused function arguments (to keep function signatures)
allow_defined_top = true   -- Allow top-level variables defined in the file
ignore = {
  "631",                   -- Ignore warnings about using variables outside if statements
  "111",                   -- Ignore global variable redefinition (e.g., with vim.keymap.set)
}
