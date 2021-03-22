ARG VERSION=1.26.0
FROM pilina/cardano-node-build:${VERSION}
LABEL name="Cardano Node"
LABEL description="An opinionated cardano node management image for Raspberry Pi 4b"
LABEL maintainer="Pilina <team@pilina.com>"

RUN useradd -ms /bin/bash pilina
USER pilina
ENV PATH="/opt/cardano/bin:${PATH}" \
    LD_LIBRARY_PATH="/opt/cardano/lib:${LD_LIBRARY_PATH}"

COPY ./entrypoint.sh ~/entrypoint.sh
ENTRYPOINT ["~/entrypoint.sh"]

