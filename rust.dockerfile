FROM localhost/base

RUN apk add --no-cache rustup gcc libgcc musl-dev make && rustup-init -q -y
