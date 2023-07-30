FROM localhost/go AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV CGO_ENABLED=0
RUN cd ${GH_REPO} && make install prefix=/opt/pusnow
RUN mkdir -p /opt/pusnow/share/bash-completion/completions && /opt/pusnow/bin/gh completion --shell bash >/opt/pusnow/share/bash-completion/completions/gh

FROM scratch
COPY --from=BUILD /opt /opt
