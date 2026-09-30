#!/usr/bin/env bash
# Checks the two halves of agent restore: that tmux-resurrect matches the
# commands panes are really recorded with (see @resurrect-processes in
# ../tmux.conf), and that tmux_resurrect_run relaunches pi with the right
# runner for the pane's cwd.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
conf="$here/../tmux.conf"
resurrect="${RESURRECT_DIR:-$HOME/.tmux/plugins/tmux-resurrect}"

fail=0
check() { # check <label> <expected> <actual>
	if [ "$2" = "$3" ]; then
		printf 'ok   %s\n' "$1"
	else
		printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3"
		fail=1
	fi
}

# --- half 1: resurrect's matching against the real option value -------------

conf_processes="$(sed -n "s/^set -g @resurrect-processes '\(.*\)'$/\1/p" "$conf")"
[ -n "$conf_processes" ] || {
	echo "no @resurrect-processes in $conf" >&2
	exit 1
}

# shellcheck source=/dev/null
source "$resurrect/scripts/variables.sh"
# shellcheck source=/dev/null
source "$resurrect/scripts/helpers.sh"
# shellcheck source=/dev/null
source "$resurrect/scripts/process_restore_helpers.sh"

# The helpers read options from a live tmux server; feed them the conf value
# and let every other option fall back to the default the caller passed.
get_tmux_option() {
	if [ "$1" = "$restore_processes_option" ]; then
		echo "$conf_processes"
	else
		echo "${2-}"
	fi
}

restore_command() { # restore_command <recorded ps line>
	local recorded="$1" proc match
	eval set $(_restore_list)
	for proc in "$@"; do
		match="$(_get_proc_match_element "$proc")"
		if _proc_matches_full_command "$recorded" "$match"; then
			_get_proc_restore_command "$recorded" "$proc" "$match"
			return 0
		fi
	done
	echo "<no match>"
}

store_pi=/nix/store/ai9szyf9fivph9rdk65gzjiy30sll754-pi-0.87.1/libexec/pi/pi

check "plain pi / cpi pane" \
	"tmux_resurrect_run pi " "$(restore_command "$store_pi")"
check "pi pane with args" \
	"tmux_resurrect_run pi --model opus" "$(restore_command "$store_pi --model opus")"
check "redacted pi pane" \
	"llm-redactor-exec -- tmux_resurrect_run pi " "$(restore_command "llm-redactor-exec -- pi")"

# --- half 2: the runner tmux_resurrect_run picks ----------------------------

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home/repos/work/proj" "$tmp/home/repos/other"
for stub in pi workmux; do
	printf '#!/usr/bin/env bash\necho "%s $*"\n' "$stub" >"$tmp/bin/$stub"
	chmod +x "$tmp/bin/$stub"
done

run_in() { # run_in <cwd> [args...]
	local dir="$1"
	shift
	(cd "$dir" && PATH="$tmp/bin:$PATH" HOME="$tmp/home" "$here/tmux_resurrect_run" pi "$@")
}

check "work repo -> corp profile" \
	"workmux --profile corp exec pi --continue" "$(run_in "$tmp/home/repos/work/proj")"
check "other repo -> plain pi" \
	"pi --continue" "$(run_in "$tmp/home/repos/other")"
check "explicit session flag is replayed untouched" \
	"pi --resume abc" "$(run_in "$tmp/home/repos/other" --resume abc)"

exit "$fail"
