FROM localhost/rust AS BUILD
ARG VERSION
ARG GH_REPO
ARG EXTRA_RUN

RUN apk add --no-cache perl

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV RUSTFLAGS='-C link-arg=-s -C link-arg=-fuse-ld=lld'
RUN . "$HOME/.cargo/env" && cargo install --path ${GH_REPO} --root /opt/pusnow

FROM scratch
COPY --from=BUILD /opt /opt
