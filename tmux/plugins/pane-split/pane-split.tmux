#!/usr/bin/env sh
# pane-split: tilish's Alt+Enter "open terminal" extracted as a standalone
# plugin (tmux-tilish/tilish.tmux, non-legacy branch), pinned to its
# main-vertical layout: first split goes side by side, every next pane
# stacks below the last in the right column (dwm-style master + stack).
# Layout applied only on Alt+Enter — no global hooks, manual prefix+h/v
# splits keep their sizes.
# Used by the orca profile; the local profile gets this from tilish itself.
tmux bind -n M-Enter run-shell 'cwd="`tmux display -p \"#{pane_current_path}\"`"; tmux select-pane -t "bottom-right"; tmux split-pane -c "$cwd"; tmux select-layout main-vertical'
