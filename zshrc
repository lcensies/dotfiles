# Initialize Starship prompt (only if not using Powerlevel10k)
eval "$(starship init zsh)"

export EDITOR=nvim
export VISUAL=nvim
export LIBVIRT_DEFAULT_URI=qemu:///system

# Load completions (optimized)
autoload -Uz compinit
# Only run compinit once per day unless .zcompdump is older than 24 hours
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

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
zstyle ':completion:*' menu select

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
# TODO: parametrize user name
zstyle :compinstall filename "/home/$USER/.zshrc"


# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases


export XDG_DATA_DIRS="/home/$USER/.nix-profile/share:$XDG_DATA_DIRS"

# Scripts
test -d ~/.scripts && export PATH="$PATH:/home/${USER}/.scripts"
test -d ~/.scripts/priv && export PATH="$PATH:/home/${USER}/.scripts/priv"
test -d ~/.local/bin && export PATH="$HOME/.local/bin:$PATH"
test -d ~/.local/bin/distrobox-exported && export PATH="$HOME/.local/bin/distrobox-exported:$PATH"

# Moving around words with ctrl + Arrow
# TODO also add vim-like shortcuts
# Other alternative is to set it in the Alacritty
# See https://github.com/alacritty/alacritty/issues/1408
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word


# SSH agent is managed by the system on NixOS, no need for manual setup


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


# Enter tmux if it's present and not already in tmux (only in interactive shells)
if [[ -n "$PS1" ]] && 
   command -v tmux &> /dev/null && 
   [[ ! "$TERM" =~ screen ]] && 
   [[ ! "$TERM" =~ tmux ]] && 
   [[ -z "$TMUX" ]] && 
   [[ -t 0 ]] &&
   [[ "${NO_TMUX}" != "true" ]]; then
   
  # Check if we're in an SSH session
  if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
    # SSH session - attach to existing session or create new one
    exec tmux new-session -A -s ssh
  else
    # Local session - attach to existing session or create new one
    exec tmux new-session -A -s local
  fi
fi

# Initialize tools only in interactive shells
if [[ -n "$PS1" ]]; then
  # Initialize zoxide
  # --cmd j is handled by custom alias which performs 
  # cd . with additional logic
  command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

  # Atuin will be initialized after plugins are loaded
fi

# Source fzf completions
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

# Configure fzf-tab
if command -v fzf-tab >/dev/null 2>&1; then
  # Disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # Set descriptions format to enable group support
  zstyle ':completion:*:descriptions' format '[%d]'
  # Set list-colors to show directories with different colors
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # Preview directory's content with exa when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
  # Switch group using `,` and `.`
  zstyle ':fzf-tab:*' switch-group ',' '.'
fi

# Virtual environment handling (only in interactive shells)
if [[ -n "$PS1" ]]; then
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
    (command -v exa >/dev/null && exa -F 2>/dev/null || ls -F)
  }

  function cd {
    builtin cd "$@" 
    ls_after_cd
    handle_venv
  }
fi

# Download antidote plugin manager if it's not present (only if needed)
if [[ ! -d ~/.antidote ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
fi

# Load antidote and plugins only in interactive shells
if [[ -n "$PS1" ]]; then
  source ~/.antidote/antidote.zsh
  antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins
  
  # Initialize atuin after plugins are loaded to avoid keybinding conflicts
  if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
  fi
fi
#
