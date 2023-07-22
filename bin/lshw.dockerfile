FROM cpp AS BUILD
ARG VERSION
RUN download-untar.sh lshw z "https://github.com/lyonel/lshw/archive/$VERSION.tar.gz"

RUN apk add --no-cache musl-libintl linux-headers gettext-tiny

RUN cd lshw && make static PREFIX=/opt/pusnow && make install PREFIX=/opt/pusnow

FROM scratch
COPY --from=BUILD /opt /opt
