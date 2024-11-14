# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR=nvim
export VISUAL=nvim
export LIBVIRT_DEFAULT_URI=qemu:///system

# Load completions
autoload -Uz compinit && compinit

# Doesn't work for some reason. 
# Anyway, jo . can be used as alternative
function fuzzy-xdg-open {
  local output
  output=$(fzf --height 40% --reverse </dev/tty) && xdg-open ${(q-)output}
  zle reset-prompt
}

bindkey -r "^o"
bindkey -r "^O"
zle -N fuzzy-xdg-open
bindkey '^o' fuzzy-xdg-open

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
zstyle :compinstall filename "/home/$USER/.zshrc"

autoload -Uz compinit
compinit


# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# Scripts
test -d ~/.scripts && export PATH="$PATH:/home/${USER}/.scripts"
test -d ~/.scripts/priv && export PATH="$PATH:/home/${USER}/.scripts/priv"

# Moving around words with ctrl + Arrow
# TODO also add vim-like shortcuts
# Other alternative is to set it in the Alacritty
# See https://github.com/alacritty/alacritty/issues/1408
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word


SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "Initialising new SSH agent..." > /dev/null
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded > /dev/null
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    find $HOME/.ssh | xargs /usr/bin/ssh-add >dev/null 2>&1
    # /usr/bin/ssh-add >/dev/null 2>&1
}



# Autostart X server on login to get WM working without
# typing startx each time after reboot
# if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
#   exec startx
# fi

# Configure tmux prompt
# Not necesarry anymore due to plugin
# TODO: remove
# https://that.guru/blog/automatically-set-tmux-window-name/
# case "$TERM" in
# linux|xterm*|rxvt*)
#   export PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}: ${PWD##*/}\007"'
#   ;;
# screen*)
#   export PROMPT_COMMAND='echo -ne "\033k${HOSTNAME%%.*}: ${PWD##*/}\033\\" '
#   ;;
# *)
#   ;;
# esac


# Enter tmux if it's present
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#   exec tmux
#   # https://www.reddit.com/r/tmux/comments/s5hpdz/how_to_prevent_tmux_from_creating_a_new_session/
#   # exec tmux new-session -A -s local
# fi

# Initialize zoxide
# --cmd j is handled by custom alias which performs 
# cd . with additional logic
which zoxide >/dev/null && eval "$(zoxide init  zsh)"

# Source fzf completions
source /usr/share/fzf/key-bindings.zsh 2>/dev/null
source /usr/share/fzf/completion.zsh 2>/dev/null

function handle_venv {
  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If env folder is found then activate the vitualenv
      if [[ -d ./venv ]] ; then
        source ./venv/bin/activate
      fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
      fi
  fi
}
# Handle venv on shell spawn
handle_venv

function ls_after_cd {
  (exa -F 2>/dev/null || ls -F)
}

function cd {
  builtin cd "$@" 
  ls_after_cd
  handle_venv
}


# Download antidote plugin manager if it's not present
[[ -d ~/.antidote ]] || git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
source ~/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins 


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
