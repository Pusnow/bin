FROM go
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV CGO_ENABLED=0
RUN cd ${GH_REPO} && go build
RUN cd ${GH_REPO} && install -d /opt/pusnow/bin && install -t /opt/pusnow/bin rclone
RUN cd ${GH_REPO} && install -d /opt/pusnow/share/man/man1 && install -t /opt/pusnow/share/man/man1 rclone.1
