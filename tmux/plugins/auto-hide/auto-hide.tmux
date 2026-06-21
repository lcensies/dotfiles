#!/usr/bin/env bash
#
# auto-hide: turn the right-hand column of a main-vertical layout into an
# auto-collapsing drawer. The focused drawer pane expands; the others shrink
# to a single line that still shows their cwd / running command.

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# NOTE: the pane border status line that shows a collapsed pane's cwd/command
# lives in the main tmux config (pane-border-status / pane-border-format), not
# here -- it's generally useful and not specific to auto-hide.

# --- Auto-accordion on focus ----------------------------------------------
# `after-select-pane` fires on internal pane switches (keybinds, mouse,
# vim-tmux-navigator); `pane-focus-in` only fires when the terminal/client
# regains focus, so we hook both. Overwrite (not -a) so reloads don't stack
# duplicate hooks; nothing else in the config uses these two hooks.
ahcmd="run-shell -b '$CURRENT_DIR/scripts/auto_hide.sh'"
tmux set-hook -g after-select-pane "$ahcmd"
tmux set-hook -g pane-focus-in "$ahcmd"
