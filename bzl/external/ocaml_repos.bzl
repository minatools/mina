load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")  # buildifier: disable=load

########################
def ocaml_fetch_libs():

    ## remote, not embedded
    maybe(
        git_repository,
        name = "ocaml_jemalloc",
        remote = "https://github.com/obazl/ocaml-jemalloc",
        branch = "bazel"
        ## TODO:
        # remote = "https://github.com/o1-labs/jemalloc",
        # branch = "master"
    )

    ## remotes embedded as submodules using local_repository rules in WORKSPACE.bazel
    ## once embedded git submodules are eliminated, use these instead of local_repository
    # maybe(
    #     git_repository,
    #     name = "graphql_ppx",
    #     remote = "https://github.com/obazl/graphql_ppx",
    #     branch = "bazel"
    # )

    # maybe(
    #     git_repository,
    #     name = "ppx_optcomp",
    #     remote = "https://github.com/obazl/ppx_optcomp",
    #     branch = "bzl/mina-sync"
    # )

    # maybe(
    #     git_repository,
    #     name = "ppx_version",
    #     remote = "https://github.com/o1-labs/ppx_version",
    #     branch = "master"
    # )

    # native.local_repository( name = "snarky" , path = "src/lib/snarky")
    # maybe(
    #     git_repository,
    #     name = "snarky",
    #     remote = "https://github.com/o1-labs/snarky",
    #     branch = "master"
    # )

    ################################################################
    native.local_repository( name = "ocaml_rocksdb", path = "src/external/ocaml-rocksdb" )
    # maybe(
    #     git_repository,
    #     name = "ocaml_rocksdb",
    #     remote = "https://github.com/o1-labs/orocksdb",
    #     branch = "master"
    # )
    native.local_repository( name = "ocaml_sodium", path = "src/external/ocaml-sodium" )
    # maybe(
    #     git_repository,
    #     name = "ocaml_sodium",
    #     remote = "https://github.com/o1-labs/ocaml-sodium",
    #     branch = "master"
    # )

    # https://github.com/bkase/tablecloth

    ################################################################
    ## opam pinned, not  bazelized
    # maybe(
    #     git_repository,
    #     name = "async_kernel",
    #     remote = "https://github.com/obazl/async_kernel",
    #     branch = ""
    # )
    # maybe(
    #     git_repository,
    #     name = "coda_base58",
    #     remote = "https://github.com/o1-labs/coda_base58",
    #     branch = "master"
    # )
    # maybe(
    #     git_repository,
    #     name = "ocaml_extlib",
    #     remote = "https://github.com/obazl/ocaml-extlib",
    #     branch = ""
    # )
    # maybe(
    #     git_repository,
    #     name = "rpc_parallel",
    #     remote = "https://github.com/o1-labs/rpc_parallel",
    #     branch = ""
    # )
