FROM cpp AS BUILD
ARG VERSION
RUN mkdir /build

RUN apk add --no-cache openssl-dev openssl-libs-static

RUN download-untar.sh iperf z "https://github.com/esnet/iperf/archive/refs/tags/${VERSION}.tar.gz"
ENV LDFLAGS="-static"
RUN cd iperf && autoconf && ./configure --prefix=/opt/pusnow --disable-shared --enable-static --enable-doc --enable-tool && make LDFLAGS="-all-static" -j
RUN cd iperf && make install

FROM scratch
COPY --from=BUILD /opt /opt
