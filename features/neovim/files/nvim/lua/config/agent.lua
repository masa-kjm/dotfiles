-- Review-oriented integration with an external coding agent (e.g. Copilot CLI):
--   * reload files the agent changed on disk
--   * list changed files in quickfix
--   * keep the agent CLI resident in a terminal and send it paths / selections

local keymap = require('utils').keymap

-- Command that starts the agent CLI. Override with `vim.g.agent_cli_cmd` before this module loads.
local agent_cmd = vim.g.agent_cli_cmd or 'copilot'

-- Reload on external changes ---------------------------------------------------------------------

local group = vim.api.nvim_create_augroup('AgentAutoReload', { clear = true })

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'TermLeave' }, {
  group = group,
  callback = function()
    -- checktime is not allowed in the command-line window
    if vim.fn.getcmdwintype() == '' then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = group,
  callback = function(args)
    vim.notify(
      ('File changed on disk, reloaded: %s'):format(vim.fn.fnamemodify(args.file, ':.')),
      vim.log.levels.WARN
    )
  end,
})

-- Changed files -> quickfix ----------------------------------------------------------------------

local function git_lines(args, cwd)
  local result = vim.system(vim.list_extend({ 'git' }, args), { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or '')
  end
  return vim.split(result.stdout, '\n', { trimempty = true })
end

-- Fill quickfix with files changed against `ref` (default HEAD) plus untracked files.
local function changed_files_to_quickfix(ref)
  local root, err = git_lines({ 'rev-parse', '--show-toplevel' }, vim.fn.getcwd())
  if not root then
    vim.notify('Not a git repository: ' .. err, vim.log.levels.ERROR)
    return
  end
  root = root[1]

  local items = {}
  local function collect(args, text)
    local files = git_lines(args, root) or {}
    for _, file in ipairs(files) do
      table.insert(items, { filename = vim.fs.joinpath(root, file), lnum = 1, text = text })
    end
  end

  collect({ 'diff', '--name-only', '--diff-filter=d', ref or 'HEAD' }, 'changed')
  collect({ 'ls-files', '--others', '--exclude-standard' }, 'untracked')

  vim.fn.setqflist({}, ' ', { title = 'Changed files (' .. (ref or 'HEAD') .. ')', items = items })
  if #items == 0 then
    vim.notify('No changed files', vim.log.levels.INFO)
    return
  end
  vim.cmd.copen()
end

vim.api.nvim_create_user_command('ChangedFiles', function(opts)
  changed_files_to_quickfix(opts.args ~= '' and opts.args or nil)
end, { nargs = '?', desc = 'Send changed files (git diff --name-only) to quickfix' })

keymap('n', '<Leader>gq', '<cmd>ChangedFiles<CR>', { desc = 'Changed files to quickfix' })

-- Resident agent CLI terminal --------------------------------------------------------------------

local cli_term

local function get_cli_term()
  if not cli_term then
    cli_term = require('toggleterm.terminal').Terminal:new({
      cmd = agent_cmd,
      direction = 'vertical',
      hidden = true,
      close_on_exit = true,
      on_exit = function()
        cli_term = nil
      end,
    })
  end
  return cli_term
end

local function toggle_cli()
  if vim.fn.executable(agent_cmd) ~= 1 then
    vim.notify(('Agent CLI not found: %s'):format(agent_cmd), vim.log.levels.ERROR)
    return
  end
  get_cli_term():toggle(math.floor(vim.o.columns * 0.4))
end

-- Send text to the CLI as a bracketed paste so that newlines do not submit the prompt.
local function send_to_cli(text)
  if vim.fn.executable(agent_cmd) ~= 1 then
    vim.notify(('Agent CLI not found: %s'):format(agent_cmd), vim.log.levels.ERROR)
    return
  end
  local term = get_cli_term()
  if not term:is_open() then
    term:open(math.floor(vim.o.columns * 0.4))
  end
  vim.fn.chansend(term.job_id, '\27[200~' .. text .. '\27[201~')
end

local function current_relative_path()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    vim.notify('Buffer has no file', vim.log.levels.WARN)
    return nil
  end
  return vim.fn.fnamemodify(name, ':.')
end

keymap('n', '<Leader>ic', toggle_cli, { desc = 'Toggle agent CLI' })

keymap('n', '<Leader>ip', function()
  local path = current_relative_path()
  if path then
    send_to_cli('@' .. path .. ' ')
  end
end, { desc = 'Send current file path to agent CLI' })

keymap('x', '<Leader>is', function()
  local path = current_relative_path()
  if not path then
    return
  end
  local v, cursor = vim.fn.getpos('v'), vim.fn.getpos('.')
  local first, last = math.min(v[2], cursor[2]), math.max(v[2], cursor[2])
  local lines = vim.fn.getregion(v, cursor, { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'nx', false)
  send_to_cli(('@%s:%d-%d\n```\n%s\n```\n'):format(path, first, last, table.concat(lines, '\n')))
end, { desc = 'Send selection to agent CLI' })
