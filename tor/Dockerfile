FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes \
  && apt-get install --assume-yes --no-install-recommends \
    build-essential \
    ca-certificates \
    gnupg \
    libevent-dev \
    libssl-dev \
    libzip-dev \
    wget

WORKDIR /opt/tor

ARG BLESK_TOR_VERSION

RUN ( \
    wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://dist.torproject.org/tor-${BLESK_TOR_VERSION}.tar.gz" \
    || wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://tor.eff.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz" \
    || wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://tor.calyxinstitute.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz" \
    || exit 10 \
  ) \
  && ( \
    wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://tor.eff.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum" \
    || wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://tor.calyxinstitute.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum" \
    || wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://dist.torproject.org/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum" \
    || exit 20 \
  ) \
  && ( \
    wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://tor.calyxinstitute.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum.asc" \
    || wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://dist.torproject.org/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum.asc" \
    || wget -nv \
      --timeout=10 \
      --tries=2 \
      "https://tor.eff.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum.asc" \
    || exit 30 \
  ) \
  && gpg --batch \
    --keyserver hkps://keyserver.ubuntu.com:443 \
    --recv-keys \
      0xEB5A896A28988BF5 \
      0xC218525819F78451 \
      0x21194EBB165733EA \
      0x6AFEE6D49E92B601 \
      B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
      514102454D0A87DB0767A1EBBE6A0531C18A9179 \
  && gpg --verify "tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum.asc" \
  && sha256sum -c "tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum" \
  && tar -xvz \
    --strip-components 1 \
    -f "tor-${BLESK_TOR_VERSION}.tar.gz" \
  && ./configure \
    --disable-asciidoc \
    --disable-unittests \
    --sysconfdir=/etc \
  && make \
  && make install


FROM debian:bookworm-slim AS runner

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes --no-install-recommends \
  && apt-get install --assume-yes --no-install-recommends \
    libevent-2.1 \
    libssl3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG BLESK_TOR_USERNAME
ARG BLESK_TOR_UID
ARG BLESK_TOR_GID
ARG BLESK_TOR_HOME
ARG BLESK_TOR_ONIONS

RUN groupadd --system \
    --key SYS_GID_MIN="$BLESK_TOR_GID" \
    --key SYS_GID_MAX="$BLESK_TOR_GID" \
    --gid "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && useradd --system --create-home \
    --home-dir "$BLESK_TOR_HOME" \
    --key SYS_UID_MIN="$BLESK_TOR_UID" \
    --key SYS_UID_MAX="$BLESK_TOR_UID" \
    --uid "$BLESK_TOR_UID" \
    --key SYS_GID_MIN="$BLESK_TOR_GID" \
    --key SYS_GID_MAX="$BLESK_TOR_GID" \
    --gid "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && mkdir \
    --mode 0750 \
    /etc/tor \
    "${BLESK_TOR_ONIONS}" \
  && mkdir \
    --mode 0700 \
    "${BLESK_TOR_HOME}/.tor" \
  && chown -R "${BLESK_TOR_UID}:${BLESK_TOR_GID}" \
    /etc/tor \
    "$BLESK_TOR_HOME"

USER "$BLESK_TOR_USERNAME"

WORKDIR "$BLESK_TOR_HOME"

COPY --from=builder /usr/local/bin/tor /usr/local/bin/tor
COPY --from=builder --chown="${BLESK_TOR_UID}:${BLESK_TOR_GID}" /etc/tor/ /etc/tor

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
