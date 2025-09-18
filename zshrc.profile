# Profiling version of zshrc - adds timing to identify slow sections
# Initialize Starship prompt (only if not using Powerlevel10k)
# eval "$(starship init zsh)"

# Start profiling
PROFILE_START=$(date +%s%N)
echo "ZSH Profile: Starting zshrc at $(date)" > /tmp/zsh_profile.log

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

PROFILE_COMPINIT=$(date +%s%N)
echo "ZSH Profile: After compinit: $(( (PROFILE_COMPINIT - PROFILE_START) / 1000000 ))ms" >> /tmp/zsh_profile.log

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

PROFILE_BASIC=$(date +%s%N)
echo "ZSH Profile: After basic config: $(( (PROFILE_BASIC - PROFILE_COMPINIT) / 1000000 ))ms" >> /tmp/zsh_profile.log

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases

PROFILE_ALIASES=$(date +%s%N)
echo "ZSH Profile: After aliases: $(( (PROFILE_ALIASES - PROFILE_BASIC) / 1000000 ))ms" >> /tmp/zsh_profile.log

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

PROFILE_PATHS=$(date +%s%N)
echo "ZSH Profile: After paths: $(( (PROFILE_PATHS - PROFILE_ALIASES) / 1000000 ))ms" >> /tmp/zsh_profile.log

# Enter tmux if it's present and not already in tmux (only in interactive shells)
if [[ -n "$PS1" ]] && command -v tmux &> /dev/null && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [[ -z "$TMUX" ]] && [[ -t 0 ]]; then
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

  # Initialize atuin
  if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
  fi
fi

PROFILE_TOOLS=$(date +%s%N)
echo "ZSH Profile: After tools: $(( (PROFILE_TOOLS - PROFILE_PATHS) / 1000000 ))ms" >> /tmp/zsh_profile.log

# Source fzf completions
# if command -v fzf >/dev/null 2>&1; then
#   eval "$(fzf --zsh)"
# fi

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

PROFILE_VENV=$(date +%s%N)
echo "ZSH Profile: After venv: $(( (PROFILE_VENV - PROFILE_TOOLS) / 1000000 ))ms" >> /tmp/zsh_profile.log

# Download antidote plugin manager if it's not present (only if needed)
if [[ ! -d ~/.antidote ]]; then
  git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
fi

# Load antidote and plugins only in interactive shells
if [[ -n "$PS1" ]]; then
  source ~/.antidote/antidote.zsh
  antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins
fi

PROFILE_PLUGINS=$(date +%s%N)
echo "ZSH Profile: After plugins: $(( (PROFILE_PLUGINS - PROFILE_VENV) / 1000000 ))ms" >> /tmp/zsh_profile.log

PROFILE_END=$(date +%s%N)
echo "ZSH Profile: Total time: $(( (PROFILE_END - PROFILE_START) / 1000000 ))ms" >> /tmp/zsh_profile.log
echo "ZSH Profile: Completed at $(date)" >> /tmp/zsh_profile.log
