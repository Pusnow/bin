FROM localhost/cpp AS BUILD
ARG VERSION
RUN download-untar.sh lshw z "https://github.com/lyonel/lshw/archive/$VERSION.tar.gz"

RUN apk add --no-cache musl-libintl linux-headers gettext-tiny

RUN cd lshw && make static PREFIX=/opt/pusnow && make install PREFIX=/opt/pusnow
RUN cp lshw/src/lshw-static /opt/pusnow/sbin/lshw
FROM scratch
COPY --from=BUILD /opt /opt
