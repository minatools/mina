load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")  # buildifier: disable=load

all_content = """filegroup(name = "all", srcs = glob(["**"]), visibility = ["//visibility:public"])"""

def librocksdb_fetch_repos():

    maybe(
        http_archive,
        name = "rocksdb",
        urls = [
            # latest:
            # "https://github.com/facebook/rocksdb/archive/v6.14.5.zip",

            # "https://github.com/facebook/rocksdb/archive/v6.0.1.zip"
            # "https://github.com/facebook/rocksdb/archive/v5.18.4.zip"

            "https://github.com/facebook/rocksdb/archive/v5.17.2.zip"
        ],
        # strip_prefix = "rocksdb-6.14.5",
        # sha256 = "14d06aad5e1edcd6160b94cd2dd25dc1f9954755d330a72f7c9225e177a10189",

        # strip_prefix = "rocksdb-6.0.1",
        # sha256 = "d2d0f7e5975a5c8e8ff265020191c3b48100226271d3dc6748b467726105b114",

        # strip_prefix = "rocksdb-5.18.4",
        # sha256 = "101fa4fa2aa5248f23b82586bfa9c916828a40ee61841b550eab86ca2198e143",

        strip_prefix = "rocksdb-5.17.2",
        sha256 = "269c266c1fc12d1e73682ed1a05296588e8482d188e6d56408a29de447ce87d7",

        build_file_content = "\n".join([
            "filegroup(name = \"all\",",
            "srcs = glob([\"**\"]),",
            "visibility = [\"//visibility:public\"])",
        ]),
        workspace_file_content = "workspace( name = \"mina_rocksdb\" )"
    )

    maybe(
        http_archive,
        name = "rocksdb-bzip2", # namespaced to avoid clashes with other repos
        url = "https://www.sourceware.org/pub/bzip2/bzip2-latest.tar.gz",
        type = "gz",
        sha256 = "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269",
        strip_prefix = "bzip2-1.0.8",
        build_file_content = all_content
    )

    maybe(
        http_archive,
        name = "rocksdb-zlib",  # namespaced to avoid clashes with other repos
        url = "https://zlib.net/zlib-1.2.11.tar.gz",
        sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        strip_prefix = "zlib-1.2.11",
        build_file_content = all_content,
    )
