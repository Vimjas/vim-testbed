FROM testbed/vim

# Custom build dependencies are not cleaned by "install_vim".
RUN apk add make

RUN install_vim -tag v7.1 -name vim71 -prebuild_script 'echo "#define FEAT_PROFILE" >> src/feature.h' -build \
                -tag v7.3.429 -name vim73 -py -build \
                -tag v7.4.052 -name vim74-trusty -py3 -build \
                -tag master -py2 -py3 -ruby -lua -build \
                -tag neovim:v0.6.1 -py2 -py3 -ruby -build \
                -tag neovim:master -py2 -py3 -ruby -build

# make is installed still.
RUN command -v make
# gcc was pruned.
RUN if command -v gcc; then false; fi
