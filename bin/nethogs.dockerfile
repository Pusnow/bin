FROM localhost/cpp AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache ncurses-static libpcap-dev linux-headers

RUN cd ${GH_REPO} && make -j PREFIX=/opt/pusnow CPPFLAGS=-static && make install PREFIX=/opt/pusnow 
 
FROM scratch
COPY --from=BUILD /opt /opt
