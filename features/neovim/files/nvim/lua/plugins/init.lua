-- Plugin management with the built-in vim.pack (no lazy loading).
-- Plugin sources are declared in one place; per-plugin settings live in plugins/<group>/<name>.lua
-- and run when required (see `modules` below).

local gh = function(repo)
  return 'https://github.com/' .. repo
end

-- Build hooks. vim.pack has no `build` key, so run them on install / update.
local build_hooks = {
  ['markdown-preview.nvim'] = function()
    vim.fn['mkdp#util#install']()
  end,
  ['nvim-treesitter'] = function()
    require('nvim-treesitter').update()
  end,
}

vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('PackBuildHooks', { clear = true }),
  callback = function(ev)
    local data = ev.data
    local hook = build_hooks[data.spec.name]
    if not hook or (data.kind ~= 'install' and data.kind ~= 'update') then
      return
    end
    if not data.active then
      vim.cmd.packadd(data.spec.name)
    end
    local ok, err = pcall(hook)
    if not ok then
      vim.notify(('Build hook failed for %s: %s'):format(data.spec.name, err), vim.log.levels.ERROR)
    end
  end,
})

vim.pack.add({
  -- shared libraries
  gh('nvim-lua/plenary.nvim'),
  gh('nvim-tree/nvim-web-devicons'),

  -- base
  gh('stevearc/aerial.nvim'),
  gh('akinsho/toggleterm.nvim'),
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
  gh('rmagatti/auto-session'),
  gh('akinsho/bufferline.nvim'),
  gh('ibhagwan/fzf-lua'),
  gh('stevearc/oil.nvim'),
  gh('stevearc/overseer.nvim'),
  gh('kevinhwang91/nvim-bqf'),
  gh('folke/which-key.nvim'),

  -- edit
  gh('windwp/nvim-autopairs'),
  gh('monaqa/dial.nvim'),
  gh('folke/flash.nvim'),
  { src = gh('kylechui/nvim-surround'), version = vim.version.range('*') },
  gh('Wansmer/treesj'),
  gh('echasnovski/mini.cursorword'),
  gh('windwp/nvim-ts-autotag'),

  -- git
  gh('sindrets/diffview.nvim'),
  gh('lewis6991/gitsigns.nvim'),

  -- lsp (server definitions only; see config/lsp.lua)
  gh('neovim/nvim-lspconfig'),

  -- ui
  -- gh('folke/tokyonight.nvim'),
  -- gh('rebelot/kanagawa.nvim'),
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  gh('lukas-reineke/indent-blankline.nvim'),
  gh('nvim-lualine/lualine.nvim'),
  gh('iamcco/markdown-preview.nvim'),
  gh('nvim-zh/colorful-winsep.nvim'),
}, { load = true })

-- Configuration modules, loaded in order (the colorscheme goes first).
local modules = {
  -- colorscheme
  'ui.catppuccin',
  -- 'ui.tokyonight',
  -- 'ui.kanagawa',

  -- base
  'base.aerial',
  'base.toggleterm',
  'base.treesitter',
  'base.autosession',
  'base.bufferline',
  'base.fzf-lua',
  'base.oil',
  'base.overseer',
  'base.which-key',

  -- edit
  'edit.autopairs',
  'edit.dial',
  'edit.flash',
  'edit.nvim-surround',
  'edit.treesj',
  'edit.cursorword',
  'edit.ts-autotag',

  -- git
  'git.diffview',
  'git.gitsigns',

  -- ui
  'ui.indent-blankline',
  'ui.lualine',
  'ui.markdown-preview',
  'ui.winsep',
}

for _, name in ipairs(modules) do
  local ok, err = pcall(require, 'plugins.' .. name)
  if not ok then
    vim.notify(('Failed to load plugins.%s: %s'):format(name, err), vim.log.levels.ERROR)
  end
end
