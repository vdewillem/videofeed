FROM nimmis/alpine-micro
MAINTAINER Willem <vdewillem@gmail.com>

RUN set -xe \
    && apk add --no-cache ca-certificates \
                          ffmpeg \
                          openssl \
                          python3 \
    && pip3 install youtube-dl pocket

ADD app/ /app

cmd ["/usr/bin/python3","/app/parser.py"]