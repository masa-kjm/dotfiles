-- Keymap consistency checks, run headless by lint.sh: nvim --headless -c 'luafile checks/keymaps.lua' -c qa
-- Verifies every <Leader> mapping has a description and none is a prefix of another
-- (a prefix would make the longer mapping wait for 'timeoutlen').
local leader = vim.g.mapleader or ' '
local errors = {}
local seen = {}

for _, mode in ipairs({ 'n', 'x', 'v', 'i', 'o', 't' }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    if m.lhs:sub(1, #leader) == leader then
      local id = mode .. ':' .. m.lhs
      if not m.desc or m.desc == '' then
        table.insert(errors, 'missing desc: ' .. id)
      end
      seen[mode] = seen[mode] or {}
      table.insert(seen[mode], m.lhs)
    end
  end
end

for mode, list in pairs(seen) do
  for _, a in ipairs(list) do
    for _, b in ipairs(list) do
      if a ~= b and b:sub(1, #a) == a then
        table.insert(errors, ('prefix conflict: %s:%s shadows %s'):format(mode, a, b))
      end
    end
  end
end

if #errors > 0 then
  io.stderr:write(table.concat(errors, '\n'), '\n')
  os.exit(1)
end
