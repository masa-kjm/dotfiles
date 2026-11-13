#!/usr/bin/env bash
# Quality checks for the Neovim feature (format, static analysis, headless smoke test).
# Run directly, or via tools/lint.sh which discovers features/*/lint.sh.
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES_DIR="$FEATURE_DIR/files"
NVIM_DIR="$FILES_DIR/nvim"

readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_RED='\033[0;31m'

log_step() {
    echo -e "${COLOR_GREEN}==>${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*"
}

# stylua (format) and luacheck (static analysis); configs live in files/
static_checks() {
    log_step "Validating Neovim configuration..."

    echo "  Running stylua..."
    stylua --config-path "$FILES_DIR/.stylua.toml" -c "$NVIM_DIR/lua" "$NVIM_DIR/init.lua" "$FEATURE_DIR/checks"

    echo "  Running luacheck..."
    luacheck --config "$FILES_DIR/.luacheckrc" "$NVIM_DIR" "$FEATURE_DIR/checks"

    echo "  ✓ Neovim config valid"
}

# Smoke test the Neovim configuration in headless mode
smoke_test() {
    log_step "Smoke testing Neovim configuration..."

    if ! command -v nvim > /dev/null 2>&1; then
        echo "  Skipping (nvim not found)"
        return 0
    fi

    # Use this repository's config regardless of what ~/.config/nvim points to
    local tmp_config
    tmp_config="$(mktemp -d)"
    trap 'rm -rf "$tmp_config" "${tmp_data:-}"' RETURN
    ln -s "$NVIM_DIR" "$tmp_config/nvim"

    local data_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
    local output

    if [[ -d "$data_dir/site/pack/core/opt" ]]; then
        echo "  Checking startup errors..."
        if ! output="$(XDG_CONFIG_HOME="$tmp_config" nvim --headless +qa 2>&1)" \
            || grep -qE '^(Error|E[0-9]+:)|Failed to load|Keymap without desc|Duplicate keymap' <<< "$output"; then
            log_error "Neovim reported errors on startup:"
            echo "$output"
            return 1
        fi

        echo "  Checking health (vim.pack / vim.lsp / nvim-treesitter)..."
        local health_file="$tmp_config/health.txt"
        XDG_CONFIG_HOME="$tmp_config" nvim --headless \
            "+checkhealth vim.pack vim.lsp nvim-treesitter" "+w! $health_file" +qa > /dev/null 2>&1 || true
        if grep -q 'ERROR' "$health_file" 2> /dev/null; then
            log_error "checkhealth reported errors:"
            grep -B1 -A3 'ERROR' "$health_file"
            return 1
        fi

        echo "  Checking <Leader> keymaps (desc / prefix conflicts)..."
        if ! output="$(XDG_CONFIG_HOME="$tmp_config" nvim --headless -c "luafile $FEATURE_DIR/checks/keymaps.lua" -c qa 2>&1)"; then
            log_error "Keymap check failed:"
            echo "$output"
            return 1
        fi
    else
        echo "  Skipping startup, health and keymap checks (plugins are not installed: run nvim once)"
    fi

    echo "  Checking that VSCode mode loads no plugins..."
    tmp_data="$(mktemp -d)"
    output="$(XDG_CONFIG_HOME="$tmp_config" XDG_DATA_HOME="$tmp_data" nvim --headless --cmd 'let g:vscode=1' \
        '+lua io.write(tostring(package.loaded["plugins"] ~= nil))' +qa 2>&1 || true)"
    if [[ "$output" != "false" || -d "$tmp_data/nvim/site/pack" ]]; then
        log_error "Plugins were loaded in VSCode mode: $output"
        return 1
    fi

    echo "  ✓ Neovim smoke test passed"
}

static_checks
smoke_test
