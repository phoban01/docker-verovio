FROM debian:buster-slim AS compile

ARG VEROVIO_VERSION

ENV VEROVIO_VERSION=${VEROVIO_VERSION:-3.4.1}

RUN apt update && apt upgrade -yy && \
    apt install -y curl build-essential cmake && \
    curl -sLO https://github.com/rism-digital/verovio/archive/refs/tags/version-$VEROVIO_VERSION.tar.gz && \
    tar -xf version-$VEROVIO_VERSION.tar.gz && cd verovio-version-$VEROVIO_VERSION/tools && \
    cmake ../cmake && \
    make && make install/strip

FROM gcr.io/distroless/cc-debian10:latest

ARG VEROVIO_VERSION
ARG OWNER
ARG BUILD_SHA
ARG SRC_REPO

ENV VEROVIO_VERSION=${VEROVIO_VERSION:-3.4.1}

LABEL maintainer=$OWNER
LABEL build_sha=$BUILD_DATE
LABEL manifest=$SRC_REPO
LABEL version=$VEROVIO_VERSION

COPY --from=compile /usr/local/bin/verovio /usr/local/bin/verovio
COPY --from=compile /usr/local/share/verovio /usr/local/share/verovio

ENTRYPOINT ["verovio"]
