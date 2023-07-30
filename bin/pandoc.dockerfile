FROM localhost/base AS BUILD
ARG VERSION
ARG GH_REPO
ARG VERSION_ARCH

RUN download-untar.sh pandoc z "https://github.com/${GH_REPO}/releases/download/${VERSION}/pandoc-${VERSION}-linux-${VERSION_ARCH}.tar.gz"
RUN mv pandoc /opt/pusnow

FROM scratch
COPY --from=BUILD /opt /opt
