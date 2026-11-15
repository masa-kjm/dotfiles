# The operating system type for dotfiles configuration scripts
export DOTFILES_OS_TYPE=linux
# Set the default editor to nvim
export EDITOR=nvim
# default less options
export LESS='-i -M -R'

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate bash)"
fi

