FROM localhost/rust AS BUILD
ARG VERSION
ARG GH_REPO
ARG EXTRA_RUN

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV RUSTFLAGS='-C link-arg=-s -Clinker=rust-lld'
RUN . "$HOME/.cargo/env" && cargo install --path ${GH_REPO}/crates/ruff_cli --root /opt/pusnow

FROM scratch
COPY --from=BUILD /opt /opt
