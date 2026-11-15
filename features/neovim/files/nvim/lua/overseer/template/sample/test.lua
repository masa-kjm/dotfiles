return {
  generator = function(opts)
    local workspace = vim.fs.find('pnpm-workspace.yaml', { upward = true, type = 'file', path = opts.dir })[1]
    if not workspace then
      return 'No pnpm-workspace.yaml file found'
    end
    local cwd = vim.fs.dirname(workspace)
    return {
      {
        name = 'pnpm sample',
        builder = function(params)
          return {
            cmd = 'pnpm',
            args = { '-F', params.package, 'run', 'test' },
            cwd = cwd,
            components = { 'default', 'display_duration' },
          }
        end,
        params = {
          package = {
            type = 'string',
            desc = 'Package to test',
            default = 'package_prefix',
            optional = false,
          },
        },
      },
    }
  end,
}
