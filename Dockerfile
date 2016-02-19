FROM debian:jessie

ENV PATH="/scripts:$PATH"
ENV DEBIAN_FRONTEND=noninteractive
ENV PYENV_ROOT=/pyenv

RUN adduser --home /home --shell /bin/bash --uid 8465 --gecos "" --disabled-password vimtest
RUN chown -R vimtest:vimtest /home

ADD rtp.vim /rtp.vim
ADD scripts /scripts
RUN chmod +x /scripts/*

# The user directory for setup
VOLUME /home

# Your plugin
VOLUME /testplugin

ENTRYPOINT ["/scripts/run_vim"]
