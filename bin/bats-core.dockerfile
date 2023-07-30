FROM localhost/base AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-untar.sh bats-core z "https://github.com/${GH_REPO}/archive/refs/tags/${VERSION}.tar.gz"
RUN apk add --no-cache bash
RUN bats-core/install.sh /opt/pusnow/

FROM scratch
COPY --from=BUILD /opt /opt
