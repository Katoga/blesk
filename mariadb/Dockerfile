ARG BLESK_MARIADB_VERSION=lts

FROM alpine:3 AS builder

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash

SHELL [ "/bin/bash", "-o", "pipefail", "-euc" ]

WORKDIR /opt/mariadb

ARG BLESK_DOJO_VERSION
ARG BLESK_MARIADB_SCRIPTS_CHECKSUM_1
ARG BLESK_MARIADB_SCRIPTS_CHECKSUM_2
RUN wget -q \
    "https://github.com/Dojo-Open-Source-Project/samourai-dojo/raw/refs/tags/v${BLESK_DOJO_VERSION}/db-scripts/1_db.sql" \
  && echo "${BLESK_MARIADB_SCRIPTS_CHECKSUM_1}  1_db.sql" \
    | sha512sum -cws - \
  && wget -q \
    "https://github.com/Dojo-Open-Source-Project/samourai-dojo/raw/refs/tags/v${BLESK_DOJO_VERSION}/db-scripts/2_update.sql" \
  && echo "${BLESK_MARIADB_SCRIPTS_CHECKSUM_2}  2_update.sql" \
    | sha512sum -cws -

FROM mariadb:${BLESK_MARIADB_VERSION} AS runner

RUN apt-get update \
  && apt-get upgrade --assume-yes --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/mariadb/*.sql /docker-entrypoint-initdb.d/
