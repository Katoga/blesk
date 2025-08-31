FROM node:24-alpine AS builder

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    git \
    gnupg

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

WORKDIR /opt/rtl

ENV NODE_ENV=production

ARG BLESK_RTL_VERSION
RUN git clone \
    --depth 1 \
    --branch "v${BLESK_RTL_VERSION}" \
    https://github.com/Ride-The-Lightning/RTL.git . \
  && wget -q -O - "https://keybase.io/suheb/pgp_keys.asc" \
    | gpg --import \
  && git verify-tag "v${BLESK_RTL_VERSION}" \
  && npm ci --legacy-peer-deps --no-audit --no-fund --no-update-notifier


FROM node:24-alpine AS runner

# hadolint ignore=DL3016,DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    jq

ARG BLESK_RTL_USERNAME
ARG BLESK_RTL_UID
ARG BLESK_RTL_GID
ARG BLESK_RTL_HOME
ARG BLESK_LND_USERNAME
ARG BLESK_LND_GID

RUN addgroup -S \
    -g "$BLESK_RTL_GID" \
    "$BLESK_RTL_USERNAME" \
  && addgroup -S \
    -g "$BLESK_LND_GID" \
    "$BLESK_LND_USERNAME" \
  && adduser -S \
    -h "$BLESK_RTL_HOME" \
    -u "$BLESK_RTL_UID" \
    -G "$BLESK_RTL_USERNAME" \
    "$BLESK_RTL_USERNAME" \
  && addgroup "$BLESK_RTL_USERNAME" "$BLESK_LND_USERNAME" \
  && mkdir "${BLESK_RTL_HOME}/rtl" \
  && chown "${BLESK_RTL_UID}:${BLESK_RTL_GID}" "${BLESK_RTL_HOME}/rtl"

USER "$BLESK_RTL_USERNAME"

WORKDIR "$BLESK_RTL_HOME"

COPY --from=builder --chown="${BLESK_RTL_UID}:${BLESK_RTL_GID}" /opt/rtl/ ./rtl/

COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

ARG BLESK_RTL_PORT

EXPOSE ${BLESK_RTL_PORT}
