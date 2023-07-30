FROM cpp AS BUILD
ARG VERSION
ARG GH_REPO
RUN mkdir /build

RUN download-ghr.sh ${GH_REPO} ${VERSION}

RUN apk add --no-cache meson ninja

ENV LDFLAGS=-static
RUN cd ${GH_REPO}/build/meson && meson setup --prefix "/opt/pusnow" -Dbin_programs=true -Dstatic_runtime=true -Ddefault_library=static -Dzlib=disabled -Dlzma=disabled -Dlz4=disabled builddir
RUN cd ${GH_REPO}/build/meson/builddir && ninja && ninja install

FROM scratch
COPY --from=BUILD /opt /opt
