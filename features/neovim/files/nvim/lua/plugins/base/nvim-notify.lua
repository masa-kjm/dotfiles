require('notify').setup({
  -- stages = 'slide', -- Notification animation style
  stages = 'fade_in_slide_out', -- Notification animation style
  timeout = 4000, -- Notification display time (ms)
  background_colour = '#1e222a', -- Set background color
  render = 'minimal', -- Simple style
  -- task_list = {
  -- 	direction = 'right', -- Task List Direction
  -- },
  top_down = false,
})
vim.notify = require('notify')
