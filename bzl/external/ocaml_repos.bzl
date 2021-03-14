load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")  # buildifier: disable=load

#######################
def ocaml_fetch_local_libs():

    native.local_repository( name = "graphql_ppx"  , path = "src/external/graphql_ppx")
    native.local_repository( name = "ppx_optcomp"  , path = "src/external/ppx_optcomp")
    native.local_repository( name = "ppx_version"  , path = "src/external/ppx_version")
    native.local_repository( name = "snarky"       , path = "src/lib/snarky")

    ## the next two are not currently submodules, just embedded w/o bazel support.
    ## for the bazel build we fetch remotes, see below, ocaml_fetch_ffi_libs().
    # native.local_repository( name = "ocaml_rocksdb", path = "src/external/ocaml-rocksdb" )
    # native.local_repository( name = "ocaml_sodium" , path = "src/external/ocaml-sodium" )

    ## opam-pinned embedded (non-remoted) repos.
    ## we do not need them as bazel repos, since opam builds them as part of the pinning process.
    # local_repository( name = "async_kernel" , path = "src/external/async_kernel")
    # local_repository( name = "ocaml_extlib" , path = "src/external/ocaml_extlib")
    # local_repository( name = "rpc_parallel" , path = "src/external/rpc_parallel")

    # https://github.com/bkase/tablecloth
    # local_repository( name = "tablecloth" , path = "frontend/wallet/tablecloth")

########################
def ocaml_fetch_remote_libs():
    ## these are also submodules, fetchable by ocaml_fetch_local_libs (above)

    maybe(
        http_archive,
        name   = "graphql_ppx",
        sha256 = "2ae9316f6f22d7c3a6262f6ff0799abf83e7042fa2bf972ab577299392b8d0eb",
        strip_prefix = "graphql_ppx-2278ab4b23f162576ede96ff3a22ecaf8c5e004a",
        urls = [
            "https://github.com/minatools/graphql_ppx/archive/2278ab4b23f162576ede96ff3a22ecaf8c5e004a.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "ppx_optcomp",
        sha256 = "1fe5d2830200938e17b6adfa388d38a1f4eb2a9d3860a9dcc8dbed9e41e2478d",
        strip_prefix = "ppx_optcomp-0a51daef09aee7b10d997c112d6e97fe4a2e9ccc",
        urls = [
            "https://github.com/minatools/ppx_optcomp/archive/0a51daef09aee7b10d997c112d6e97fe4a2e9ccc.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "ppx_version",
        sha256 = "e71db52fac94e97e2766f47c78be7cdb1efbcf69088a4be75aac329422ee10e7",
        strip_prefix = "ppx_version-e6112930056a873b8b3b965b64fd47a27a1bc20f",
        urls = [
            "https://github.com/minatools/ppx_version/archive/e6112930056a873b8b3b965b64fd47a27a1bc20f.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "snarky",
        # sha256 = "59d497049abef12597150a0e480e81983c9a8d7fe029cae5398f11ab0ed4d527",
        strip_prefix = "snarky-91f90da5bad15f9c4084770fd3ac0dafa7675e5f",
        urls = [
            "https://github.com/minatools/snarky/archive/91f90da5bad15f9c4084770fd3ac0dafa7675e5f.tar.gz"
        ],
    )

    ################################################################
    ## opam pinned.  these are bazelized but the bazel code is not used
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

################################################################
def ocaml_fetch_ffi_libs():

    maybe(
        http_archive,
        name   = "ocaml_jemalloc",
        sha256 = "06d2790befdf678eb0b0211b97dd6aa01cf64514c839e4ab1318680b50940d27",
        strip_prefix = "ocaml-jemalloc-459423d165c8a48b42f1ad372c8fe81eb9a98da9",
        urls = [
            "https://github.com/obazl/ocaml-jemalloc/archive/459423d165c8a48b42f1ad372c8fe81eb9a98da9.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "ocaml_rocksdb",
        sha256 = "8cb32f16613bd8821c97f0a31a4e584a932647fcf35d2203121c7ec1a9489d45",
        strip_prefix = "orocksdb-503f9fdd0de2e7b0acb8297951d797633be05ae4",
        urls = [
            "https://github.com/minatools/orocksdb/archive/503f9fdd0de2e7b0acb8297951d797633be05ae4.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "ocaml_sodium",
        sha256 = "14f7ac299e5f9d0d483ebcbde316cebb240d355a575b39c70322f39f6005f512",
        strip_prefix = "ocaml-sodium-8f57006e673c19f512600c1bdda6fe048f887cfa",
        urls = [
            "https://github.com/minatools/ocaml-sodium/archive/8f57006e673c19f512600c1bdda6fe048f887cfa.tar.gz"
        ],
    )

#######################
def ocaml_fetch_libs():

    # for these bazel always uses downloaded repos, not the embedded ones in src/external:
    ocaml_fetch_ffi_libs()

    ## either local (embedded submodules) or remote
    ocaml_fetch_local_libs()
    # ocaml_fetch_remote_libs()
