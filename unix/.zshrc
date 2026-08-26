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
# nvm.sh is ~4600 lines of shell and sourcing it costs ~380ms per shell, which
# is by far the most expensive thing in this file. So don't: put the default
# version's bin directory straight onto PATH - that covers node, npm, npx and
# everything installed globally under it - and only source nvm.sh the first
# time `nvm` itself is called. Tab-completion for `nvm` also arrives then.
export NVM_DIR="$HOME/.nvm"

# Either the install-script layout under $NVM_DIR or the Homebrew one under
# $(brew --prefix nvm) - never both, loading nvm twice just costs startup time.
if [ -s "$NVM_DIR/nvm.sh" ]; then
	_nvm_sh="$NVM_DIR/nvm.sh"
	_nvm_completion="$NVM_DIR/bash_completion"
elif [ -n "$HOMEBREW_PREFIX" ] && [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]; then
	_nvm_sh="$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
	_nvm_completion="$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
fi

if [ -n "$_nvm_sh" ]; then
	# Drop the stubs first so the real definitions from nvm.sh replace them, then
	# re-dispatch. `nvm use` strips our PATH entry itself - it lives under
	# $NVM_DIR, which is exactly what nvm rewrites when switching versions.
	_nvm_load() {
		unfunction nvm node npm npx 2>/dev/null
		\. "$_nvm_sh"
		[ -s "$_nvm_completion" ] && \. "$_nvm_completion"
	}

	# Resolve the `default` alias to a concrete versions/node/<v>/bin. It can
	# point at another alias (default -> lts/* -> lts/jod -> v22.23.2), at a
	# partial version, or at `node`/`stable` meaning "the newest installed".
	_nvm_default_bin() {
		local target dirs i
		[ -r "$NVM_DIR/alias/default" ] || return 1
		target="$(<"$NVM_DIR/alias/default")"
		for i in 1 2 3; do
			[[ $target == v[0-9]* ]] && break
			[ -r "$NVM_DIR/alias/$target" ] || break
			target="$(<"$NVM_DIR/alias/$target")"
		done
		[[ $target == (node|stable|unstable) ]] && target=''
		# `nvm alias default 20` stores a bare `20`; the directories are `v20.*`.
		[[ $target == [0-9]* ]] && target="v$target"
		# (N) so a default naming an uninstalled version yields nothing rather than
		# a literal glob, (n) so v20.9.0 sorts before v20.10.0, (/) directories only.
		dirs=("$NVM_DIR/versions/node/${target}"*(Nn/))
		(( $#dirs )) || return 1
		print -r -- "${dirs[-1]}/bin"
	}

	_nvm_bin="$(_nvm_default_bin)"
	unfunction _nvm_default_bin

	if [ -n "$_nvm_bin" ]; then
		path=("$_nvm_bin" $path)
	else
		# No resolvable default, so node/npm/npx aren't on PATH at all. Fall back
		# to loading nvm on first use of any of them.
		node() { _nvm_load; node "$@" }
		npm()  { _nvm_load; npm "$@" }
		npx()  { _nvm_load; npx "$@" }
	fi
	unset _nvm_bin

	nvm() { _nvm_load; nvm "$@" }
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

# Ctrl+Left/Right: move by word. These are the sequences Ghostty sends.
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

