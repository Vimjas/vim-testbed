set rtp=/home/vimtest/vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,/home/vimtest/vim/after
execute 'set rtp+='.join(filter(split(expand('/home/vimtest/plugins/*')), 'isdirectory(v:val)'), ',')
set rtp+=/testplugin
