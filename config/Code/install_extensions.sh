#!/usr/bin/env bash

cat vscode-extensions.txt | while read extension || [[ -n $extension ]];
do
  echo installing $extension
  code --install-extension $extension --force
done
