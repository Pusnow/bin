#!/bin/sh
git clone --recursive -b "${2}" --depth 1 "${3}" "${1}"
