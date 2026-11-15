-- nvim-treesitter (main branch): parser management only. Highlighting and indent are enabled per
-- buffer below. Requires the `tree-sitter` CLI and a C compiler.
local parsers = {
  'bash',
  'c',
  'c_sharp',
  'cpp',
  'css',
  'diff',
  'dockerfile',
  'gitcommit',
  'gitignore',
  'go',
  'html',
  'ini',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'make',
  'markdown',
  'markdown_inline',
  'mermaid',
  'python',
  'query',
  'rust',
  'scss',
  'sql',
  'typescript',
  'tsx',
  'toml',
  'vim',
  'vimdoc',
  'yaml',
}

-- Skips already installed parsers, so this is cheap on every startup.
require('nvim-treesitter').install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('TreesitterStart', { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang or not vim.treesitter.language.add(lang) then
      return
    end
    vim.treesitter.start(args.buf, lang)
    vim.bo[args.buf].indentexpr = 'v:lua.require\'nvim-treesitter\'.indentexpr()'
  end,
})
