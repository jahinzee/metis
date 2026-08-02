FROM ghcr.io/ublue-os/kinoite-main:latest

COPY build.sh /tmp

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    /bin/bash /tmp/build.sh