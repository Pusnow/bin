FROM localhost/base AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN cd ${GH_REPO} && ./install --prefix /opt/pusnow

FROM scratch
COPY --from=BUILD /opt /opt
