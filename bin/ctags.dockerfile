FROM localhost/cpp AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

RUN cd ${GH_REPO} && ./autogen.sh  && LDFLAGS="-static" ./configure --prefix=/opt/pusnow --enable-static && make -j && make install
 
# FROM scratch
# COPY --from=BUILD /opt /opt
