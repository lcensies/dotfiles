# https://github.com/esm7/obsidian-vimrc-support
set clipboard=unnamed

nmap H ^
nmap L $

exmap back obcommand app:go-back
nmap <C-o> :back
exmap forward obcommand app:go-forward
nmap <C-i> :forward
