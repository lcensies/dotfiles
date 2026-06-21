#!/usr/bin/env bash
#
# Accordion for the secondary (drawer) panes of a main-vertical layout.
#
# Fired on `pane-focus-in`. When the focused pane has vertical siblings in
# its column (i.e. it is one of the stacked drawer panes), it is expanded to
# the full window height, collapsing the other panes in that column down to a
# single status line (their cwd / running command is shown via the pane
# border, see auto-hide.tmux).
#
# The main pane lives alone in its own column, so focusing it does nothing:
# the last-expanded drawer pane stays expanded.

set -eu

active_id="$(tmux display-message -p '#{pane_id}')"
active_left="$(tmux display-message -p '#{pane_left}')"

# How many panes share the active pane's column (same left edge)?
column_count="$(tmux list-panes -F '#{pane_left}' | grep -cx "$active_left")"

# Only accordion when the active pane actually has siblings to collapse.
if [ "$column_count" -gt 1 ]; then
  tmux resize-pane -t "$active_id" -y "$(tmux display-message -p '#{window_height}')"
fi
