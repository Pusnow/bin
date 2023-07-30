FROM localhost/go AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache bash

RUN cd ${GH_REPO} && go build -a -ldflags "-linkmode external -extldflags -static -s -w -X main.version=${VERSION} -X main.revision=pusnow" -tags "" && mkdir -p /opt/pusnow/bin && cp fzf /opt/pusnow/bin/
RUN mkdir -p /opt/pusnow/shell && cp -r ${GH_REPO}/shell/key-bindings.* /opt/pusnow/shell
RUN mkdir -p /opt/pusnow/share/bash-completion/completions && cp -r ${GH_REPO}/shell/completion.bash /opt/pusnow/share/bash-completion/completions/fzf

FROM scratch
COPY --from=BUILD /opt /opt
