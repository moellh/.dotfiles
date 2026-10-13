# ZSH configuration
# Preferably use ~/.zshrc.local for system specific configuration, so .zshrc works on any system (Not yet employed).

## P10K ==================================================================== {{{

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source ~/.p10k.zsh

## }}}

## ZSH plugins ============================================================= {{{

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## }}}

# ZSH options ============================================================== {{{

# Completion
autoload -Uz compinit
compinit

# word selection like bash
autoload -U select-word-style
select-word-style bash

# Up and Down arrow keys to scroll search history
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

## zsh history
setopt appendhistory

## }}}

## KEYBINDS ================================================================ {{{

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

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

## }}}

## ALIASES ================================================================= {{{

alias dark='cp ~/.config/kitty/Catppuccin-Mocha.conf ~/.config/kitty/current-theme.conf && kill -SIGUSR1 $(pgrep kitty) && reload_tmux '
alias grep="grep --color=always"
alias agent="ssh -t hermes 'bash -lc hermes'"
alias icat="kitten icat"
alias lg="lazygit"
alias light='cp ~/.config/kitty/Catppuccin-Latte.conf ~/.config/kitty/current-theme.conf && kill -SIGUSR1 $(pgrep kitty) && reload_tmux'
alias ll="lsd -al"
alias lo="lsd -a --oneline"
alias ls="lsd"
alias mg="kitty +kitten hyperlinked_grep --smart-case $@"
alias ns="search_to_nvim"
alias open="xdg-open"
alias ra="ranger"
alias ranger=". ranger"
alias ssk="kitty +kitten ssh $@"

## }}}

## ENVIRONMENT VARIABLES =================================================== {{{

source $HOME/data/env

export PYENV_ROOT="$HOME/.pyenv"
export JAVA_HOME="/usr/lib/jvm/default"
export ANKI_WAYLAND=1
export COLOR_SCHEME="dark"
export EDITOR="nvim"
export GTK_USE_PORTAL=1 # use kde file dialog for gtk applications
export FZF_ALT_C_COMMAND="fd --type=d --hidden --exclude .git"
export HISTFILE=~/.histfile
export HISTSIZE=100000
export JUPYTERLAB_DIR=$HOME/.local/share/jupyter/lab # required for jupyter lab extensions on arch linux
export PATH="${PATH}:$HOME/.scripts" # user binaries
export PATH="${PATH}:$HOME/.local/bin" # user binaries
export PATH=$HOME/.nix-profile/bin:$PATH
export QT_QPA_PLATFORM=wayland
export SAVEHIST=100000
export XCURSOR_SIZE=24
export XCURSOR_THEME=Adwaita
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

## }}}

## FUNCTIONS =============================================================== {{{

EDIT_FILES=(
    $HOME/.config/hypr/hyprland.lua
    $HOME/.zshrc
)
edit() {
    for file in "${EDIT_FILES[@]}"; do
        if [[ "$file" == *"$1"* ]]; then
            nvim "$file"
            return
        fi
    done
    echo "No matching file found."
}

opencode() {
    command opencode "$@"

    # \033 is ESC
    # [    is CSI (Control Sequence Introducer)
    # 9A   is CUU-n (Cursor Up n)
    # J    is ED (Erase in Display)
    printf '\033[9A\033[J'
}

reload_tmux() {
    if tmux ls &> /dev/null; then
        tmux source-file ~/.config/tmux/tmux.conf
    fi
}

y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

## }}}

## APPS ==================================================================== {{{

eval "$(dircolors -b ~/.dircolors)"

source <(fzf --zsh)

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

eval "$(zoxide init zsh)"

## }}}

## TEMPORARY ADDITIONS ===================================================== {{{

## }}}
