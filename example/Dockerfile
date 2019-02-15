FROM testbed/vim

# v7.0001: oldest tag: 7.0aa ALPHA (2004 June 7)
RUN install_vim -tag v7.0001 -name vim70aa -build \
                -tag v7.1 -name vim71 -prebuild_script 'echo "#define FEAT_PROFILE" >> src/feature.h' -build \
                -tag v7.3.429 -name vim73 -py -build \
                -tag v7.4.052 -name vim74-trusty -build \
                -tag master -py2 -py3 -ruby -lua -build \
                -tag neovim:v0.2.0 -py2 -py3 -ruby -build \
                -tag neovim:master -py2 -py3 -ruby -build
