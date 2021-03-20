ARG VERSION=1.26.0
FROM pilina/cardano-node-build:${VERSION}
LABEL name="Cardano Node"
LABEL description="An opinionated cardano node management image for Raspberry Pi 4b"
LABEL maintainer="Pilina <team@pilina.com>"

# this is going to be obsolete with the new build image
RUN cp -pr /opt/libsodium /opt/cardano && mkdir /opt/cardano/bin \
    && cd /root/.cabal \
    && mv $(readlink -f ~/.cabal/bin/cardano-cli) /opt/cardano/bin \
    && mv $(readlink -f ~/.cabal/bin/cardano-node) /opt/cardano/bin

RUN useradd -ms /bin/bash pilina
USER pilina
ENV PATH="/opt/cardano/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/cardano/lib:${LD_LIBRARY_PATH}"

COPY ./entrypoint.sh ~/entrypoint.sh
ENTRYPOINT ["~/entrypoint.sh"]

