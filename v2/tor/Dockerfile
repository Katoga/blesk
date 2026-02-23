FROM debian:trixie-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

SHELL [ "/bin/bash", "-o", "pipefail", "-euc" ]

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get upgrade --assume-yes \
  && apt-get install --assume-yes --no-install-recommends \
    build-essential \
    ca-certificates \
    gnupg \
    libevent-dev \
    libssl-dev \
    wget \
    zlib1g-dev

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
    --disable-html-manual \
    --disable-manpage \
    --enable-lzma \
    --enable-zstd \
    --sysconfdir=/etc \
    --enable-static-libevent \
    --with-libevent-dir="$(ldconfig -p | grep libevent- | awk '{ print $4 }' | xargs -I {} dirname {})" \
  && make \
  && make install


FROM gcr.io/distroless/base-debian13:nonroot AS runner

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=builder /usr/local/bin/tor /usr/local/bin/tor
COPY ./torrc /etc/tor/torrc

ENTRYPOINT [ "/usr/local/bin/tor" ]
