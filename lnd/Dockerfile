FROM alpine:3 AS builder-lnd

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    gnupg

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

WORKDIR /opt/lnd

ARG TARGETPLATFORM
ARG BLESK_LND_VERSION
ARG BLESK_LND_SIGNATURES
RUN arch="${TARGETPLATFORM##linux/}" \
  && tarball="lnd-linux-${arch}-v${BLESK_LND_VERSION}-beta.tar.gz" \
  && checksums_file="manifest-v${BLESK_LND_VERSION}-beta.txt" \
  && wget -q "https://github.com/lightningnetwork/lnd/releases/download/v${BLESK_LND_VERSION}-beta/$tarball" \
  && wget -q "https://github.com/lightningnetwork/lnd/releases/download/v${BLESK_LND_VERSION}-beta/${checksums_file}" \
  && for sig in ${BLESK_LND_SIGNATURES}; do \
      sig_file="manifest-${sig}-v${BLESK_LND_VERSION}-beta.sig" \
      && wget -q "https://github.com/lightningnetwork/lnd/releases/download/v${BLESK_LND_VERSION}-beta/${sig_file}" \
      && wget -q -O - "https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/${sig}.asc" \
        | gpg --import \
      && gpg --verify "$sig_file" "$checksums_file"; \
    done \
  && grep "$tarball" "$checksums_file" \
    | sha256sum -csw - \
  && tar -xvz \
    --strip-components 1 \
    -f "$tarball" \
  && mv ./lnd ./lncli /usr/local/bin/


FROM golang:1.25-alpine AS builder-lndinit

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    build-base \
    git \
    gnupg

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

WORKDIR /opt/lndinit

ARG TARGETPLATFORM
ARG BLESK_LNDINIT_VERSION

RUN git clone \
    --depth 1 \
    --branch "v${BLESK_LNDINIT_VERSION}-beta" \
    https://github.com/lightninglabs/lndinit . \
  && wget -q -O - "https://github.com/web-flow.gpg" \
    | gpg --import \
  && git verify-commit "v${BLESK_LNDINIT_VERSION}-beta" \
  && go get -u \
  && go build \
    -tags 'netgo' \
    -ldflags "-w -s -linkmode 'external' -extldflags '-static'" \
  && mv ./lndinit /usr/local/bin/


FROM golang:1.25-alpine AS builder-lndconnect

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    build-base

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

WORKDIR /opt/lndconnect

ARG TARGETPLATFORM
ARG BLESK_LNDCONNECT_VERSION
ARG BLESK_LNDCONNECT_CHECKSUM

RUN tarball="v${BLESK_LNDCONNECT_VERSION}.tar.gz" \
  && wget -q "https://github.com/LN-Zap/lndconnect/archive/refs/tags/${tarball}" \
  && echo "${BLESK_LNDCONNECT_CHECKSUM}  ${tarball}" \
    | sha512sum -csw - \
  && tar x -vz \
    --strip-components 1 \
    -f "$tarball" \
  && rm -f "$tarball" \
  && go build -o "${GOPATH}/bin/" -tags 'netgo' -ldflags "-w -s -linkmode 'external' -extldflags '-static'" \
  && mv "${GOPATH}/bin/lndconnect" /usr/local/bin


FROM alpine:3 AS runner

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    gettext-envsubst \
    inotify-tools

ARG BLESK_LND_USERNAME
ARG BLESK_LND_UID
ARG BLESK_LND_GID
ARG BLESK_LND_HOME
ARG BLESK_LND_SCB_BACKUP_DIR
ARG BLESK_TOR_USERNAME
ARG BLESK_TOR_GID
ARG BLESK_BITCOINCORE_USERNAME
ARG BLESK_BITCOINCORE_GID

RUN addgroup -S \
    -g "$BLESK_LND_GID" \
    "$BLESK_LND_USERNAME" \
  && addgroup -S \
    -g "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && addgroup -S \
    -g "$BLESK_BITCOINCORE_GID" \
    "$BLESK_BITCOINCORE_USERNAME" \
  && adduser -S \
    -h "$BLESK_LND_HOME" \
    -u "$BLESK_LND_UID" \
    -G "$BLESK_LND_USERNAME" \
    "$BLESK_LND_USERNAME" \
  && addgroup "$BLESK_LND_USERNAME" "$BLESK_TOR_USERNAME" \
  && addgroup "$BLESK_LND_USERNAME" "$BLESK_BITCOINCORE_USERNAME" \
  && mkdir "${BLESK_LND_HOME}/.lnd" \
  && chown "${BLESK_LND_UID}:${BLESK_LND_GID}" "${BLESK_LND_HOME}/.lnd" \
  && mkdir -p "${BLESK_LND_SCB_BACKUP_DIR}" \
  && chown "${BLESK_LND_UID}:${BLESK_LND_GID}" "$BLESK_LND_SCB_BACKUP_DIR"

USER "$BLESK_LND_USERNAME"
WORKDIR "${BLESK_LND_HOME}"

COPY --from=builder-lnd --chown="${BLESK_LND_UID}:${BLESK_LND_GID}" /usr/local/bin/lnd /usr/local/bin/lncli /usr/local/bin/
COPY --from=builder-lndinit --chown="${BLESK_LND_UID}:${BLESK_LND_GID}" /usr/local/bin/lndinit /usr/local/bin/
COPY --from=builder-lndconnect --chown="${BLESK_LND_UID}:${BLESK_LND_GID}" /usr/local/bin/lndconnect /usr/local/bin/
COPY --chown="${BLESK_LND_UID}:${BLESK_LND_GID}" lnd.conf.template ./

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

ARG BLESK_LND_PORT_P2P
ARG BLESK_LND_PORT_RPC
ARG BLESK_LND_PORT_REST

EXPOSE ${BLESK_LND_PORT_P2P}
EXPOSE ${BLESK_LND_PORT_RPC}
EXPOSE ${BLESK_LND_PORT_REST}
