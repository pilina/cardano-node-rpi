FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

# Install build dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y \
    && apt-get install -y apt-utils git wget pkg-config libgmp-dev libssl-dev \
      libtinfo-dev libsystemd-dev zlib1g-dev llvm-9 automake make libtool \
      build-essential libffi-dev libncursesw5 g++ jq haskell-platform autoconf

# install ghc
ARG GHC_VERSION=8.6.5
RUN git clone https://github.com/input-output-hk/ghc.git \
    && cd ghc \
    && git checkout release/${GHC_VERSION}-iohk \
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
    && cd .. && rm -rf ghc \
    && ln -sf /usr/local/bin/ghc /usr/bin/ghc

# install cabal
ARG CABAL_VERSION=3.4.0.0
ENV PATH="/root/.cabal/bin:/root/.ghcup/bin:/root/.local/bin:$PATH"
RUN git clone https://github.com/haskell/cabal.git \
    && cd cabal \
    && git checkout cabal-install-v${CABAL_VERSION} \
    && ./bootstrap.sh \
    && cd .. && rm -rf cabal

# install libsodium
ARG LIBSODIUM_COMMIT=66f017f1
RUN git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium \
    && git checkout ${LIBSODIUM_COMMIT} \
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

# install cardano-node
ARG NODE_VERSION=1.25.1
RUN git clone https://github.com/input-output-hk/cardano-node \
    && cd cardano-node \
    && git checkout tags/${NODE_VERSION} \
    && echo "jobs: 4" >>  cabal.project.local \
    && echo "package cardano-crypto-praos" >>  cabal.project.local \
    && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local \
    && cabal update \
    && cabal user-config update \
    && cabal build all \
    && mkdir -p /root/.local/bin/ \
    && cp -p dist-newstyle/build/aarch64-linux/ghc-8.6.5/cardano-node-${NODE_VERSION}/x/cardano-node/build/cardano-node/cardano-node /root/.local/bin \
    && cp -p dist-newstyle/build/aarch64-linux/ghc-8.6.5/cardano-cli-${NODE_VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli /root/.local/bin \
    && echo "Done! Time to clean up ..."

#     && git checkout tags/$VERSION \
#     && cabal configure --with-compiler=ghc-8.10.4 \
#     && echo "package cardano-crypto-praos" >>  cabal.project.local \
#     && echo "  flags: -external-libsodium-vrf" >>  cabal.project.local \
#     && cabal build all \
#     && mkdir -p /root/.local/bin/ \
#     && cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.4/cardano-node-${VERSION}/x/cardano-node/build/cardano-node/cardano-node /root/.local/bin/ \
#     && cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.4/cardano-cli-${VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli /root/.local/bin/ \
#     && rm -rf /root/.cabal/packages \
#     && rm -rf /usr/local/lib/ghc-8.10.4/ \
#     && rm -rf /cardano-node/dist-newstyle/ \
#     && rm -rf /root/.cabal/store/ghc-8.10.4
