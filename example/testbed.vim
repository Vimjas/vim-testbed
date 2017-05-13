" vint: -ProhibitSetNoCompatible

let s:this_dir = expand('<sfile>:h')
exe 'set runtimepath+='.s:this_dir.'/test/plugins/vader.vim'

filetype plugin indent on
syntax on
set nocompatible
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set backspace=2
set nofoldenable
set foldmethod=syntax
set foldlevelstart=10
set foldnestmax=10
set ttimeoutlen=0
