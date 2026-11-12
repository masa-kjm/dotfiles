#!/usr/bin/env bash
set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Color output
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_RED='\033[0;31m'

log_step() {
    echo -e "${COLOR_GREEN}==>${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*"
}

# Validate profile format
validate_profiles() {
    log_step "Validating profile format..."
    
    local profiles=(
        "$DOTFILES_ROOT/profiles/linux.yaml"
        "$DOTFILES_ROOT/profiles/wsl.yaml"
        "$DOTFILES_ROOT/profiles/windows.yaml"
    )
    
    local has_errors=0
    
    for profile in "${profiles[@]}"; do
        if [[ ! -f "$profile" ]]; then
            log_error "Profile not found: $profile"
            has_errors=1
            continue
        fi
        
        echo "  Checking: $profile"
        
        # Check YAML syntax
        if ! yq eval '.' "$profile" > /dev/null 2>&1; then
            log_error "Invalid YAML syntax: $profile"
            has_errors=1
            continue
        fi
        
        # Check features is a map (not array)
        local features_type=$(yq eval '.features | type' "$profile")
        if [[ "$features_type" != "!!map" ]]; then
            log_error "features must be a map, got: $features_type in $profile"
            has_errors=1
            continue
        fi
        
        # Check each feature value is a map (or null)
        local feature_names=($(yq eval '.features | keys | .[]' "$profile" 2>/dev/null || true))
        for feature in "${feature_names[@]}"; do
            local feature_type=$(yq eval ".features.${feature} | type" "$profile")
            if [[ "$feature_type" != "!!map" && "$feature_type" != "!!null" ]]; then
                log_error "Feature '$feature' must be a map, got: $feature_type in $profile"
                has_errors=1
            fi
        done
    done
    
    if [[ $has_errors -eq 0 ]]; then
        echo "  ✓ All profiles valid"
    else
        return 1
    fi
}

# Run feature-specific checks (features/<name>/lint.sh)
validate_features() {
    local script
    for script in "$DOTFILES_ROOT"/features/*/lint.sh; do
        [[ -f "$script" ]] || continue
        log_step "Running $(basename "$(dirname "$script")") feature checks..."
        bash "$script" || return 1
    done
}

# Main
log_step "Running quality checks..."

validate_profiles || exit 1
validate_features || exit 1

log_step "All checks passed!"
