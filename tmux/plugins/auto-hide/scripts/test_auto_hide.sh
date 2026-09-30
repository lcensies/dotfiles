#!/usr/bin/env bash
# Self-check for auto_hide.sh on a throwaway tmux server.
# Asserts: always exits 0, collapsed panes stop polluting scrollback, focus
# revives the pane it lands on.
set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T=(tmux -L ah_selfcheck)
fail=0
ck() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: got '$2' want '$3'"; fail=1; fi; }

"${T[@]}" kill-server 2>/dev/null; sleep 0.3
prod="$(mktemp)"; chmod +x "$prod"
cat >"$prod" <<'EOF'
#!/usr/bin/env bash
while :; do printf '\033[H'; for r in $(seq 1 40); do echo "frame line $r"; done; sleep 0.05; done
EOF

"${T[@]}" new-session -d -s t -x 200 -y 50 'sleep 300'
"${T[@]}" split-window -t t -h 'sleep 300'   # drawer column
"${T[@]}" split-window -t %1 -v "$prod"      # noisy TUI, stacked in that column
sleep 0.5

# Focus the quiet drawer pane -> %2 (the noisy one) must get collapsed+parked.
"${T[@]}" select-pane -t %1; "$DIR/auto_hide.sh"; ck "exit 0 on switch" "$?" "0"
sleep 0.3
ck "sibling collapsed" "$("${T[@]}" display -p -t %2 '#{pane_height}')" "1"
ck "sibling parked"    "$("${T[@]}" display -p -t %2 '#{alternate_on}')" "1"
ck "sibling frozen"    "$("${T[@]}" display -p -t %2 '#{pane_in_mode}')" "1"

h0=$("${T[@]}" display -p -t %2 '#{history_size}'); sleep 3
ck "no scrollback junk while parked" "$(( $("${T[@]}" display -p -t %2 '#{history_size}') - h0 ))" "0"

"$DIR/auto_hide.sh"; ck "exit 0 when already settled" "$?" "0"

# Focus the noisy pane -> unparked, live again.
"${T[@]}" select-pane -t %2; "$DIR/auto_hide.sh"; ck "exit 0 on refocus" "$?" "0"
sleep 0.3
ck "refocused unparked" "$("${T[@]}" display -p -t %2 '#{alternate_on}')" "0"
ck "refocused live"     "$("${T[@]}" display -p -t %2 '#{pane_in_mode}')" "0"
ck "refocused expanded" "$("${T[@]}" display -p -t %2 '#{?#{>:#{pane_height},1},yes,no}')" "yes"

"${T[@]}" kill-server 2>/dev/null; rm -f "$prod"
exit "$fail"
