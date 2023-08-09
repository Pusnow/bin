FROM localhost/rust AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV RUSTFLAGS='-C link-arg=-s'
RUN . "$HOME/.cargo/env" && cargo install --path ${GH_REPO} --root /opt/pusnow
RUN mkdir -p /opt/pusnow/share/bash-completion/completions
RUN mkdir -p /opt/pusnow/share/man/man1
RUN cp ${GH_REPO}/target/release/build/bat-*/out/assets/completions/bat.bash /opt/pusnow/share/bash-completion/completions/bat
RUN cp ${GH_REPO}/target/release/build/bat-*/out/assets/manual/bat.1 /opt/pusnow/share/man/man1/bat.1

FROM scratch
COPY --from=BUILD /opt /opt
