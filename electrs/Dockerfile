FROM rust:1-slim-trixie AS builder

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
    libclang-dev \
    llvm-dev \
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


FROM gcr.io/distroless/cc-debian13:nonroot AS runner

COPY --from=builder /opt/electrs/target/release/electrs /usr/local/bin/
COPY --chown=nonroot:nonroot config.toml /etc/electrs/config.toml

ENTRYPOINT [ "/usr/local/bin/electrs" ]

ARG BLESK_ELECTRS_PORT

EXPOSE ${BLESK_ELECTRS_PORT}
