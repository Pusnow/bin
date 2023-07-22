FROM base AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-untar.sh neofetch z "https://github.com/${GH_REPO}/archive/refs/tags/${VERSION}.tar.gz"
RUN mkdir -p /opt/pusnow/bin/ && mv neofetch/neofetch /opt/pusnow/bin/
RUN mkdir -p /opt/pusnow/share/man/man1/ && mv neofetch/neofetch.1 /opt/pusnow/share/man/man1/

FROM scratch
COPY --from=BUILD /opt /opt
