FROM alpine:3.5

RUN adduser -h /home -s /bin/sh -D -u 8465 vimtest

RUN mkdir -p /vim /vim-build/bin /plugins
RUN chown vimtest:vimtest /home /plugins

ADD scripts/argecho.sh /vim-build/bin/argecho
ADD scripts/install_vim.sh /sbin/install_vim
ADD scripts/run_vim.sh /sbin/run_vim

RUN chmod +x /vim-build/bin/argecho /sbin/install_vim /sbin/run_vim

ADD scripts/rtp.vim /rtp.vim

# The user directory for setup
VOLUME /home

# Your plugin
VOLUME /testplugin

ENTRYPOINT ["/sbin/run_vim"]
