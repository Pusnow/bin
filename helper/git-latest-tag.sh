#!/bin/sh
TMPDIR=$(mktemp -d)
git clone "$1" "${TMPDIR}"
git -C "${TMPDIR}" describe --tags $(git -C "${TMPDIR}" rev-list --tags --max-count=1)
rm -rf "${TMPDIR}"
