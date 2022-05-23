# docker backup image (native/docker-backup).

FROM alpine
MAINTAINER nativeit <dev@nativeit.net>

RUN apk --no-cache add \
    tar \
    xz \
    bash \
    grep

ADD backup.sh /root/

VOLUME /backup
ENTRYPOINT ["/root/backup.sh"]
CMD ["backup"]
