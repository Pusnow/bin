FROM localhost/rust AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV RUSTFLAGS='-C link-arg=-s'
RUN . "$HOME/.cargo/env" && cargo install --path ${GH_REPO} --root /opt/pusnow
RUN mkdir -p /opt/pusnow/share/bash-completion/completions
RUN cp ${GH_REPO}/target/release/build/hyperfine-*/out/hyperfine.bash /opt/pusnow/share/bash-completion/completions/hyperfine

FROM scratch
COPY --from=BUILD /opt /opt
