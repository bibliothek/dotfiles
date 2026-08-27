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

# Ghostty always starts inside tmux: attach to the "main" session, creating it
# on first launch (-A). Later Ghostty windows join that same session rather than
# spawning their own. Placed after the brew shellenv above (tmux comes from
# brew) and before the slower setup below, which the inner shell redoes anyway.
# The $TMUX guard keeps this from recursing inside tmux itself.
if [[ "$TERM_PROGRAM" == "ghostty" && -z "$TMUX" ]] && command -v tmux >/dev/null; then
	exec tmux new-session -A -s main
fi

# Atuin
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
command -v atuin >/dev/null && eval "$(atuin init zsh)"

# GO
[ -d /usr/local/go/bin ] && path=($path /usr/local/go/bin)
export GOPATH=$HOME/go
[ -d "$GOPATH/bin" ] && path=($path "$GOPATH/bin")

# NVM
# nvm's install script always lands in $HOME/.nvm, and sourcing its ~4600-line
# nvm.sh costs ~380ms on every single shell. So don't: put the default
# version's bin directory straight on PATH - that covers node, npm, npx and
# everything installed globally under it - and leave `nvm` itself as a stub
# that sources nvm.sh (and its completion) the first time it is called.
export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
	nvm() {
		unfunction nvm
		\. "$NVM_DIR/nvm.sh"
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
		nvm "$@"
	}

	if [ -r "$NVM_DIR/alias/default" ]; then
		# default may point at another alias: default -> lts/* -> lts/jod -> v22.23.2
		_nvm_v="$(<$NVM_DIR/alias/default)"
		[ -r "$NVM_DIR/alias/$_nvm_v" ] && _nvm_v="$(<$NVM_DIR/alias/$_nvm_v)"
		[ -r "$NVM_DIR/alias/$_nvm_v" ] && _nvm_v="$(<$NVM_DIR/alias/$_nvm_v)"
		[[ $_nvm_v == [0-9]* ]] && _nvm_v="v$_nvm_v"          # `nvm alias default 20`
		[[ $_nvm_v == (node|stable|unstable) ]] && _nvm_v=''  # newest installed
		# (N) nothing at all if that version isn't installed, (n) so that v20.9.0
		# sorts before v20.10.0, (/) directories only.
		_nvm_dir=("$NVM_DIR/versions/node/$_nvm_v"*(Nn/))
		(( $#_nvm_dir )) && path=("${_nvm_dir[-1]}/bin" $path)
		unset _nvm_v _nvm_dir
	fi
fi

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
alias gg='lazygit'

# Ctrl+Left/Right: move by word. These are the sequences Ghostty sends.
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

