FROM rust:1.91-slim-trixie AS builder

ENV DEBIAN_FRONTEND=noninteractive

ARG BLESK_ELECTRS_VERSION

SHELL [ "/bin/bash", "-euo", "pipefail", "-c" ]

WORKDIR /opt/electrs

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes \
  && apt-get install --assume-yes --no-install-recommends \
    build-essential \
    clang \
    cmake \
    git \
    gnupg \
    wget \
  && wget -nv \
    -O - \
    https://romanzey.de/pgp.txt \
  | gpg --import \
  && git clone \
    --depth 1 \
    --branch "v${BLESK_ELECTRS_VERSION}" \
    https://github.com/romanz/electrs.git . \
  && git verify-tag "v${BLESK_ELECTRS_VERSION}" \
  && cargo build --locked --release


FROM debian:trixie-slim AS runner

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes --no-install-recommends \
  && apt-get install --assume-yes --no-install-recommends \
    gettext-base \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG BLESK_ELECTRS_USERNAME
ARG BLESK_ELECTRS_UID
ARG BLESK_ELECTRS_GID
ARG BLESK_ELECTRS_HOME
ARG BLESK_BITCOINCORE_USERNAME
ARG BLESK_BITCOINCORE_GID

RUN groupadd --system \
    --key SYS_GID_MIN="$BLESK_ELECTRS_GID" \
    --key SYS_GID_MAX="$BLESK_ELECTRS_GID" \
    --gid "$BLESK_ELECTRS_GID" \
    "$BLESK_ELECTRS_USERNAME" \
  && groupadd --system \
    --key SYS_GID_MIN="$BLESK_BITCOINCORE_GID" \
    --key SYS_GID_MAX="$BLESK_BITCOINCORE_GID" \
    --gid "$BLESK_BITCOINCORE_GID" \
    "$BLESK_BITCOINCORE_USERNAME" \
  && useradd --system --create-home \
    --home-dir "$BLESK_ELECTRS_HOME" \
    --key SYS_UID_MIN="$BLESK_ELECTRS_UID" \
    --key SYS_UID_MAX="$BLESK_ELECTRS_UID" \
    --uid "$BLESK_ELECTRS_UID" \
    --key SYS_GID_MIN="$BLESK_ELECTRS_GID" \
    --key SYS_GID_MAX="$BLESK_ELECTRS_GID" \
    --gid "$BLESK_ELECTRS_GID" \
    --groups "$BLESK_BITCOINCORE_GID" \
    "$BLESK_ELECTRS_USERNAME" \
  && mkdir "${BLESK_ELECTRS_HOME}/db" \
  && chown -h "${BLESK_ELECTRS_USERNAME}:${BLESK_ELECTRS_USERNAME}" "${BLESK_ELECTRS_HOME}/db"

USER "$BLESK_ELECTRS_USERNAME"

WORKDIR "$BLESK_ELECTRS_HOME"

COPY --from=builder --chown="${BLESK_ELECTRS_UID}:${BLESK_ELECTRS_GID}" /opt/electrs/target/release/electrs /usr/local/bin/
COPY --chown="${BLESK_ELECTRS_UID}:${BLESK_ELECTRS_GID}" config.toml.template /etc/electrs/

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

ARG BLESK_ELECTRS_PORT

EXPOSE ${BLESK_ELECTRS_PORT}
