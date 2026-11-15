local keymap = require('utils').keymap

local overseer = require('overseer')

overseer.setup({
  task_list = {
    direction = 'right',
    max_width = { 200, 0.8 },
  },
})

vim.api.nvim_create_user_command('OverseerRestartLast', function()
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify('No tasks found', vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], 'restart')
  end
end, {})

keymap('n', '<Leader>xl', '<cmd>OverseerToggle<CR>', { desc = 'Toggle task list' })
keymap('n', '<Leader>xr', '<cmd>OverseerRun<CR>', { desc = 'Run task' })
keymap('n', '<Leader>xp', '<cmd>OverseerRestartLast<CR>', { desc = 'Restart last task' })
