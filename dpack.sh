#!/bin/bash
set -e

for IMG in $@; do
    podman image pull -q "ghcr.io/pusnow/bin-${IMG}:latest" &
done
wait

mkdir -p build

podman images --format="{{.ID}}" --sort=id ghcr.io/pusnow/bin-* >build/ids

wget -qO "ids-old.txt" "https://github.com/Pusnow/bin/releases/download/bin/ids-${ARCH}.txt" || true
if diff -q "ids-old.txt" "build/ids" &>/dev/null; then
    echo "Skipping upgrade..."
    exit 0
fi

for IMG in $@; do
    echo "FROM ghcr.io/pusnow/bin-${IMG}:latest AS ${IMG}" >>build/Dockerfile
done
echo "FROM alpine:latest" >>build/Dockerfile
for IMG in $@; do
    echo "COPY --from=${IMG} /opt /opt" >>build/Dockerfile
done

cd build

podman build --tag pack .
podman run -v $PWD:/build pack cp -r /opt/pusnow /build

cp ids pusnow/
cp ids ids-${ARCH}.txt
tar -cvf "linux-${ARCH}.tar" pusnow
zstd -19 -T4 "linux-${ARCH}.tar"
gzip "linux-${ARCH}.tar"
gh release upload bin "linux-${ARCH}.tar.gz" "linux-${ARCH}.tar.zst" "ids-${ARCH}.txt" --clobber