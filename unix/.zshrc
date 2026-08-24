# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Keep PATH free of duplicates when this file is re-sourced.
typeset -U path PATH

path=(
	$path
	"$HOME/source/repos/helper-scripts"
	"$HOME/.dotnet/tools"
)

ZSH_THEME="agnoster"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	z
)
ZSHZ_CASE=smart

# We set the terminal title ourselves below.
DISABLE_AUTO_TITLE="true"

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# User configuration

[ -f $HOME/.env ] && set -a && source $HOME/.env && set +a

# export MANPATH="/usr/local/man:$MANPATH"

prompt_context(){}

# Homebrew (Apple Silicon, Intel macOS, Linuxbrew) - before anything that
# relies on brew-installed binaries being on PATH.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
	if [ -x "$_brew" ]; then
		eval "$("$_brew" shellenv)"
		break
	fi
done
unset _brew

# Atuin
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
command -v atuin >/dev/null && eval "$(atuin init zsh)"

# GO
[ -d /usr/local/go/bin ] && path=($path /usr/local/go/bin)
export GOPATH=$HOME/go
[ -d "$GOPATH/bin" ] && path=($path "$GOPATH/bin")

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# nvm installed via Homebrew lives under $(brew --prefix nvm)
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# Terminal/tab title: always the current directory, matching the tmux
# automatic-rename-format. %1~ is the trailing path component, or ~ at $HOME.
autoload -Uz add-zsh-hook
_set_term_title() { print -Pn '\e]2;%1~\a' }
add-zsh-hook precmd _set_term_title

_gco() {
  gco $(gum choose $(git branch --format='%(refname:short)'))
}

alias _ghpr='gh pr checkout --force'

# Ctrl+Left/Right: move by word. These are the sequences Ghostty sends.
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
