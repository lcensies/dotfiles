#!/usr/bin/env bash
# Setup GNOME input sources for language switching
# This script configures US English and Russian keyboard layouts with Alt+Shift toggle

gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:alt_shift_toggle']"
gsettings set org.gnome.desktop.input-sources show-all-sources true
