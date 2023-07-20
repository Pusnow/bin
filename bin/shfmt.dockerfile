FROM go
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV CGO_ENABLED=0
RUN cd ${GH_REPO}/cmd/shfmt && go build && mkdir -p /opt/pusnow/bin && cp shfmt /opt/pusnow/bin/
