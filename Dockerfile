FROM debian:bullseye-slim AS build
LABEL name="Cardano Node"
LABEL description="A cardano node image purpose built for Raspberry Pi 4b"
LABEL maintainer="Pilina <team@pilina.com>"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get full-upgrade -y \
    && apt-get install -y automake build-essential pkg-config libffi-dev \
      libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make \
      g++ git wget libncursesw5 libtool autoconf libnuma-dev cabal-install ghc

# Update Cabal to 3.4.0.0
RUN cabal --version \
    && cabal update \
    && cabal install cabal-install \
    && cabal --version

# Get a special version of libsodium
RUN git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium && git checkout 66f017f1 \
    && ./autogen.sh && ./configure --prefix=/opt/libsodium \
    && make -j5 && make -j5 install \
    && cd .. && rm -rf libsodium
ENV LD_LIBRARY_PATH="/opt/libsodium/lib:${LD_LIBRARY_PATH}" \
    PKG_CONFIG_PATH="/opt/libsodium/lib/pkgconfig:${PKG_CONFIG_PATH}"

# Build cardano node
ARG VERSION=1.26.1
RUN git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git fetch --all --recurse-submodules --tags \
    && git checkout tags/${VERSION} \
    && cabal update \
    && cabal configure --with-compiler=ghc-8.8.2 \
    && echo "jobs: 4" >>  cabal.project.local \
    && echo "package cardano-crypto-praos" >>  cabal.project.local \
    && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local \
    && cabal build all \
    && cabal install cardano-cli cardano-node \
    && mkdir -p /opt/cardano/bin \
    && mv $(readlink -f ~/.cabal/bin/cardano-cli) /opt/cardano/bin \
    && mv $(readlink -f ~/.cabal/bin/cardano-node) /opt/cardano/bin

FROM debian:bullseye-slim
RUN apt-get update -y && apt-get full-upgrade -y \
    && apt-get install -y libnuma1 netbase

COPY --from=build /opt/libsodium /opt/cardano
COPY --from=build /opt/cardano/bin /opt/cardano/bin

RUN useradd -ms /bin/bash lovelace
USER lovelace

ENV PATH="/opt/cardano/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/cardano/lib:${LD_LIBRARY_PATH}"

COPY ./entrypoint.sh ~/entrypoint.sh
ENTRYPOINT ["~/entrypoint.sh"]
