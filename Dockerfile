# docker backup image (piscue/docker-backup).

FROM alpine
MAINTAINER piscue <piscue+github@gmail.com>

RUN apk --no-cache add \
    tar \
    xz \
    bash \
    grep

ADD backup.sh /root/

VOLUME /backup
ENTRYPOINT ["/root/backup.sh"]
CMD ["backup"]
