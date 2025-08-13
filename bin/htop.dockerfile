FROM localhost/cpp AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

RUN apk add --no-cache ncurses-static pkgconf lm-sensors libcap-static libcap-dev libnl3-static musl-dev

RUN cd ${GH_REPO} && ./autogen.sh  && ./configure  --prefix=/opt/pusnow --enable-static && make -j && make install
FROM scratch
COPY --from=BUILD /opt /opt
