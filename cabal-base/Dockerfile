FROM debian:bullseye-slim
LABEL name="Cabal Build Environment"
LABEL description="A cabal build environment image to form the base of Cardano images for Raspberry Pi 4b"
LABEL maintainer="Pilina <team@pilina.com>"

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get full-upgrade -y \
    && apt-get install -y \
      git \
      wget \
      xz-utils \
      make \
      gcc \
      libtool \
      libtinfo5 \
      llvm-9-dev \
      libnuma-dev \
      zlib1g-dev
ENV PATH="/usr/lib/llvm-9/bin:${PATH}"

RUN arch=`uname -m` \
    && wget -nv https://downloads.haskell.org/ghc/8.8.2/ghc-8.8.2-${arch}-deb9-linux.tar.xz \
    && tar -xf ghc-8.8.2-${arch}-deb9-linux.tar.xz \
    && rm ghc-8.8.2-${arch}-deb9-linux.tar.xz \
    && cd ghc-8.8.2/ \
    && ./configure --prefix=/opt/ghc \
    && make -j5 install \
    && cd .. && rm -rf ghc-8.8.2
ENV PATH="/opt/ghc/bin:${PATH}"

RUN case `uname -m` in \
      aarch64) filename="aarch64-ubuntu-18" ;; \
            *) filename="x86_64-ubuntu-16" ;; \
    esac \
    && wget -nv https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-${filename}.04.tar.xz \
    && tar -xvf cabal-install-3.4.0.0-${filename}.04.tar.xz \
    && rm cabal-install-3.4.0.0-${filename}.04.tar.xz \
    && mv cabal /usr/local/bin \
    && cabal update \
    && cabal --version

