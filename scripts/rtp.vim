set rtp=/home/vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,/home/vim/after
execute 'set rtp+='.join(filter(split(expand('/home/plugins/*')), 'isdirectory(v:val)'), ',')
set rtp+=/testplugin
