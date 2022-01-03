#!/bin/bash
VERSION=2.0.10

URL="https://github.com/zyedidia/micro/releases/download/v${VERSION}/micro-${VERSION}-linux64-static.tar.gz"
rm -rf out tmp
mkdir -p out tmp
wget -O tmp/micro.tar.gz $URL
tar -xvzf tmp/micro.tar.gz -C tmp --strip-components=1
mv tmp/micro out/micro
