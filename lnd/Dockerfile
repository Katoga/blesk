FROM alpine:3 AS builder

# hadolint ignore=DL3018
RUN apk --no-cache add \
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
  && tar -xvzf "$tarball" \
  && mv "lnd-linux-${arch}-v${BLESK_LND_VERSION}-beta/lnd" "lnd-linux-${arch}-v${BLESK_LND_VERSION}-beta/lncli" /usr/local/bin/


FROM alpine:3 AS runner

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash

ARG BLESK_LND_USERNAME
ARG BLESK_LND_UID
ARG BLESK_LND_GID
ARG BLESK_TOR_USERNAME
ARG BLESK_TOR_GID

ENV BLESK_LND_HOME="/home/${BLESK_LND_USERNAME}"

RUN addgroup -S \
    -g "$BLESK_LND_GID" \
    "$BLESK_LND_USERNAME" \
  && addgroup -S \
    -g "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && adduser -S \
    -h "$BLESK_LND_HOME" \
    -u "$BLESK_LND_UID" \
    -G "$BLESK_LND_USERNAME" \
    "$BLESK_LND_USERNAME" \
  && addgroup "$BLESK_LND_USERNAME" "$BLESK_TOR_USERNAME" \
  && mkdir "${BLESK_LND_HOME}/.lnd" \
  && chown "${BLESK_LND_UID}:${BLESK_LND_GID}" "${BLESK_LND_HOME}/.lnd"

USER "$BLESK_LND_USERNAME"
WORKDIR "${BLESK_LND_HOME}"

COPY --from=builder --chown="${BLESK_LND_UID}:${BLESK_LND_GID}" /usr/local/bin/lnd /usr/local/bin/lncli /usr/local/bin/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
