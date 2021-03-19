FROM debian:bullseye-slim AS dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get full-upgrade -y \
    && apt-get install -y \
        wget \
        git \
        xz-utils \
        make \
        gcc \
        libtool \
        libtinfo5 \
        llvm-9-dev \
        libnuma-dev \
        zlib1g-dev \
        pkg-config \
        libsystemd-dev
ENV PATH="/usr/lib/llvm-9/bin:${PATH}"

RUN wget https://downloads.haskell.org/ghc/8.8.2/ghc-8.8.2-aarch64-deb9-linux.tar.xz \
    && tar -xvf ghc-8.8.2-aarch64-deb9-linux.tar.xz \
    && rm ghc-8.8.2-aarch64-deb9-linux.tar.xz \
    && cd ghc-8.8.2/ \
    && ./configure --prefix=/opt/ghc \
    && make -j5 install \
    && cd .. && rm -rf ghc-8.8.2
ENV PATH="/opt/ghc/bin:${PATH}"

RUN git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium && git checkout 66f017f1 \
    && ./autogen.sh && ./configure --prefix=/opt/libsodium \
    && make -j5 && make -j5 install \
    && cd .. && rm -rf libsodium
ENV LD_LIBRARY_PATH="/opt/libsodium/lib:${LD_LIBRARY_PATH}" \
    PKG_CONFIG_PATH="/opt/libsodium/lib/pkgconfig:${PKG_CONFIG_PATH}"

ARG VERSION=1.25.1
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-aarch64-ubuntu-18.04.tar.xz \
    && tar -xvf cabal-install-3.4.0.0-aarch64-ubuntu-18.04.tar.xz \
    && rm cabal-install-3.4.0.0-aarch64-ubuntu-18.04.tar.xz \
    && mv cabal /usr/local/bin \
    && cabal update \
    && cabal --version \
    && git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git fetch --all --recurse-submodules --tags \
    && git checkout tags/${VERSION} \
    && cabal configure --with-compiler=ghc-8.8.2 \
    && echo "jobs: 4" >>  cabal.project.local \
    && echo "package cardano-crypto-praos" >>  cabal.project.local \
    && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local \
    && cabal build all \
    && cabal install --installdir /opt/cardano cardano-cli cardano-node \
    && cd .. && rm -rf cardano-node
ENV PATH="/opt/cardano:${PATH}"

