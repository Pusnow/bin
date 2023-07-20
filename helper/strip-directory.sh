#!/bin/sh
NE=$(find "${1}" -maxdepth 1 -mindepth 1 | wc -l | xargs || true)
ND=$(find "${1}" -maxdepth 1 -mindepth 1 -type d | wc -l | xargs || true)

if [[ "${NE}" == "1" ]] && [[ "${ND}" == "1" ]]; then
    DIR=$(find "${1}" -maxdepth 1 -mindepth 1)
    mv "${DIR}/"* "${1}"
    rm -r "${DIR}"
fi
