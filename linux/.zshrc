# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PATH="$PATH:$HOME/source/repos/win11-setup/scripts:/home/martin/.dotnet/tools"

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

source $ZSH/oh-my-zsh.sh

# User configuration

[ -f $HOME/.env ] && set -a && source $HOME/.env && set +a

# export MANPATH="/usr/local/man:$MANPATH"

prompt_context(){}

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# GO
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

