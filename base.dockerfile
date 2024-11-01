FROM alpine:edge

RUN apk add --no-cache git
COPY *.sh /bin/

WORKDIR /root
ENV JEMALLOC_SYS_WITH_LG_PAGE 16
VOLUME ["/out"]
