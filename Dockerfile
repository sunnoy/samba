# syntax=docker/dockerfile:1

FROM alpine:edge

RUN set -eu && \
    apk --no-cache add \
    tini \
    bash \
    samba \
    tzdata \
    shadow && \
    addgroup -S smb && \
    rm -f /etc/samba/smb.conf && \
    rm -rf /tmp/* /var/cache/apk/*

COPY --chmod=755 samba.sh /usr/bin/samba.sh
COPY --chmod=664 smb.conf /etc/samba/smb.default

VOLUME /storage
EXPOSE 137/udp 138/udp 139 445

ENV NAME="Data"
ENV USER="samba"
ENV PASS="secret"

ENV UID=1000
ENV GID=1000
ENV RW=true

HEALTHCHECK --interval=60s --timeout=15s CMD smbclient --configfile=/etc/samba.conf -L \\localhost -U % -m SMB3

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/samba.sh"]
