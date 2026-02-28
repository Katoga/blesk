FROM node:24-trixie-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes \
  && apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    wget

WORKDIR /opt/explorer

ENV NODE_ENV=production

ARG BLESK_EXPLORER_VERSION
ARG BLESK_EXPLORER_CHECKSUM
RUN tarball="v${BLESK_EXPLORER_VERSION}+SW.tar.gz" \
  && wget -q "https://github.com/Dojo-Open-Source-Project/btc-rpc-explorer/archive/refs/tags/${tarball}" \
  && echo "${BLESK_EXPLORER_CHECKSUM}  ${tarball}" \
    | sha512sum -cw - \
  && tar -xvz \
    -f "$tarball" \
    --strip-components 1 \
  && rm -f "$tarball" \
  && npm install --no-audit --no-fund --no-update-notifier

RUN sed -i 's~#!/usr/bin/env node~#!/nodejs/bin/node~' ./bin/cli.js \
  && sed -i 's~#!/usr/bin/env node~#!/nodejs/bin/node~' ./bin/www \
  && sed -E 's~^#?(BTCEXP_BITCOIND_HOST)=.+$~\1=bitcoincore~' .env-sample \
    | sed -E 's~^#?(BTCEXP_ADDRESS_API)=.+$~\1=electrum~' \
    | sed -E 's~^#?(BTCEXP_PRIVACY_MODE|BTCEXP_NO_RATES)=.+$~\1=true~' \
    > .env \
  && rm -rf \
    ./.git* \
    ./Dockerfile \
    ./LICENSE \
    ./README.md \
    ./TODO.md \
    ./docker-compose.yml \
    ./npm-shrinkwrap.json \
    ./pnpm* \
    ./roadmap.md

FROM gcr.io/distroless/nodejs24-debian13:nonroot AS runner

ENV DEBIAN_FRONTEND=noninteractive

ENV NODE_ENV=production

ARG BLESK_DIR_HOME

COPY --from=builder --chown=nonroot:nonroot /opt/explorer/ "${BLESK_DIR_HOME}/explorer/"

COPY --from=builder /opt/explorer/.env /etc/btc-rpc-explorer/.env

ENTRYPOINT [ "./explorer/bin/cli.js" ]
