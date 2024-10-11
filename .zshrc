# powerlevel10k instant prompt
# must be at top of .zshrc, apart from initialization code
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ZSHRC of moellh
# last update on 2024-10-03

# zsh completion system
autoload -Uz compinit
compinit

# keybindngs

# home key moves cursor to beginning of line
bindkey "^[[H" beginning-of-line
# end key moves cursor to end of line
bindkey "^[[F" end-of-line

# <C-Left> moves cursor one word to left
bindkey "^[[1;5D" backward-word
# <C-Right> moves cursor one word to right
bindkey "^[[1;5C" forward-word

# <C-Backspace> deletes one word
bindkey "^[[3~" delete-char

# Up and Down arrow keys to scroll search history
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# load powerlevel10k
source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# word selection like bash
autoload -U select-word-style
select-word-style bash

# java
export JAVA_HOME="/usr/lib/jvm/default"

# binaries
export PATH="${PATH}:$HOME/.local/bin" # user binaries

# fzf tools for zsh
source <(fzf --zsh)

# zsh history
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory

# aliases

## ls aliases
alias ls="/bin/ls --hyperlink=auto --color=auto -hF $@"
alias ll="ls -al"

## kitty aliases
alias mg="kitty +kitten hyperlinked_grep --smart-case $@"
alias icat="kitten icat"
alias ssk="kitty +kitten ssh $@"

# color directories
eval "$(dircolors -b ~/.dircolors)"

# zoxide
eval "$(zoxide init zsh)"
alias cd="z $@"

# zsh plugins
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# custom scripts
export PATH="${PATH}:$HOME/.scripts" # user binaries

# default editor
EDITOR="nvim"

# use kde file dialog for gtk applications
export GTK_USE_PORTAL=1

# set cursor theme
export XCURSOR_SIZE=24
export XCURSOR_THEME=Adwaita

# required for jupyter lab extensions on arch linux
export JUPYTERLAB_DIR=$HOME/.local/share/jupyter/lab

# go
export GOPATH="$(go env GOPATH)"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOBIN"

# load pyenv for shell
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# lazygit
alias lg="lazygit"

# alias für neovim
alias nv="nvim"
alias ns="search_to_nvim"

# open file with default application
alias open="xdg-open"
 
# setup for bachelor thesis
export BATH=~/studies/bath
source $HOME/spack/share/spack/setup-env.sh
export HPX_DIR=/home/moellh/spack/opt/spack/linux-endeavourosrolling-skylake/gcc-14.2.1/hpx-1.10.0-if6kd37pinezdqim67eu4nf2yncosazh/lib/cmake/HPX/
export HPX_INCLUDE=/home/moellh/spack/opt/spack/linux-endeavourosrolling-skylake/gcc-14.2.1/hpx-1.10.0-if6kd37pinezdqim67eu4nf2yncosazh/include/
export BOOST_INCLUDE=/home/moellh/spack/opt/spack/linux-endeavourosrolling-skylake/gcc-14.2.1/boost-1.86.0-a7yco7hbfiigu4p2mwj7ijahf3mzmxpb/include/
