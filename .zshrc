# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ZSHRC from moellh on 25.05.2024
autoload -Uz compinit
compinit

# Key-Bindings
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[3~" delete-char
bindkey "^H" backward-kill-word

# Search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload -U select-word-style
select-word-style bash

export JAVA_HOME="/usr/lib/jvm/default"

export PATH="${PATH}:/mnt/data/studies/bfp/programming/install/bin"
export PATH="${PATH}:$JAVA_HOME/bin"
export PATH="${PATH}:$HOME/.local/bin"
export PATH="${PATH}:$HOME/bin"

source <(fzf --zsh)

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

alias ls="/bin/ls --hyperlink=auto --color=auto -hF $@"
alias ll="ls -al"

eval "$(dircolors -b ~/.dircolors)"

alias mg="kitty +kitten hyperlinked_grep --smart-case $@"
alias icat="kitten icat"
alias ssk="kitty +kitten ssh $@"

eval "$(zoxide init zsh)"
alias cd="z $@"

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

EDITOR="nvim"
export GTK_USE_PORTAL=1

export XCURSOR_SIZE=24
export XCURSOR_THEME=Adwaita

export JUPYTERLAB_DIR=$HOME/.local/share/jupyter/lab
export GOPATH="$(go env GOPATH)"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

alias lg="lazygit"
alias nv="nvim"
alias ns="search_to_nvim"
alias open="xdg-open"
