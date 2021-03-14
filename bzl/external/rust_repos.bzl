load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")  # buildifier: disable=load

def rust_fetch_libs():

    ## commit ids should match submodule pins
    minatools = struct(
        zexe = struct(
            commitid = "f317d3e5f7edc7cd3630baf08fe0de459ef9374a",
            sha256   = "843794aff7822840d7d3976e5ee681b5dd0890f13ce4d734fac8fdc35707c16e"
        ),
        marlin = struct(
            commitid = "0096f8d15582d363d7de420274f1b911be6831c4",
            sha256   = "8a520b330c26c3fda68269e9d6686b1bc49f745d7ae272cbcb69bf464bf5986e"
        )
    )
    # o1labs = struct(
    #     commitid = "...",  # prod (o1-labs)
    #     sha256   = ""  # proc
    # )

    maybe(
        http_archive,
        name         = "marlin",
        sha256       = minatools.marlin.sha256,
        strip_prefix = "marlin-" + minatools.marlin.commitid,
        urls = [
            ## dev:
            "https://github.com/minatools/marlin/archive/" + minatools.marlin.commitid + ".tar.gz"

            ## prod:
            ## "https://github.com/o1-labs/marlin",
        ],
    )

    maybe(
        http_archive,
        name         = "zexe",
        sha256       = minatools.zexe.sha256,
        strip_prefix = "zexe-" + minatools.zexe.commitid,
        urls = [
            ## dev:
            "https://github.com/minatools/zexe/archive/" + minatools.zexe.commitid + ".tar.gz"

            ## prod:
            ## "https://github.com/o1-labs/zexe",
        ],
    )
