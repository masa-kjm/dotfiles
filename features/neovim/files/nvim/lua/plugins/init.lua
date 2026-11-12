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
    if vim.fn.exists(':TSUpdate') == 2 then
      vim.cmd('TSUpdate')
    end
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

  -- ai
  gh('zbirenbaum/copilot.lua'),
  gh('CopilotC-Nvim/CopilotChat.nvim'),

  -- base
  gh('stevearc/aerial.nvim'),
  gh('akinsho/toggleterm.nvim'),
  -- Pinned to the archived `master` branch until the `main` migration
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'master' },
  { src = gh('nvim-treesitter/nvim-treesitter-textobjects'), version = 'master' },
  gh('j-hui/fidget.nvim'),
  gh('rmagatti/auto-session'),
  gh('akinsho/bufferline.nvim'),
  { src = gh('nvim-telescope/telescope.nvim'), version = '0.1.x' },
  gh('stevearc/oil.nvim'),
  gh('stevearc/overseer.nvim'),
  gh('rcarriga/nvim-notify'),
  gh('kevinhwang91/nvim-bqf'),

  -- edit
  gh('windwp/nvim-autopairs'),
  gh('monaqa/dial.nvim'),
  gh('folke/flash.nvim'),
  { src = gh('kylechui/nvim-surround'), version = vim.version.range('*') },
  gh('Wansmer/treesj'),
  gh('echasnovski/mini.cursorword'),
  gh('folke/ts-comments.nvim'),
  gh('windwp/nvim-ts-autotag'),

  -- git
  gh('sindrets/diffview.nvim'),
  gh('lewis6991/gitsigns.nvim'),

  -- lsp
  gh('neovim/nvim-lspconfig'),
  gh('hrsh7th/nvim-cmp'),
  gh('hrsh7th/cmp-nvim-lsp'),
  gh('hrsh7th/cmp-buffer'),
  gh('hrsh7th/cmp-path'),
  gh('hrsh7th/cmp-cmdline'),
  gh('L3MON4D3/LuaSnip'),
  gh('saadparwaiz1/cmp_luasnip'),
  gh('onsails/lspkind.nvim'),
  gh('ray-x/lsp_signature.nvim'),
  gh('nvimdev/lspsaga.nvim'),
  gh('dense-analysis/ale'),

  -- ui
  gh('folke/tokyonight.nvim'),
  gh('lukas-reineke/indent-blankline.nvim'),
  gh('nvim-lualine/lualine.nvim'),
  gh('iamcco/markdown-preview.nvim'),
  gh('stevearc/dressing.nvim'),
  gh('nvim-zh/colorful-winsep.nvim'),
}, { load = true })

-- Configuration modules, loaded in order (the colorscheme goes first).
local modules = {
  'ui.tokyonight',

  -- ai
  'ai.copilot',
  'ai.copilot-chat',

  -- base
  'base.aerial',
  'base.toggleterm',
  'base.treesitter',
  'base.fidget',
  'base.autosession',
  'base.bufferline',
  'base.telescope',
  'base.oil',
  'base.overseer',
  'base.nvim-notify',

  -- edit
  'edit.autopairs',
  'edit.dial',
  'edit.flash',
  'edit.nvim-surround',
  'edit.treesj',
  'edit.cursorword',
  'edit.ts-comments',
  'edit.ts-autotag',

  -- git
  'git.diffview',
  'git.gitsigns',

  -- lsp
  'lsp.lspconfig',
  'lsp.nvim-cmp',
  'lsp.lsp-signature',
  'lsp.lsp-saga',
  'lsp.ale',

  -- ui
  'ui.indent-blankline',
  'ui.lualine',
  'ui.markdown-preview',
  'ui.dressing',
  'ui.winsep',
}

for _, name in ipairs(modules) do
  local ok, err = pcall(require, 'plugins.' .. name)
  if not ok then
    vim.notify(('Failed to load plugins.%s: %s'):format(name, err), vim.log.levels.ERROR)
  end
end
