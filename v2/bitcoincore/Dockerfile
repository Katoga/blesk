FROM debian:trixie-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "-o", "pipefail", "-euc" ]

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes --no-install-recommends \
  && apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    gnupg \
    jq \
    wget

WORKDIR /opt/bitcoincore

ARG BLESK_BITCOINCORE_VERSION

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

FROM gcr.io/distroless/cc-debian13:nonroot AS runner

# Prevent excessive memory usage
ENV MALLOC_ARENA_MAX=1

COPY --from=builder /opt/bitcoincore/bin/bitcoin-cli /opt/bitcoincore/bin/bitcoind /usr/local/bin/
COPY --from=builder /opt/bitcoincore/bitcoin.conf /etc/bitcoincore/

ENTRYPOINT [ "/usr/local/bin/bitcoind" ]
