FROM alpine:3 AS builder

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    build-base \
    gnupg \
    libevent-dev \
    openssl-dev \
    zlib-dev

WORKDIR /opt/tor

ARG BLESK_TOR_VERSION

RUN ( \
    wget -q \
      -T 10 \
      "https://dist.torproject.org/tor-${BLESK_TOR_VERSION}.tar.gz" \
    || wget -q \
      -T 10 \
      "https://tor.eff.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz" \
    || wget -q \
      -T 10 \
      "https://mirrors.mit.edu/torproject/dist//tor-${BLESK_TOR_VERSION}.tar.gz" \
    || exit 10 \
  ) \
  && ( \
    wget -q \
      -T 10 \
      "https://tor.eff.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum" \
    || wget -q \
      -T 10 \
      "https://mirrors.mit.edu/torproject/dist//tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum" \
    || wget -q \
      -T 10 \
      "https://dist.torproject.org/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum" \
    || exit 20 \
  ) \
  && ( \
    wget -q \
      -T 10 \
      "https://mirrors.mit.edu/torproject/dist//tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum.asc" \
    || wget -q \
      -T 10 \
      "https://dist.torproject.org/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum.asc" \
    || wget -q \
      -T 10 \
      "https://tor.eff.org/dist/tor-${BLESK_TOR_VERSION}.tar.gz.sha256sum.asc" \
    || exit 30 \
  ) \
  && gpg --auto-key-locate nodefault,wkd --locate-keys ahf@torproject.org \
  && gpg --list-key  514102454D0A87DB0767A1EBBE6A0531C18A9179 \
  && gpg --auto-key-locate nodefault,wkd --locate-keys dgoulet@torproject.org \
  && gpg --list-key  B74417EDDF22AC9F9E90F49142E86A2A11F48D36 \
  && gpg --auto-key-locate nodefault,wkd --locate-keys nickm@torproject.org \
  && gpg --list-key  2133BC600AB133E1D826D173FE43009C4607B1FB \
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


FROM alpine:3 AS runner

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    libevent

ARG BLESK_TOR_USERNAME
ARG BLESK_TOR_UID
ARG BLESK_TOR_GID
ARG BLESK_TOR_HOME
ARG BLESK_TOR_ONIONS

RUN addgroup -S \
    -g "$BLESK_TOR_GID" \
    "$BLESK_TOR_USERNAME" \
  && adduser -S \
    -h "$BLESK_TOR_HOME" \
    -u "$BLESK_TOR_UID" \
    -G "$BLESK_TOR_USERNAME" \
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
