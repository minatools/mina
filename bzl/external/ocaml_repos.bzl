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
        sha256 = "58d948dc83485786f3b314f48e2e76a121edbd286e33441f8bbbeda19c798e38",
        strip_prefix = "ppx_optcomp-fc23edf814f39ce91e6c474634f055dec37c1dde",
        urls = [
            "https://github.com/minatools/ppx_optcomp/archive/fc23edf814f39ce91e6c474634f055dec37c1dde.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "ppx_version",
        sha256 = "d3743227218257faf831c6a594345a24aa70550e6efb8a3369197ccd155c9b9e",
        strip_prefix = "ppx_version-dc0d05d92a783644b5e136acb6960dcbd0cee104",
        urls = [
            "https://github.com/minatools/ppx_version/archive/dc0d05d92a783644b5e136acb6960dcbd0cee104.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "snarky",
        sha256 = "304c38e50bd5f793e2092843a50b1e88587c5246f0ce3a23bf087c3d503d489a",
        strip_prefix = "snarky-af96fa4d4b3c2c86ea2b9b1c9c2e9858c610e683",
        urls = [
            "https://github.com/minatools/snarky/archive/af96fa4d4b3c2c86ea2b9b1c9c2e9858c610e683.tar.gz"
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
        sha256 = "92d8406c47b6d1758bba6a364f6916f7ed2a2579a4839225e3f9888cb39ae2f4",
        strip_prefix = "ocaml-jemalloc-67d68baf7dca48e46eaf151fccb2403133ba04b2",
        urls = [
            # branch: bazel
            "https://github.com/obazl/ocaml-jemalloc/archive/67d68baf7dca48e46eaf151fccb2403133ba04b2.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "ocaml_rocksdb",
        sha256 = "50d50d9399af62b1c39b9195f566f4b786973da092a295306cd4dcf0f50e2654",
        strip_prefix = "orocksdb-1af6ff6675fc42a11da6f96736a6fe2de3fb94d0",
        urls = [
            # branch: mina
            "https://github.com/minatools/orocksdb/archive/1af6ff6675fc42a11da6f96736a6fe2de3fb94d0.tar.gz"
        ],
    )

    maybe(
        http_archive,
        name   = "ocaml_sodium",
        sha256 = "3748684e3aee5539755e2d297e2e08f6c51bd422487826cb9ad62dfb3168ec2d",
        strip_prefix = "ocaml-sodium-dc296f289d19284ed1e6586cd23b6c094f7a28c1",
        urls = [
            # branch: mina
            "https://github.com/minatools/ocaml-sodium/archive/dc296f289d19284ed1e6586cd23b6c094f7a28c1.tar.gz"
        ],
    )

#######################
def ocaml_fetch_libs():

    # for these bazel always uses downloaded repos, not the embedded ones in src/external:
    ocaml_fetch_ffi_libs()

    ## either local (embedded submodules) or remote
    ocaml_fetch_local_libs()
    # ocaml_fetch_remote_libs()
