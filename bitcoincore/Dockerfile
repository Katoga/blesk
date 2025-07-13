FROM debian:bookworm-slim AS builder-bitcoincore

ARG BLESK_BITCOINCORE_VERSION

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes --no-install-recommends \
  && apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    gnupg \
    jq \
    wget

SHELL [ "/bin/bash", "-o", "pipefail", "-euc" ]

WORKDIR /opt/bitcoincore

RUN arch="$(uname -m)" \
  && tarball="bitcoin-${BLESK_BITCOINCORE_VERSION}-${arch}-linux-gnu.tar.gz" \
  && wget -nv "https://bitcoincore.org/bin/bitcoin-core-${BLESK_BITCOINCORE_VERSION}/${tarball}" \
  && wget -nv "https://bitcoincore.org/bin/bitcoin-core-${BLESK_BITCOINCORE_VERSION}/SHA256SUMS" \
  && wget -nv "https://bitcoincore.org/bin/bitcoin-core-${BLESK_BITCOINCORE_VERSION}/SHA256SUMS.asc" \
  && sha256sum --ignore-missing --check SHA256SUMS \
  && wget -nv -O - https://api.github.com/repositories/355107265/contents/builder-keys \
  | jq -r '.[].download_url' \
  | while read -r url; do \
    wget -nv -O - "$url" \
    | gpg --import; \
  done \
  && gpg --verify SHA256SUMS.asc \
  && sha256sum --check --status --ignore-missing SHA256SUMS \
  && tar -xvz \
    --strip-components=1 \
    -f "$tarball"


FROM golang:1.24-alpine3.22 AS builder-rpcauth

RUN apk --no-cache upgrade

WORKDIR /opt/rpcauth

COPY rpcauth.go ./

RUN go build -o ./ -tags 'netgo' ./rpcauth.go


FROM debian:bookworm-slim AS runner

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes --no-install-recommends \
  && apt-get install --assume-yes --no-install-recommends \
    jq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG BLESK_BITCOINCORE_USERNAME
ARG BLESK_BITCOINCORE_UID
ARG BLESK_BITCOINCORE_GID
ARG BLESK_BITCOINCORE_HOME
ARG BLESK_TOR_USERNAME
ARG BLESK_TOR_GID

RUN groupadd --system \
    --key SYS_GID_MIN="$BLESK_BITCOINCORE_GID" \
    --key SYS_GID_MAX="$BLESK_BITCOINCORE_GID" \
    --gid "$BLESK_BITCOINCORE_GID" \
    "$BLESK_BITCOINCORE_USERNAME" \
  && groupadd --system \
    --key SYS_GID_MIN="$BLESK_TOR_GID" \
    --key SYS_GID_MAX="$BLESK_TOR_GID" \
    --gid "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && useradd --system --create-home \
    --home-dir "$BLESK_BITCOINCORE_HOME" \
    --key SYS_UID_MIN="$BLESK_BITCOINCORE_UID" \
    --key SYS_UID_MAX="$BLESK_BITCOINCORE_UID" \
    --uid "$BLESK_BITCOINCORE_UID" \
    --key SYS_GID_MIN="$BLESK_BITCOINCORE_GID" \
    --key SYS_GID_MAX="$BLESK_BITCOINCORE_GID" \
    --gid "$BLESK_BITCOINCORE_GID" \
    --groups "$BLESK_TOR_GID" \
    "$BLESK_BITCOINCORE_USERNAME" \
  && mkdir "${BLESK_BITCOINCORE_HOME}/.bitcoin" \
  && chown -h "${BLESK_BITCOINCORE_USERNAME}:${BLESK_BITCOINCORE_USERNAME}" "${BLESK_BITCOINCORE_HOME}/.bitcoin"

USER "$BLESK_BITCOINCORE_USERNAME"

WORKDIR "$BLESK_BITCOINCORE_HOME"

COPY --from=builder-bitcoincore /opt/bitcoincore/bin/* /usr/local/bin/
COPY --from=builder-rpcauth /opt/rpcauth/rpcauth /usr/local/bin/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
