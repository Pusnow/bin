FROM localhost/go AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache bash

RUN cd ${GH_REPO} && go build -a -ldflags "-linkmode external -extldflags -static -s -w -X main.version=${VERSION} -X main.revision=pusnow" -tags "" && mkdir -p /opt/pusnow/bin && cp fzf /opt/pusnow/bin/

FROM scratch
COPY --from=BUILD /opt /opt
