FROM go AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV CGO_ENABLED=0
RUN cd ${GH_REPO} && go build -ldflags "-X main.VersionString=${VERSION}" && mkdir -p /opt/pusnow/bin && cp dnslookup /opt/pusnow/bin/

FROM scratch
COPY --from=BUILD /opt /opt
