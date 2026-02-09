FROM alpine:3

# hadolint ignore=DL3018
RUN apk --no-cache upgrade \
  && apk --no-cache add \
    bash \
    inotify-tools

ARG BLESK_FILE_READY_USERNAME
ARG BLESK_FILE_READY_UID
ARG BLESK_FILE_READY_GID
ARG BLESK_FILE_READY_HOME

RUN addgroup -S \
    -g "$BLESK_FILE_READY_GID" \
    "$BLESK_FILE_READY_USERNAME" \
  && adduser -S \
    -h "$BLESK_FILE_READY_HOME" \
    -u "$BLESK_FILE_READY_UID" \
    -G "$BLESK_FILE_READY_USERNAME" \
    "$BLESK_FILE_READY_USERNAME"

USER "$BLESK_FILE_READY_USERNAME"

COPY ./docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
