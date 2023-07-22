FROM cpp
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache cmake lua-dev wget musl-libintl

RUN cd ${GH_REPO} && make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/opt/pusnow/ CMAKE_EXTRA_FLAGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_EXE_LINKER_FLAGS=-static" && make install
