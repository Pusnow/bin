FROM localhost/rust AS BUILD
ARG VERSION
ARG GH_REPO

RUN download-ghr.sh ${GH_REPO} ${VERSION}

ENV RUSTFLAGS='-C link-arg=-s'
ENV BTM_GENERATE="Y"
RUN . "$HOME/.cargo/env" && cargo install --path ${GH_REPO} --root /opt/pusnow
RUN mkdir -p /opt/pusnow/share/bash-completion/completions
RUN cp ${GH_REPO}/target/release/build/lsd-*/out/lsd.bash /opt/pusnow/share/bash-completion/completions/lsd
RUN apk add --no-cache pandoc
RUN mkdir -p /opt/pusnow/share/man/man1
RUN pandoc --standalone --to man ${GH_REPO}/doc/lsd.md -o /opt/pusnow/share/man/man1/lsd.1

FROM scratch
COPY --from=BUILD /opt /opt
