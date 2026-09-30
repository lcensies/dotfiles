#!/usr/bin/env bash
# Checks tmux_log_open's path harvesting: real unified-exec output shape,
# newest-first order, dedup, relative paths against the pane cwd, and that
# vanished paths / bare words are dropped without a nonzero exit (tmux would
# print "... returned 1" over the pane).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/src"
: >"$tmp/a.log"
: >"$tmp/b.log"
: >"$tmp/src/index.ts"

check() { # check <label> <expected> <actual>
	if [ "$2" = "$3" ]; then
		printf 'ok   %s\n' "$1"
	else
		printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3" >&2
		exit 1
	fi
}

check "logs: newest first, deduped, missing dropped" \
	"$(printf '%s\n%s' "$tmp/b.log" "$tmp/a.log")" \
	"$(printf '%s\n' \
		"log_path: $tmp/a.log" \
		"took 4.2s · exit_code=0 · log: $tmp/a.log" \
		"log_path: $tmp/gone.log" \
		"log_path: $tmp/b.log" |
		"$here/tmux_log_open" --extract "$tmp")"

check "relative path resolved against pane cwd, bare words ignored" \
	"$tmp/src/index.ts" \
	"$(printf '%s\n' "read src/index.ts and also nothing_here" |
		"$here/tmux_log_open" --extract "$tmp")"

# Ranking: unified-exec log first even when it is the oldest thing on screen,
# then other logs, then plain files; newest-first inside each tier.
: >"$tmp/pi-unified-exec-7-deadbeef.log"
check "unified-exec log outranks newer logs and files" \
	"$(printf '%s\n%s\n%s\n%s' "$tmp/pi-unified-exec-7-deadbeef.log" "$tmp/b.log" "$tmp/a.log" "$tmp/src/index.ts")" \
	"$(printf '%s\n' \
		"log: $tmp/pi-unified-exec-7-deadbeef.log" \
		"edited src/index.ts" \
		"see $tmp/a.log" \
		"see $tmp/b.log" |
		"$here/tmux_log_open" --extract "$tmp")"

for label in "no match at all" "only vanished paths"; do
	case $label in
	"no match at all") input="nothing to see here" ;;
	*) input="log_path: $tmp/gone.log" ;;
	esac
	if out=$(printf '%s\n' "$input" | "$here/tmux_log_open" --extract "$tmp") && [ -z "$out" ]; then
		echo "ok   $label: empty, exit 0"
	else
		printf 'FAIL %s (exit %s, out %q)\n' "$label" "$?" "$out" >&2
		exit 1
	fi
done
