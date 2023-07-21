FROM cpp
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache oniguruma-dev flex bison libtool

RUN cd ${GH_REPO} && autoreconf -i && ./configure --prefix=/opt/pusnow


RUN cd ${GH_REPO} && make LDFLAGS=-all-static -j && make install
