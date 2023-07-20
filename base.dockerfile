FROM alpine:latest

RUN apk add --no-cache gcc g++ make git github-cli autoconf gettext-tiny automake libtool readline readline-dev
COPY *.sh /bin/

WORKDIR /root
VOLUME ["/out"]
