FROM base
ARG VERSION
ARG GH_REPO
ARG VERSION_ARCH

RUN download-untar.sh shellcheck J "https://github.com/${GH_REPO}/releases/download/${VERSION}/shellcheck-${VERSION}.linux.${VERSION_ARCH}.tar.xz"
RUN mkdir -p /opt/pusnow/bin/ && mv shellcheck/shellcheck /opt/pusnow/bin/