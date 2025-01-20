FROM localhost/base

RUN apk add --no-cache gcc g++ make autoconf gettext-tiny automake libtool readline readline-dev ninja-build
