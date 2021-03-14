FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

# Install build dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y apt-utils git wget pkg-config libgmp-dev libssl-dev \
      libtinfo-dev libsystemd-dev zlib1g-dev llvm-9 automake make libtool \
      build-essential libffi-dev libncursesw5 g++ jq tmux haskell-platform \
      autoconf \
    && apt-get clean

# install ghc
ARG GHC_VERSION=8.6.5
RUN git clone https://github.com/input-output-hk/ghc.git \
    && cd ghc \
    && git checkout release/$GHC_VERSION-iohk \
    && git config --global url."git://github.com/ghc/packages-".insteadOf     git://github.com/ghc/packages/ \
    && git config --global url."http://github.com/ghc/packages-".insteadOf    http://github.com/ghc/packages/ \
    && git config --global url."https://github.com/ghc/packages-".insteadOf   https://github.com/ghc/packages/ \
    && git config --global url."ssh://git\@github.com/ghc/packages-".insteadOf ssh://git\@github.com/ghc/packages/ \
    && git config --global url."git\@github.com:/ghc/packages-".insteadOf      git\@github.com:/ghc/packages/ \
    && git submodule update --init \
    && ./boot \
    && ./configure \
    && make -j3 \
    && make install \
    && cd .. \
    && rm -rf ghc \
    && ln -sf /usr/local/bin/ghc /usr/bin/ghc

# install cabal
ARG CABAL_VERSION=3.4.0.0
ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:$PATH"
RUN git clone https://github.com/haskell/cabal.git \
    && cd cabal \
    && git checkout cabal-install-v$CABAL_VERSION \
    && ./bootstrap.sh \
    && cd .. && rm -rf cabal

# install libsodium
ARG LIBSODIUM_COMMIT=66f017f1
RUN git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium \
    && git checkout $LIBSODIUM_COMMIT \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd .. && rm -rf libsodium
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# cleanup stuff
RUN cabal clean \
    && apt-get autoremove -y \
    && apt-get clean \
    && apt-get autoclean


