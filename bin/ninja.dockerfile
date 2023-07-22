FROM cpp AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}
RUN apk add --no-cache cmake

RUN cd ${GH_REPO} && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXE_LINKER_FLAGS="-static" -B release-build --install-prefix /opt/pusnow && cmake --build release-build --parallel --config Release && cmake --install release-build

FROM scratch
COPY --from=BUILD /opt /opt
