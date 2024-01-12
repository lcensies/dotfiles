# Dont try to display a fancy theme in a tty
if [[ $TERM == "linux" ]]; then
  [[ ! -f ~/.p10k-portable.zsh ]] || source ~/.p10k-portable.zsh
else
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Move one word left or right using alt
bindkey "[D" backward-word
bindkey "^[h" backward-word
bindkey "[C" forward-word
bindkey "^[l" forward-word

# Aliases
alias ls="ls --color=auto"
alias lsblk="lsblk -o +LABEL"
alias ip="ip -c"
alias showip="ip --brief a"
alias ssh='TERM=xterm ssh'
alias ll="ls -l"

# Lines configured by zsh-newuser-install
bindkey -e

# History config
HIST_IGNORE_DUPS="true"
HIST_STAMPS="mm/dd/yyyy"
HISTFILE=~/.zsh_history
HISTSIZE=999999
SAVEHIST=$HISTSIZE
setopt SHARE_HISTORY

# Autocompletion behaviour
autoload -Uz compinit; compinit
zstyle ':completion:*' menu select

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
# TODO: parametrize user name
zstyle :compinstall filename '/home/esc2/.zshrc'

autoload -Uz compinit
compinit

# End of lines added by compinstall
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Scripts
test -d ~/.scripts && export PATH="$PATH:/home/${USER}/.scripts"

# Moving around words with ctrl + Arrow
# TODO also add vim-like shortcuts
# Other alternative is to set it in the Alacritty
# See https://github.com/alacritty/alacritty/issues/1408
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word


# Start SSH agent on login
# TODO consider enabling it on headless sessions
# TODO consider using keychain
# https://wiki.archlinux.org/title/SSH_keys#Start_ssh-agent_with_systemd_user
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# Autostart X server on login to get WM working without
# typing startx each time after reboot
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec startx
fi




# Configure tmux prompt
# Not necesarry anymore due to plugin
# TODO: remove
# https://that.guru/blog/automatically-set-tmux-window-name/
case "$TERM" in
linux|xterm*|rxvt*)
  export PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}: ${PWD##*/}\007"'
  ;;
screen*)
  export PROMPT_COMMAND='echo -ne "\033k${HOSTNAME%%.*}: ${PWD##*/}\033\\" '
  ;;
*)
  ;;
esac

# Plugin rename-window requires customization
# tmux-window-name() {
# 	($TMUX_PLUGIN_MANAGER_PATH/tmux-window-name/scripts/rename_session_windows.py &)
# }

# Enter tmux if it's present
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  # Set hook for windows renaming
  #add-zsh-hook chpwd tmux-window-name
  exec tmux
fi

# Initialize zoxide
which zoxide >/dev/null && eval "$(zoxide init --cmd j zsh)"

# Source fzf completions
source /usr/share/fzf/key-bindings.zsh 2>/dev/null
source /usr/share/fzf/completion.zsh 2>/dev/null


if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi

if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec startx
fi
