FROM testbed/vim

RUN install_vim -tag v7.3.429 -name vim73 -py -build \
                -tag v7.4.052 -name vim74-trusty -build \
                -tag master -py2 -py3 -ruby -lua -build \
                -tag neovim:v0.2.0 -py2 -py3 -ruby -build \
                -tag neovim:master -py2 -py3 -ruby -build
