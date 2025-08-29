FROM node:24-alpine AS builder

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    build-base \
    ca-certificates \
    gnupg \
    gyp \
    wget

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

WORKDIR /opt/dojo

ARG BLESK_DOJO_VERSION
RUN wget -nv \
    -O "samourai-dojo-${BLESK_DOJO_VERSION}.tar.gz" \
    "https://github.com/Dojo-Open-Source-Project/samourai-dojo/archive/refs/tags/v${BLESK_DOJO_VERSION}.tar.gz" \
  && wget -nv "https://github.com/Dojo-Open-Source-Project/samourai-dojo/releases/download/v${BLESK_DOJO_VERSION}/samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt" \
  && wget -nv "https://github.com/Dojo-Open-Source-Project/samourai-dojo/releases/download/v${BLESK_DOJO_VERSION}/samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt.sig" \
  && wget -nv -O - https://keys.openpgp.org/vks/v1/by-fingerprint/E53AD419B242822F19E23C6D3033D463D6E544F6 \
    | gpg --import \
  && gpg --verify "samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt.sig" \
  && grep 'tar\.gz' "samourai-dojo-${BLESK_DOJO_VERSION}-fingerprints.txt" \
    | sha256sum -cs - \
  && tar -xvz \
    --strip-components 1 \
    -f "samourai-dojo-${BLESK_DOJO_VERSION}.tar.gz" \
  && rm -f samourai-dojo-${BLESK_DOJO_VERSION}* \
  && npm install --no-audit --no-fund --no-update-notifier \
    --omit=dev \
  && mv ./static/admin/conf/index-mainnet.js ./static/admin/conf/index.js \
  && sed -Ei "s~^(const INTERPRETER =).+~\\1 'node'~" ./pm2.config.cjs.example \
  && mv ./pm2.config.cjs.example ./pm2.config.cjs

FROM node:24-alpine AS runner

# hadolint ignore=DL3016,DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
  && npm install -g \
    pm2

ARG BLESK_DOJO_USERNAME
ARG BLESK_DOJO_UID
ARG BLESK_DOJO_GID
ARG BLESK_DOJO_HOME
ARG BLESK_TOR_USERNAME
ARG BLESK_TOR_GID

RUN addgroup -S \
    -g "$BLESK_DOJO_GID" \
    "$BLESK_DOJO_USERNAME" \
  && addgroup -S \
    -g "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && adduser -S \
    -h "$BLESK_DOJO_HOME" \
    -u "$BLESK_DOJO_UID" \
    -G "$BLESK_DOJO_USERNAME" \
    "$BLESK_DOJO_USERNAME" \
  && addgroup "$BLESK_DOJO_USERNAME" "$BLESK_TOR_USERNAME"

USER "$BLESK_DOJO_USERNAME"

WORKDIR "$BLESK_DOJO_HOME"

COPY --from=builder --chown="${BLESK_DOJO_UID}:${BLESK_DOJO_GID}" /opt/dojo/ ./dojo/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
