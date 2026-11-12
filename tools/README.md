# Quality Assurance Tools

Development tools for maintaining code quality and documentation consistency.

## Scripts

### lint.sh

Runs code quality checks on profiles and on each feature that provides its own `lint.sh`.

**Usage:**

```bash
bash tools/lint.sh
```

**Checks:**

- Profile format validation (YAML syntax and schema)
  - Ensures `features` is a map (not array)
  - Validates feature entries are maps or null
- Feature checks: runs every `features/<name>/lint.sh` (feature-specific checks live in the feature)
  - `features/neovim/lint.sh`: `stylua`, `luacheck`, and a headless smoke test (startup errors, `checkhealth`, no plugins in VSCode mode)

## Adding New Tools

Place new tools in this directory and document them here with:

- Tool name and purpose
- Usage command
- Key options/flags
- Expected output or side effects
