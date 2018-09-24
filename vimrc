"""""""""""""""""""""""""""""""""""""
" __      _______ __  __            "
" \ \    / /_   _|  \/  |           "
"  \ \  / /  | | | \  / |_ __ ___   "
"   \ \/ /   | | | |\/| | '__/ __|  "
"    \  /   _| |_| |  | | | | (__   "
"     \/   |_____|_|  |_|_|  \___|  "
"                                   "
"""""""""""""""""""""""""""""""""""""
" Install powerline fonts and configure your 
" terminal emulator to use them.
" -> https://github.com/powerline/fonts "
" -> Arch linux AUR: powerline-fonts-git
"

set nocompatible
filetype off

""""""""""""""""""""""""""""""""""""""
"  Vundle (vim plugin manager) stuff "
""""""""""""""""""""""""""""""""""""""
set rtp+=~/.vim/bundle/Vundle.vim

" Automatically setting up vundle "
let has_vundle=1
if !filereadable($HOME."/.vim/bundle/Vundle.vim/README.md")
    echo "Installing Vundle..."
    echo ""
    silent !mkdir -p $HOME/.vim/bundle
    silent !git clone https://github.com/gmarik/Vundle.vim $HOME/.vim/bundle/Vundle.vim
    let has_vundle=0
endif

" Start Vundle stuff "
call vundle#begin()
    Plugin 'VundleVim/Vundle.vim'
    
    " A pretty statusline, bufferline integration "
    Plugin 'itchyny/lightline.vim'
    Plugin 'bling/vim-bufferline'
    
    " <Tab> everything! "
    "Plugin 'ervandew/supertab'
    
    " Glorious colorscheme "
    Plugin 'nanotech/jellybeans.vim'
    
    " Super easy commenting, toggle comments etc "
    "Plugin 'scrooloose/nerdcommenter'
    
    " Autoclose
    "Plugin 'Townk/vim-autoclose'
    
    " Git wrapper inside Vim "
    "Plugin 'tpope/vim-fugitive'
    
    "Handle surround chars like "
    "Plugin 'tpope/vim-surround'
    
    " Vim signs (:h signs) for modified lines based off VCS (e.g. Git) "
    "Plugin 'mhinz/vim-signify'
" Finish Vundle stuff "
call vundle#end()

" Installing plugins the first time, quits when done "
if has_vundle == 0
    :silent! PluginInstall
    :qa
endif

filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""
"  Lightline (statusline) configuration "
"""""""""""""""""""""""""""""""""""""""""
"let g:lightline = {
"      \ 'colorscheme': 'default',
"      \ 'component': {
"      \   'readonly': '%{&readonly?"":""}',
"      \ },
"      \ 'separator': { 'left': '', 'right': ''  },
"      \ 'subseparator': { 'left': '', 'right': ''  }
"      \ }
"
"""""""""""""""""""""""""""""""""""""""""
"          Misc configurations          "
"""""""""""""""""""""""""""""""""""""""""

" Autointend and autoscroll 4 lines above the cursor "
set cindent
set scrolloff=4

"T abstop, Shiftwith and replace tabs with spaces but not in makefiles "
set tabstop=4
set shiftwidth=4
set expandtab

" Autocommands for special files "
autocmd FileType make set noexpandtab
autocmd BufNewFile,BufRead *.md set ft=markdown tw=79
autocmd BufNewFile,BufRead *.tex set ft=tex tw=79
autocmd BufNewFile,BufRead *.txt set ft=sh tw=79

" Stuff needed by urxvt "
set nocompatible
set mouse=a
set backspace=2

" Syntaxhighlighting, colorscheme, linenumbers "
syntax on
colorscheme jellybeans  " Colorscheme from plugin 
set cursorline
set more                " Use more 
set title               " Blank title
set vb t_vb=            " No beeping and flashing "
set wildmenu
set background=dark
set number              " Linenumbers
set list                
set nowrap
set hlsearch
set t_Co=256
set laststatus=2        " Always display the statusline in all windows
set showtabline=2       " Always display the tabline, even if there is only one tab
set noshowmode          " Hide the default mode text (e.g. -- INSERT -- below the statusline)

"Automaticly reread a file, if file has changed"
set autoread
