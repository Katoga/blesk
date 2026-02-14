FROM alpine:3

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    netcat-openbsd

ARG BLESK_PORT_LISTENS_USERNAME
ARG BLESK_PORT_LISTENS_UID
ARG BLESK_PORT_LISTENS_GID
ARG BLESK_PORT_LISTENS_HOME

RUN addgroup -S \
    -g "$BLESK_PORT_LISTENS_GID" \
    "$BLESK_PORT_LISTENS_USERNAME" \
  && adduser -S \
    -h "$BLESK_PORT_LISTENS_HOME" \
    -u "$BLESK_PORT_LISTENS_UID" \
    -G "$BLESK_PORT_LISTENS_USERNAME" \
    "$BLESK_PORT_LISTENS_USERNAME"

USER "$BLESK_PORT_LISTENS_USERNAME"

COPY ./docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
