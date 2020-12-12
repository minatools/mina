#!/bin/sh

sudo apt-get update
sudo apt-get install --yes \
     pkg-config  \
     libgmp-dev  \ ## required by zarith (libgmp3-dev?)
     libffi-dev  \ ## required by ctypes-foreign, used by orocksdb
     libssl-dev  \ ## required by async_ssl
     libpq-dev     ## required by postgresql, caqti-driver-postgresql


# OPAM:
# * build-essential
# * autoconf
# * m4
# * unzip
# * bubblewrap
# * patchelf?

# For bazel:
# * git
# * curl
# * gnupg
