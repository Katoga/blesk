FROM alpine:3 AS builder-bitcoincore

ARG BLESK_BITCOINCORE_VERSION

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    boost-dev \
    build-base \
    curl \
    cmake \
    gnupg \
    jq \
    libevent-dev \
    sqlite-dev \
    tar \
    zeromq-dev

SHELL [ "/bin/bash", "-o", "pipefail", "-euc" ]

WORKDIR /opt/bitcoincore

ENV NO_QT=1
ENV CMAKE_BUILD_TYPE=Release

RUN tarball="bitcoin-${BLESK_BITCOINCORE_VERSION}.tar.gz" \
  && wget -q "https://bitcoincore.org/bin/bitcoin-core-${BLESK_BITCOINCORE_VERSION}/${tarball}" \
  && wget -q "https://bitcoincore.org/bin/bitcoin-core-${BLESK_BITCOINCORE_VERSION}/SHA256SUMS" \
  && wget -q "https://bitcoincore.org/bin/bitcoin-core-${BLESK_BITCOINCORE_VERSION}/SHA256SUMS.asc" \
  && wget -q -O - https://api.github.com/repositories/355107265/contents/builder-keys \
  | jq -r '.[].download_url' \
  | while read -r url; do \
    wget -q -O - "$url" \
    | gpg --import; \
  done \
  && gpg --verify SHA256SUMS.asc \
  && grep "$tarball" "SHA256SUMS" \
    | sha256sum -cs - \
  && tar -xvz \
    --strip-components 1 \
    -f "$tarball" \
  && rm -f \
    "$tarball" \
    SHA256SUMS \
    SHA256SUMS.asc \
  && cmake \
    -B build \
    -LH \
  && cmake \
    -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-g0" \
    -DWITH_ZMQ=ON \
  && cmake \
    --build build \
    -j "$(nproc)" \
  && ctest \
    --test-dir build \
    -j "$(nproc)" \
  && cmake \
    --install build


FROM golang:1.25-alpine AS builder-rpcauth

RUN apk --no-cache upgrade

WORKDIR /opt/rpcauth

COPY rpcauth.go ./

RUN go build -o ./ -tags 'netgo' ./rpcauth.go


FROM alpine:3 AS runner

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    boost \
    gettext-envsubst \
    jq \
    libevent \
    zeromq

ARG BLESK_BITCOINCORE_USERNAME
ARG BLESK_BITCOINCORE_UID
ARG BLESK_BITCOINCORE_GID
ARG BLESK_BITCOINCORE_HOME
ARG BLESK_TOR_USERNAME
ARG BLESK_TOR_GID

RUN addgroup -S \
    -g "$BLESK_BITCOINCORE_GID" \
    "$BLESK_BITCOINCORE_USERNAME" \
  && addgroup -S \
    -g "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && adduser -S \
    -h "$BLESK_BITCOINCORE_HOME" \
    -u "$BLESK_BITCOINCORE_UID" \
    -G "$BLESK_BITCOINCORE_USERNAME" \
    "$BLESK_BITCOINCORE_USERNAME" \
  && addgroup "$BLESK_BITCOINCORE_USERNAME" "$BLESK_TOR_USERNAME" \
  && mkdir "${BLESK_BITCOINCORE_HOME}/.bitcoin" \
  && chown -h "${BLESK_BITCOINCORE_USERNAME}:${BLESK_BITCOINCORE_USERNAME}" "${BLESK_BITCOINCORE_HOME}/.bitcoin"

USER "$BLESK_BITCOINCORE_USERNAME"

WORKDIR "$BLESK_BITCOINCORE_HOME"

COPY --from=builder-bitcoincore /usr/local/bin/bitcoin* /usr/local/bin/
COPY --from=builder-rpcauth /opt/rpcauth/rpcauth /usr/local/bin/
COPY --chown="${BLESK_BITCOINCORE_UID}:${BLESK_BITCOINCORE_GID}" bitcoin.conf.template "./"

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
