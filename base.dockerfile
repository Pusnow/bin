FROM alpine:edge

RUN apk add --no-cache git
COPY *.sh /bin/

WORKDIR /root
VOLUME ["/out"]
