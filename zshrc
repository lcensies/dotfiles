# home-manager sessionVariables (not auto-sourced: .zshrc is dotfile-managed, programs.zsh off)
[ -f /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh ] && source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh

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
test -d ~/.cargo/bin && export PATH="$HOME/.cargo/bin:$PATH"
# cgroup-limit shims — must stay first in PATH, after all other prepends
test -d ~/.scripts/climit-wrappers && export PATH="$HOME/.scripts/climit-wrappers:$PATH"



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


# ── Orca / tmux integration ─────────────────────────────────────────────
# Orca terminals get a session per project and a window per worktree
# (orca worktree layout: <project>__worktrees/<worktree>), so multiple
# orca panes don't fight over the shared "local" session.

# True if this shell was spawned by the orca-ide daemon (process ancestry)
_orca_launched() {
  local pid=$PPID i
  for i in {1..5}; do
    [[ "$(ps -o comm= -p "$pid" 2>/dev/null)" == "orca-ide" ]] && return 0
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    [[ -z "$pid" || "$pid" -le 1 ]] && return 1
  done
  return 1
}

# exec into the project session, focused on this worktree's window.
# Orca terminals live on their own tmux server (-L orca, own config):
# local plugins (sessionx kill, resurrect/continuum saves) never touch
# orca sessions, and orca policy (detach-on-destroy on) is global there.
_orca_tmux() {
  local proj win base s n
  local -a busy T
  T=(tmux -L orca -f "$HOME/.dotfiles/tmux/orca.conf")
  if [[ "$PWD" == *__worktrees/* ]]; then
    proj=${${PWD%%__worktrees/*}:t}
    win=${${PWD##*__worktrees/}%%/*}
  else
    proj=${PWD:t}
    win=main
  fi
  # Sanitize to a tmux-target-safe charset: `.`/`:` are target separators,
  # whitespace breaks the busy-scan word split
  proj=${proj//[^[:alnum:]_-]/_}
  win=${win//[^[:alnum:]_-]/_}
  # GC grouped sessions leaked by a crash in the create→attach gap (they
  # have no destroy-unattached yet, see below) — live ones are always
  # attached, so unattached + older than 10s == leaked
  local cutoff=$(( $(date +%s) - 10 ))
  "${T[@]}" list-sessions -F '#{session_group} #{session_name} #{session_attached} #{session_created}' 2>/dev/null |
    while read -r g s att created; do
      [[ "$g" == "$proj" && "$s" != "$proj" && "$att" == 0 && "$created" -lt "$cutoff" ]] &&
        "${T[@]}" kill-session -t "=$s" 2>/dev/null
    done
  # Orca sends keystrokes to the pty, which land on that client's ACTIVE
  # window — so two orca terminals must never sit on the same window, or
  # `orca terminal send` to one types into the other. Windows held by
  # other grouped sessions are busy; take the next -N suffix.
  # ponytail: not atomic — two shells spawning in the same instant can
  # still pick the same window; claim via tmux wait-for lock if it bites
  for s in $("${T[@]}" list-sessions -F '#{session_group} #{session_name}' 2>/dev/null |
             awk -v g="$proj" '$1==g && $2!=g {print $2}'); do
    busy+=("$("${T[@]}" list-windows -t "=$s" -F '#{window_active} #{window_name}' 2>/dev/null |
              awk '$1==1 {sub(/^1 /,""); print; exit}')")
  done
  base=$win n=1
  while (( ${busy[(Ie)$win]} )); do (( n++ )); win="$base-$n"; done
  # Forward Orca identity into the window shell: tmux panes inherit server
  # env, not the invoking shell's, so without -e a second orca pane would
  # run under the first pane's ORCA_TERMINAL_HANDLE (or none at all)
  "${T[@]}" has-session -t "=$proj" 2>/dev/null ||
    "${T[@]}" new-session -d -s "$proj" -n "$win" -c "$PWD" \
      -e ORCA_TERMINAL_HANDLE="$ORCA_TERMINAL_HANDLE" -e ORCA_PANE_KEY="$ORCA_PANE_KEY"
  "${T[@]}" list-windows -t "=$proj" -F '#W' | grep -qxF -- "$win" ||
    "${T[@]}" new-window -d -t "=$proj" -n "$win" -c "$PWD" \
      -e ORCA_TERMINAL_HANDLE="$ORCA_TERMINAL_HANDLE" -e ORCA_PANE_KEY="$ORCA_PANE_KEY"
  # Stamp this terminal's identity on the window (window-scoped user
  # options) — on window reuse the pane's old shell has stale ORCA_* env;
  # _orca_refresh_env re-reads these each prompt
  "${T[@]}" set-option -w -t "=$proj:$win" @orca_handle "$ORCA_TERMINAL_HANDLE" \; \
    set-option -w -t "=$proj:$win" @orca_pane_key "$ORCA_PANE_KEY" 2>/dev/null
  # Grouped throwaway session so each orca pane focuses its own window
  # independently. Created detached + focused first so it marks the window
  # busy for the next spawn before we even attach.
  "${T[@]}" new-session -d -t "=$proj" -s "$proj-$$" \; \
    select-window -t "=$proj-$$:$win"
  # destroy-unattached only AFTER attach: set earlier, any client death on
  # the server sweeps the not-yet-attached session and attach fails with
  # "can't find session" (hits every app-quit→reopen pty respawn burst).
  # Per-session, not in orca.conf: a global would reap the unattached base
  # sessions that carry persistence.
  exec "${T[@]}" attach-session -t "=$proj-$$" \; \
    set-option destroy-unattached on
}

# Refresh ORCA_* env from window-scoped options: a reused window's shell
# outlives the orca terminal that spawned it, so its handle goes stale
# until the next attach stamps the window (see _orca_tmux)
_orca_refresh_env() {
  local out h k
  out=$(tmux display-message -p '#{@orca_handle}::#{@orca_pane_key}' 2>/dev/null) || return
  h=${out%%::*} k=${out##*::}
  [[ -n "$h" && "$h" != "$ORCA_TERMINAL_HANDLE" ]] && export ORCA_TERMINAL_HANDLE="$h"
  [[ -n "$k" && "$k" != "$ORCA_PANE_KEY" ]] && export ORCA_PANE_KEY="$k"
}
[[ -n "$TMUX" ]] && precmd_functions+=(_orca_refresh_env)

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
  elif _orca_launched; then
    _orca_tmux
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
  # Register atuin init BEFORE loading plugins so zsh-vi-mode's zvm_after_init
  # hook picks it up (zvm fires the hook during its own init inside antidote load)
  if command -v atuin >/dev/null 2>&1; then
    zvm_after_init_commands+=('eval "$(atuin init zsh)"; bindkey "^r" atuin-search')
  fi

  source ~/.antidote/antidote.zsh
  antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins
fi
#
eval "$(direnv hook zsh)"
