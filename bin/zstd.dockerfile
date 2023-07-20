FROM base
ARG VERSION
RUN mkdir /build

RUN apk add --no-cache meson ninja
RUN download-untar.sh zstd z "https://github.com/facebook/zstd/releases/download/${VERSION}/zstd-${VERSION:1}.tar.gz"
ENV LDFLAGS=-static
RUN cd zstd/build/meson && meson setup --prefix "/opt/pusnow/zstd" -Dbin_programs=true -Dstatic_runtime=true -Ddefault_library=static -Dzlib=disabled -Dlzma=disabled -Dlz4=disabled builddir
RUN cd zstd/build/meson/builddir && ninja && ninja install
