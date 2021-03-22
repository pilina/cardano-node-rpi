FROM pilina/cabal-base:3.4.0.0 AS build
LABEL name="Cardano RTView Build"
LABEL description="A cardano rtview image purpose built for Raspberry Pi 4b"
LABEL maintainer="Pilina <team@pilina.com>"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y \
      libstdc++-10-dev \
      g++

ARG VERSION=0.3.0
RUN git clone https://github.com/input-output-hk/cardano-rt-view.git \
    && cd cardano-rt-view \
    && git fetch --all --recurse-submodules --tags \
    && git checkout tags/${VERSION} \
    && cabal configure --with-compiler=ghc-8.8.2 \
    && cabal build all \
    && cabal install cardano-rt-view


