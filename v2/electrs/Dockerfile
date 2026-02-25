FROM rust:1-slim-trixie AS builder

ENV DEBIAN_FRONTEND=noninteractive

ARG BLESK_ELECTRS_VERSION
ARG BLESK_ELECTRS_SSH_KEY_FINGERPRINT

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
    openssh-client \
    wget \
  && wget -nv \
    -O - \
    https://romanzey.de/pgp.txt \
  | gpg --import \
  && git clone \
    --depth 1 \
    --branch "v${BLESK_ELECTRS_VERSION}" \
    https://github.com/romanz/electrs.git . \
  && export allowed_signers_file="${HOME}/.config/git/allowed_signers" \
  && mkdir -p "$(dirname "${allowed_signers_file}")" \
  && wget -nv \
    -O "${allowed_signers_file}" \
    https://github.com/romanz.keys \
  && git config --global gpg.ssh.allowedSignersFile "${allowed_signers_file}" \
  && \
  ( \
    set +o pipefail \
    && git verify-tag "v${BLESK_ELECTRS_VERSION}" \
    || git verify-tag "v${BLESK_ELECTRS_VERSION}" 2>&1 \
      | grep "Good \"git\" signature with ED25519 key SHA256:${BLESK_ELECTRS_SSH_KEY_FINGERPRINT}" \
  ) \
  && cargo build --locked --release

FROM gcr.io/distroless/cc-debian13:nonroot AS runner

COPY --from=builder /opt/electrs/target/release/electrs /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/electrs" ]
