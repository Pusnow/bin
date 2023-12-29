FROM localhost/cpp AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache libarchive-static libarchive-dev xz-static xz-dev asciidoc

ENV LDFLAGS="-static"
RUN cd ${GH_REPO} && ./autogen.sh && ./configure --prefix=/opt/pusnow
RUN cd ${GH_REPO} && make -j && make install

FROM scratch
COPY --from=BUILD /opt /opt
