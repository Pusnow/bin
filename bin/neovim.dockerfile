FROM cpp
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache cmake lua-dev wget musl-libintl

# RUN cd ${GH_REPO} && make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/opt/pusnow/ && make install
