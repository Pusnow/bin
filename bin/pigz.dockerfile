FROM localhost/cpp AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-untar.sh pigz z "https://github.com/madler/pigz/archive/refs/tags/${VERSION}.tar.gz"
RUN apk add --no-cache zlib-dev zlib-static

RUN sed -i 's/LDFLAGS=/LDFLAGS=-static/' pigz/Makefile
RUN cd pigz && make -j
RUN mkdir -p /opt/pusnow/bin && mv pigz/pigz /opt/pusnow/bin
RUN mkdir -p /opt/pusnow/share/man/man1/ && mv pigz/pigz.1 /opt/pusnow/share/man/man1/

FROM scratch
COPY --from=BUILD /opt /opt
