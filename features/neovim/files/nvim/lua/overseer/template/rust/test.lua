return {
  generator = function(opts)
    local manifest = vim.fs.find('Cargo.toml', { upward = true, type = 'file', path = opts.dir })[1]
    if not manifest then
      return 'No Cargo.toml file found'
    end
    local cwd = vim.fs.dirname(manifest)
    return {
      {
        name = 'Cargo Test',
        builder = function()
          return {
            cmd = 'cargo',
            args = { 'test' },
            cwd = cwd,
            components = { 'default', 'display_duration' },
          }
        end,
      },
    }
  end,
}
