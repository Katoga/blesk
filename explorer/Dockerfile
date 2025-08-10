FROM node:24-alpine3.22 AS builder

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

WORKDIR /opt/explorer

ARG BLESK_EXPLORER_VERSION
ARG BLESK_EXPLORER_CHECKSUM
RUN tarball="v${BLESK_EXPLORER_VERSION}+SW.tar.gz" \
  && wget -q "https://github.com/Dojo-Open-Source-Project/btc-rpc-explorer/archive/refs/tags/${tarball}" \
  && echo "${BLESK_EXPLORER_CHECKSUM}  ${tarball}" \
    | sha512sum -csw - \
  && tar -xvz \
    -f "$tarball" \
    --strip-components 1 \
  && rm -f "$tarball" \
  && npm install --no-update-notifier \
    --audit=false \
    --fund=false


FROM node:24-alpine3.22 AS runner

# hadolint ignore=DL3016,DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash

ARG BLESK_EXPLORER_USERNAME
ARG BLESK_EXPLORER_UID
ARG BLESK_EXPLORER_GID
ARG BLESK_EXPLORER_HOME

RUN addgroup -S \
    -g "$BLESK_EXPLORER_GID" \
    "$BLESK_EXPLORER_USERNAME" \
  && adduser -S \
    -h "$BLESK_EXPLORER_HOME" \
    -u "$BLESK_EXPLORER_UID" \
    -G "$BLESK_EXPLORER_USERNAME" \
    "$BLESK_EXPLORER_USERNAME" \
  && mkdir "${BLESK_EXPLORER_HOME}/explorer" \
  && chown "${BLESK_EXPLORER_UID}:${BLESK_EXPLORER_GID}" "${BLESK_EXPLORER_HOME}/explorer"

USER "$BLESK_EXPLORER_USERNAME"

WORKDIR "$BLESK_EXPLORER_HOME"

COPY --from=builder --chown="${BLESK_EXPLORER_UID}:${BLESK_EXPLORER_GID}" /opt/explorer/ ./

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
