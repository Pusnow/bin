FROM cpp

RUN mkdir /build

RUN apk add --no-cache openssl-dev openssl-libs-static

RUN download-git.sh socat "${VERSION}" "git://repo.or.cz/socat.git"
ENV LDFLAGS=-static
RUN cd socat && autoconf && ./configure --prefix=/opt/pusnow && make -j progs
RUN mkdir -p /opt/pusnow/bin && cd socat && install -m 755 socat procan filan /opt/pusnow/bin
