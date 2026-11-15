local keymap = require('utils').keymap

require('toggleterm').setup({
  open_mapping = [[<C-t>]],
  start_in_insert = true,
  insert_mappings = false,
  persist_size = true,
  direction = 'float',
})

local function last_terminal_line(term)
  local bufnr = term.bufnr
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return '(no output)' end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, line_count - 80), line_count, false)
  for i = #lines, 1, -1 do
    local line = vim.trim(lines[i]):gsub('%s+', ' ')
    if line ~= '' then
      return vim.fn.strcharpart(line, 0, 70) .. (vim.fn.strchars(line) > 70 and '…' or '')
    end
  end
  return '(no output)'
end

local function select_terminal()
  local terminals = require('toggleterm.terminal').get_all(false)
  if #terminals == 0 then
    vim.notify('No toggleterm terminals yet', vim.log.levels.INFO)
    return
  end

  vim.ui.select(terminals, {
    prompt = 'Select terminal',
    preview_type = 'buffer',
    format_item = function(term)
      local name = term.display_name or term.cmd or vim.o.shell
      local state = term:is_open() and 'open' or 'hidden'
      return ('%d: %s  [%s]  %s'):format(term.id, name, state, last_terminal_line(term))
    end,
    preview_item = function(term)
      if not term.bufnr or not vim.api.nvim_buf_is_valid(term.bufnr) then return nil end
      local line_count = vim.api.nvim_buf_line_count(term.bufnr)
      local lines = vim.api.nvim_buf_get_lines(term.bufnr, math.max(0, line_count - 200), line_count, false)
      while #lines > 1 and vim.trim(lines[#lines]) == '' do
        table.remove(lines)
      end
      local preview_buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
      vim.bo[preview_buf].modifiable = false
      return { buf = preview_buf, pos = { #lines, 0 } }
    end,
  }, function(term)
    if not term then return end
    if term:is_open() then
      term:focus()
    else
      term:open()
    end
  end)
end

keymap('n', '<Leader>tl', select_terminal, { desc = 'Select terminal' })
keymap('n', '<Leader>tn', '<cmd>TermNew<CR>', { desc = 'New terminal' })

local function cycle_terminal(step)
  local terminals = require('toggleterm.terminal').get_all(false)
  if #terminals < 2 then return end

  local current_id = vim.b.toggle_number
  for index, term in ipairs(terminals) do
    if term.id == current_id then
      local target = terminals[(index - 1 + step + #terminals) % #terminals + 1]
      term:close()
      if target:is_open() then
        target:focus()
      else
        target:open()
      end
      return
    end
  end
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*toggleterm#*',
  callback = function(args)
    vim.keymap.set('t', '<M-h>', function() cycle_terminal(-1) end,
      { buffer = args.buf, desc = 'Previous terminal' })
    vim.keymap.set('t', '<M-l>', function() cycle_terminal(1) end,
      { buffer = args.buf, desc = 'Next terminal' })
  end,
})
