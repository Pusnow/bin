FROM localhost/cpp AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

RUN cd ${GH_REPO} && meson setup build
 
FROM scratch
COPY --from=BUILD /opt /opt
