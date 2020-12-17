#!/bin/sh

## Use github.com/obazl until all Bazel support has been merged into o1-labs/MinaProtocol.

O1LABS=https://github.com/obazl
MINA=https://github.com/obazl
BRANCH=bazel
SNARKY_BRANCH=bzl/bd10e9c
MINA_BRANCH=bzl/gold
ROCKS_BRANCH=mina

# O1LABS=https://github.com/o1-labs
# MINA=https://github.com/MinaProtocol
## Assumption: each repo has a mina branch whose HEAD is pinned by mina
# BRANCH=mina
# SNARKY_BRANCH=mina
# MINA_BRANCH=develop

# Assumption: we're running this from the PARENT of the mina root dir
cd mina && git checkout ${MINA_BRANCH}  && git pull && git submodule init && git submodule update --init --recursive && cd -;

####
git clone ${O1LABS}/graphql_ppx.git && cd graphql_ppx && git checkout ${BRANCH} && git pull && cd ..;

git clone ${O1LABS}/ppx_version.git && cd ppx_version && git checkout ${BRANCH} && git pull && cd -;

git clone ${O1LABS}/snarky.git && cd snarky && git checkout ${SNARKY_BRANCH} && git pull && cd -;

git clone ${O1LABS}/marlin.git && cd marlin && git checkout ${BRANCH} && git pull && cd -;

git clone ${O1LABS}/zexe.git && cd zexe && git checkout ${BRANCH} & git pull && cd -;

####
git clone ${MINA}/ppx_optcomp.git && cd ppx_optcomp && git checkout ${BRANCH} && git pull && cd ..;

git clone ${MINA}/async_kernel.git && cd async_kernel && git checkout ${BRANCH} && git pull && cd -;

git clone ${MINA}/rpc_parallel.git && cd rpc_parallel && git checkout ${BRANCH} && git pull && cd -;

git clone ${MINA}/ocaml-extlib.git && cd ocaml-extlib && git checkout ${BRANCH} && git pull && cd -;

## not yet migrated to o1labs/mina

git clone ${MINA}/ocaml-jemalloc.git && cd ocaml-jemalloc && git checkout ${BRANCH} && git pull && cd -;

git clone ${MINA}/orocksdb.git && cd orocksdb && git checkout ${ROCKS_BRANCH} && git pull && cd -;

git clone ${MINA}/ocaml-sodium.git && cd ocaml-sodium && git checkout ${BRANCH} && git pull && cd -;
