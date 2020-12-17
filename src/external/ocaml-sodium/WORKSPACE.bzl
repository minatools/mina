load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")  # buildifier: disable=load
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")  # buildifier: disable=load

## WARNING: the makefile changed, for now we can only do 1.0.18-RELEASE
versions = {
    "1.0.18-RELEASE": struct(
        sha256 = "7728976ead51b0de60bede2421cd2a455c2bff3f1bc0320a1d61e240e693bce9",
        url    =    "https://github.com/jedisct1/libsodium/archive/1.0.18-RELEASE.zip",
        commit = "940ef42797baa0278df6b7fd9e67c7590f87744b"
    ),
    # "1.0.17": struct(
    #     commit = "b732443c442239c2e0184820e9b23cca0de0828c",
    #     url    =  "https://github.com/jedisct1/libsodium/archive/1.0.17.zip",
    #     sha256 = "a1734796725f9a2b5ca0316ace3ea0c02f3b239c4e61009ceb672a8d7de18465"
    # )
}

def libsodium_fetch_repo(version):

    maybe(
        http_archive,
        name="libsodium",
        # url="https://github.com/jedisct1/libsodium/archive/1.0.18-RELEASE.zip",
        # type="zip",
        # sha256="7728976ead51b0de60bede2421cd2a455c2bff3f1bc0320a1d61e240e693bce9",
        # strip_prefix = "libsodium-1.0.18-RELEASE",
        url=versions[version].url,
        sha256=versions[version].sha256,
        strip_prefix = "libsodium-" + version,
        build_file_content = "\n".join([
            "filegroup(name = \"all\",",
            "srcs = glob([\"**\"]),",
            "visibility = [\"//visibility:public\"])",
        ]),
    )
