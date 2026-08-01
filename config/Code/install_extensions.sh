#!/usr/bin/env bash
#
# SUPERSEDED on NixOS: extensions are now declared in
# nixos/home-manager/config/vscode.nix (programs.vscode.profiles.default.extensions)
# and installed by `make switch`. Kept for non-Nix machines.
# settings.json / keybindings.json in ./User/ are still rcm-managed — edit them here.

cat vscode-extensions.txt | while read extension || [[ -n $extension ]];
do
  echo installing $extension
  code --install-extension $extension --force
done
