## once embedded git submodules are eliminated, use these instead of local_repository

# load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")  # buildifier: disable=load
# load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")  # buildifier: disable=load

# def rust_fetch_libs():

    # maybe(
    #     git_repository,
    #     name = "zexe",
    #     remote = "https://github.com/o1-labs/zexe",
    #     branch = "master",
    #     # tag    = use tag instead of branch once a release tag has been published
    # )

    # maybe(
    #     git_repository,
    #     name = "marlin",
    #     remote = "https://github.com/obazl/marlin",
    #     branch = "master",
    #     # tag    = use tag instead of branch once a release tag has been published
    # )
