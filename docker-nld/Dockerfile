# mynginx + lua + mariadb(mysql) + redis
#
# Use monit to manage multiple processes
#
# docker build --force-rm --no-cache --rm -t shmilee/nld:$(date +%y%m%d) .
# docker tag shmilee/nld:$(date +%y%m%d) shmilee/nld:using
#
# docker run --rm -p 80:80 -v $PWD/etc:/srv/etc:ro -v $PWD/log:/srv/log:rw \
#   --mount type=volume,src=volume_name,dst=/var/lib/mysql shmilee/nld:using

FROM alpine:3.8

LABEL maintainer="shmilee <shmilee.zju@gmail.com>" version="1.0"

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    TIMEZONE=Asia/Shanghai \
    TERM=xterm-color

ADD ./monit_init.sh /usr/bin/monit_init.sh

# Add my repository
COPY ./*@*.rsa.pub /etc/apk/keys/
RUN echo http://shmilee.io/repo-shmilee/alpine-v3.8/shmilee > /etc/apk/repositories

RUN echo https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/main >> /etc/apk/repositories \
 && echo https://mirrors.tuna.tsinghua.edu.cn/alpine/v3.8/community >> /etc/apk/repositories \
 && addgroup -g 82 -S www-data \
 && adduser -u 82 -D -S -h /srv/http -G www-data -g www-data www-data \
 && echo "==> tini monit nginx mariadb ..." \
 && apk --no-cache add coreutils bash tzdata ca-certificates openssl \
        tini monit iproute2 \
        mynginx mynginx-meta-small-modules \
        mariadb mariadb-client redis \
        lua5.1-cjson \
 && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
 && echo "${TIMEZONE}" > /etc/timezone \
 && echo "==> clean ..." \
 && find /usr/share/terminfo/ -type f -not \( -name 'ansi' -o -name 'dumb' -o -name 'linux' \
        -o -name 'vt100' -o -name 'vt220' -o -name 'xterm' \) -exec rm {} \; \
 && chmod +x /usr/bin/monit_init.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["monit_init.sh", "5"]
