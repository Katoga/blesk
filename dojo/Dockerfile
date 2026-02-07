FROM node:24-trixie AS builder

ENV DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

# hadolint ignore=DL3018
RUN apt-get update \
  && apt-get upgrade --assume-yes

WORKDIR /opt/dojo

ENV NODE_ENV=production

COPY cookie.patch npmroot.patch ./

ARG BLESK_DOJO_VERSION

# hadolint ignore=DL3016
RUN wget -nv \
    -O "samourai-dojo-${BLESK_DOJO_VERSION}.tar.gz" \
    "https://github.com/Dojo-Open-Source-Project/samourai-dojo/archive/refs/tags/v${BLESK_DOJO_VERSION}.tar.gz" \
  && wget -nv "https://github.com/Dojo-Open-Source-Project/samourai-dojo/releases/download/v${BLESK_DOJO_VERSION}/samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt" \
  && wget -nv "https://github.com/Dojo-Open-Source-Project/samourai-dojo/releases/download/v${BLESK_DOJO_VERSION}/samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt.sig" \
  && wget -nv -O - https://keys.openpgp.org/vks/v1/by-fingerprint/E53AD419B242822F19E23C6D3033D463D6E544F6 \
    | gpg --import \
  && gpg --verify "samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt.sig" \
  && grep 'tar\.gz' "samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt" \
    | sha256sum -c - \
  && tar -xvz \
    --strip-components 1 \
    -f "samourai-dojo-${BLESK_DOJO_VERSION}.tar.gz" \
  && rm -f samourai-dojo-${BLESK_DOJO_VERSION}* \
  && patch -p1 < cookie.patch \
  && patch -p1 < npmroot.patch \
  && npm install --no-audit --no-fund --no-update-notifier \
  && mv ./static/admin/conf/index-mainnet.js ./static/admin/conf/index.js \
  && npm install --no-audit --no-fund --no-update-notifier \
    pm2 \
  && sed -Ei 's~#!/usr/bin/env node~#!/nodejs/bin/node~' ./node_modules/pm2/bin/pm2-runtime


FROM gcr.io/distroless/nodejs24-debian13:nonroot AS runner

ENV DEBIAN_FRONTEND=noninteractive

ENV NODE_ENV=production

COPY --from=builder /opt/dojo/keys/index-example.js /home/nonroot/dojo/

COPY --from=builder /opt/dojo/ /home/nonroot/dojo/
COPY pm2.config.cjs /home/nonroot/dojo/

COPY --from=builder /usr/bin/sh /usr/bin/getconf /bin/

COPY docker-entrypoint.mjs /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.mjs" ]

ARG BLESK_DOJO_PORT_API
ARG BLESK_DOJO_PORT_PUSHTX
ARG BLESK_DOJO_PORT_TRACKER

EXPOSE ${BLESK_DOJO_PORT_API}
EXPOSE ${BLESK_DOJO_PORT_PUSHTX}
EXPOSE ${BLESK_DOJO_PORT_TRACKER}
