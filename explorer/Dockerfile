FROM node:24-bookworm-slim AS builder

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes \
  && apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    wget

WORKDIR /opt/explorer

ARG BLESK_EXPLORER_VERSION
ARG BLESK_EXPLORER_CHECKSUM
RUN tarball="v${BLESK_EXPLORER_VERSION}+SW.tar.gz" \
  && wget -nv "https://github.com/Dojo-Open-Source-Project/btc-rpc-explorer/archive/refs/tags/${tarball}" \
  && echo "${BLESK_EXPLORER_CHECKSUM}  ${tarball}" \
    | sha512sum --check --status - \
  && tar -xvz \
    -f "$tarball" \
    --strip-components 1 \
  && rm -f "$tarball" \
  && npm install --no-update-notifier \
    --audit=false \
    --fund=false


FROM node:24-bookworm-slim AS runner

RUN apt-get update \
  && apt-get upgrade --assume-yes --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG BLESK_EXPLORER_USERNAME
ARG BLESK_EXPLORER_UID
ARG BLESK_EXPLORER_GID
ARG BLESK_EXPLORER_HOME

RUN groupadd --system \
    --key SYS_GID_MIN="$BLESK_EXPLORER_GID" \
    --key SYS_GID_MAX="$BLESK_EXPLORER_GID" \
    --gid "$BLESK_EXPLORER_GID" \
    "$BLESK_EXPLORER_USERNAME" \
  && useradd --system --create-home \
    --home-dir "$BLESK_EXPLORER_HOME" \
    --key SYS_UID_MIN="$BLESK_EXPLORER_UID" \
    --key SYS_UID_MAX="$BLESK_EXPLORER_UID" \
    --uid "$BLESK_EXPLORER_UID" \
    --key SYS_GID_MIN="$BLESK_EXPLORER_GID" \
    --key SYS_GID_MAX="$BLESK_EXPLORER_GID" \
    --gid "$BLESK_EXPLORER_GID" \
    "$BLESK_EXPLORER_USERNAME" \
  && mkdir "${BLESK_EXPLORER_HOME}/explorer" \
  && chown "${BLESK_EXPLORER_UID}:${BLESK_EXPLORER_GID}" "${BLESK_EXPLORER_HOME}/explorer"

USER "$BLESK_EXPLORER_USERNAME"

WORKDIR "$BLESK_EXPLORER_HOME"

COPY --from=builder --chown="${BLESK_EXPLORER_UID}:${BLESK_EXPLORER_GID}" /opt/explorer/ ./

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
