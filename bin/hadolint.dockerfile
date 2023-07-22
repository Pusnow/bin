FROM base AS BUILD
ARG VERSION
ARG GH_REPO
ARG VERSION_ARCH

RUN wget -O hadolint "https://github.com/${GH_REPO}/releases/download/${VERSION}/hadolint-Linux-${VERSION_ARCH}" && chmod +x hadolint
RUN mkdir -p /opt/pusnow/bin && mv hadolint /opt/pusnow/bin

FROM scratch
COPY --from=BUILD /opt /opt
