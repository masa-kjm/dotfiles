local get_latest_node_bin_path = require('utils').get_latest_node_bin_path

-- local copilot = {
-- 	'github/copilot.vim',
-- 	lazy = false,
-- }

vim.g.copilot_node_command = vim.fs.joinpath(get_latest_node_bin_path(), 'node')
require('copilot').setup({
  copilot_node_command = vim.fs.joinpath(get_latest_node_bin_path(), 'node'),
})
