################################################################################
# ZSH configuration file
#
# - supposed to work on any system, where .dotfiles repo has been installed
# - for system specific configuration, use .zshrc.local
################################################################################

# powerlevel10k instant prompt
# must be at top of .zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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


## zsh history
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory

# zsh plugins
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Aliases

alias ls="lsd"
alias ll="lsd -al"

# color directories
eval "$(dircolors -b ~/.dircolors)"

# custom scripts
export PATH="${PATH}:$HOME/.scripts" # user binaries
export PATH="${PATH}:$HOME/.local/bin" # user binaries

# default editor
EDITOR="nvim"

# java
export JAVA_HOME="/usr/lib/jvm/default"

# fzf
## use fzf tools for zsh
source <(fzf --zsh)
export FZF_ALT_C_COMMAND="fd --type=d --hidden --exclude .git"

# kitty
alias mg="kitty +kitten hyperlinked_grep --smart-case $@"
alias icat="kitten icat"
alias ssk="kitty +kitten ssh $@"

# zoxide
eval "$(zoxide init zsh)"

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

# Alias for neovim as vim because is vim is installed on most systems
alias ns="search_to_nvim"
alias ra="ranger"

# open file with default application
alias open="xdg-open"

reload_tmux() {
  if tmux ls &> /dev/null; then
    tmux source-file ~/.config/tmux/tmux.conf
  fi
}
alias dark='cp ~/.config/kitty/Catppuccin-Mocha.conf ~/.config/kitty/current-theme.conf && kill -SIGUSR1 $(pgrep kitty) && reload_tmux '
alias light='cp ~/.config/kitty/Catppuccin-Latte.conf ~/.config/kitty/current-theme.conf && kill -SIGUSR1 $(pgrep kitty) && reload_tmux'

alias grep="grep --color=always"

alias ranger=". ranger"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Use `y` to open yazi and automatically cd into directory on exit
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'
