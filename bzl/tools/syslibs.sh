#!/bin/sh

sudo apt-get update
sudo apt-get install --yes \
     pkg-config  \
     libgmp-dev  \
     libffi-dev  \
     libssl-dev  \
     libpq-dev

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
