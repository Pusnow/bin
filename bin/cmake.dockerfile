FROM localhost/base AS BUILD
ARG VERSION
ARG GH_REPO
ARG VERSION_ARCH

RUN download-untar.sh cmake z "https://github.com/${GH_REPO}/releases/download/${VERSION}/cmake-${VERSION:1}-linux-${VERSION_ARCH}.tar.gz"
RUN mv cmake /opt/pusnow
RUN rm -rf /opt/pusnow/doc/cmake/html

FROM scratch
COPY --from=BUILD /opt /opt
