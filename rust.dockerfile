FROM localhost/base

RUN apk add --no-cache rustup gcc libgcc musl-dev make lld && rustup-init -q -y
