FROM alpine:3.8

RUN apk --no-cache upgrade

RUN adduser -h /home/vimtest -s /bin/sh -D -u 8465 vimtest

RUN mkdir -p /vim /vim-build/bin

# Useful during tests to have these packages in a deeper layer cached already.
# RUN apk --no-cache add --virtual vim-build build-base

ADD scripts/argecho.sh /vim-build/bin/argecho
ADD scripts/install_vim.sh /sbin/install_vim
ADD scripts/run_vim.sh /sbin/run_vim

RUN mkdir /home/vimtest/.vim /home/vimtest/.config
ADD scripts/init.vim /home/vimtest/.vim/
RUN ln -s ../.vim /home/vimtest/.config/nvim
RUN ln -s .vim/init.vim /home/vimtest/.vimrc

RUN chmod +x /vim-build/bin/argecho /sbin/install_vim /sbin/run_vim

# The user directory for setup
VOLUME /home/vimtest

# Your plugin
VOLUME /testbed

ENTRYPOINT ["/sbin/run_vim"]
