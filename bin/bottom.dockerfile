FROM localhost/rust AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV RUSTFLAGS='-C link-arg=-s -Clinker=rust-lld'
ENV BTM_GENERATE="Y"
RUN . "$HOME/.cargo/env" && cargo install --path ${GH_REPO} --root /opt/pusnow
RUN mkdir -p /opt/pusnow/share/bash-completion/completions
RUN mkdir -p /opt/pusnow/share/man/man1
RUN cp ${GH_REPO}/target/tmp/bottom/completion/btm.bash /opt/pusnow/share/bash-completion/completions/btm
RUN cp ${GH_REPO}/target/tmp/bottom/manpage/btm.1 /opt/pusnow/share/man/man1/btm.1

FROM scratch
COPY --from=BUILD /opt /opt
