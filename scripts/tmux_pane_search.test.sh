#!/usr/bin/env bash
# The non-obvious part of tmux_pane_search is the `up` offset: cursor-up must
# land on the line that matched, including when capture-pane dropped trailing
# blank rows. Two panes, two asserts, real tmux server on its own socket.
set -euo pipefail

script="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/tmux_pane_search"
sock="panesearch-test-$$"
shim="$(mktemp -d)"
trap 'tmux -L "$sock" kill-server 2>/dev/null || true; rm -rf "$shim"' EXIT

# The script calls plain `tmux`; point that at the test server.
printf '#!/bin/sh\nexec %s -L %s "$@"\n' "$(command -v tmux)" "$sock" >"$shim/tmux"
chmod +x "$shim/tmux"
export PATH="$shim:$PATH"

tmux -L "$sock" new-session -d -x 80 -y 20 'bash --norc --noprofile'
sleep 0.5
# Pane 1: full screen + history, no trailing blank rows.
tmux -L "$sock" send-keys 'clear; for i in $(seq 1 120); do echo marker-line-$i; done' Enter
# Pane 2: a couple of lines, rest of the screen blank (exercises the pad).
tmux -L "$sock" split-window -d 'bash --norc --noprofile'
sleep 0.3
tmux -L "$sock" send-keys -t 2 'clear; echo needle-near-top' Enter
sleep 1

assert_jump() { # assert_jump <needle>
	local needle="$1" id up
	IFS=$'\t' read -r id up _ < <("$script" --candidates | grep -m1 -F "| $needle")
	tmux -L "$sock" copy-mode -t "$id"
	[ "$up" -gt 0 ] && tmux -L "$sock" send-keys -X -t "$id" -N "$up" cursor-up
	local got
	got="$(tmux -L "$sock" display -p -t "$id" '#{copy_cursor_line}')"
	tmux -L "$sock" send-keys -X -t "$id" cancel
	if [ "$got" != "$needle" ]; then
		echo "FAIL: $needle (up=$up) -> cursor on [$got]" >&2
		exit 1
	fi
	echo "ok: $needle (up=$up)"
}

assert_jump marker-line-42
assert_jump marker-line-119
assert_jump needle-near-top
echo "PASS"
