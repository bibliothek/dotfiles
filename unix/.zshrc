# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Keep PATH free of duplicates when this file is re-sourced.
typeset -U path PATH

# Rancher Desktop's shims go first so its docker/kubectl/nerdctl win over any
# other install. Everything else is appended.
path=(
	"$HOME/.rd/bin"
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

# Export everything .env defines. Not a && chain: if the last statement in .env
# returns non-zero, `set +a` would be skipped and allexport would stay on for
# the rest of this file.
if [ -f "$HOME/.env" ]; then
	set -a
	source "$HOME/.env"
	set +a
fi

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
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Terminal/tab title: always the current directory, matching the tmux
# automatic-rename-format. %1~ is the trailing path component, or ~ at $HOME.
autoload -Uz add-zsh-hook
_set_term_title() { print -Pn '\e]2;%1~\a' }
add-zsh-hook precmd _set_term_title

# Claude Code otherwise rewrites the title continuously while it runs, and the
# precmd hook above only fires again once claude exits.
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1

_gco() {
  gco $(gum choose $(git branch --format='%(refname:short)'))
}

alias _ghpr='gh pr checkout --force'
alias k='kubectl'

# Ctrl+Left/Right: move by word. These are the sequences Ghostty sends.
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

