#!/bin/bash
set -ex

IMAGE=$1
ARCH=$2

if [ -z "$IMAGE" ]; then
    echo "No image"
    exit 1
fi

if [ -z "$ARCH" ]; then
    ARCH=x86_64
fi

podman build -f base.dockerfile -t base helper

case $IMAGE in
aria2) VERSION=$(./helper/gh-latest.sh aria2 aria2) ;;
iperf) VERSION=$(./helper/gh-latest-tag.sh esnet iperf) ;;
sockperf) VERSION=$(./helper/gh-latest.sh Mellanox sockperf) ;;
zstd) VERSION=$(./helper/gh-latest.sh facebook zstd) ;;
*) VERSION="" ;;
esac

VERSION_ARGS=""
if [ -n "${VERSION}" ]; then
    VERSION_ARGS="--build-arg VERSION=${VERSION}"
fi

podman build -t $IMAGE ${VERSION_ARGS} - <bin/$IMAGE.dockerfile
