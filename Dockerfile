FROM alpine:3.9

RUN apk --no-cache upgrade

RUN adduser -h /home/vimtest -s /bin/sh -D -u 8465 vimtest

RUN mkdir -p /vim /vim-build/bin /plugins
RUN chown vimtest:vimtest /home /plugins

# Useful during tests to have these packages in a deeper layer cached already.
# RUN apk --no-cache add --virtual vim-build build-base

ADD scripts/argecho.sh /vim-build/bin/argecho
ADD scripts/install_vim.sh /sbin/install_vim
ADD scripts/run_vim.sh /sbin/run_vim

RUN chmod +x /vim-build/bin/argecho /sbin/install_vim /sbin/run_vim

ADD scripts/rtp.vim /rtp.vim

# The user directory for setup
VOLUME /home/vimtest

# Your plugin
VOLUME /testplugin

ENTRYPOINT ["/sbin/run_vim"]
