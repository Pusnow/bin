FROM cpp

RUN mkdir /build
RUN download-git.sh lshw master https://github.com/lyonel/lshw.git
RUN apk add --no-cache musl-libintl linux-headers gettext-tiny
RUN cd lshw && make static PREFIX=/opt/pusnow && make install PREFIX=/opt/pusnow
