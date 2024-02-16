FROM localhost/rust AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV RUSTFLAGS='-C link-arg=-s -Clinker=rust-lld'
RUN . "$HOME/.cargo/env" && cargo install --path ${GH_REPO} --root /opt/pusnow
RUN mkdir -p /opt/pusnow/share/bash-completion/completions
RUN /opt/pusnow/bin/rg --generate complete-bash >/opt/pusnow/share/bash-completion/completions/rg

FROM scratch
COPY --from=BUILD /opt /opt
