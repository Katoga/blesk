FROM debian:trixie-slim AS builder

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
    -f "$tarball" \
  # explicitly enable config options
  && sed -Ei 's~^#?(disablewallet|listen|server|txindex)=.+$~\1=1~' ./bitcoin.conf \
  # explicitly disable config options
  && sed -Ei 's~^#?(discover|dns(seed)?|natpmp)=.+$~\1=0~' ./bitcoin.conf \
  # complex settings
  && sed -Ei 's~^#?(onlynet)=.+$~\1=onion~' ./bitcoin.conf

# empty dir needed for seting permission on data dir in runner
RUN mkdir /empty

FROM gcr.io/distroless/cc-debian13:nonroot AS runner

# Prevent excessive memory usage
ENV MALLOC_ARENA_MAX=1

# just to set owner of the dir where volume is mounted
ARG BLESK_BITCOINCORE_COOKIE_DIR
COPY --from=builder --chown=nonroot:nonroot /empty/ ${BLESK_BITCOINCORE_COOKIE_DIR}
COPY --from=builder --chown=nonroot:nonroot /empty/ /home/nonroot/.bitcoin/

COPY --from=builder /opt/bitcoincore/bin/bitcoin-cli /opt/bitcoincore/bin/bitcoind /usr/local/bin/
COPY --from=builder /opt/bitcoincore/bitcoin.conf /home/nonroot/

ENTRYPOINT [ "/usr/local/bin/bitcoind" ]

ARG BLESK_BITCOINCORE_PORT_RPC
ARG BLESK_BITCOINCORE_PORT_P2P
ARG BLESK_BITCOINCORE_PORT_ZMQ_BLOCK
ARG BLESK_BITCOINCORE_PORT_ZMQ_TX

EXPOSE ${BLESK_BITCOINCORE_PORT_RPC}
EXPOSE ${BLESK_BITCOINCORE_PORT_P2P}
EXPOSE ${BLESK_BITCOINCORE_PORT_ZMQ_BLOCK}
EXPOSE ${BLESK_BITCOINCORE_PORT_ZMQ_TX}
