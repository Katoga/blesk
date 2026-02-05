FROM debian:trixie-slim AS builder

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
  && make install \
  # empty dir needed for seting permission on data dir in runner
  && mkdir /empty

FROM gcr.io/distroless/base-debian13:nonroot AS runner

# just to set owner of the dir where volume is mounted
ARG BLESK_TOR_COOKIE_DIR
COPY --from=builder --chown=nonroot:nonroot /empty/ ${BLESK_TOR_COOKIE_DIR}

COPY --from=builder /usr/lib/x86_64-linux-gnu/libevent-2.1.so.7 /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/local/bin/tor /usr/local/bin/tor
COPY ./torrc /etc/tor/torrc

ENTRYPOINT [ "/usr/local/bin/tor" ]

ARG BLESK_TOR_PORT_SOCKS
ARG BLESK_TOR_PORT_CONTROL

EXPOSE ${BLESK_TOR_PORT_SOCKS}
EXPOSE ${BLESK_TOR_PORT_CONTROL}
