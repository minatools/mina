opam = struct(
    opam_version = "2.0",
    packages = {
        "bigarray": ":ocaml", # ocamlfind: distributed with Ocaml
        "bytes": ":ocaml", # ocamlfind: distributed with OCaml 4.02 or above
        "core_kernel": "v0.12.3",
        "ctypes": "0.17.1",
        "ctypes.foreign": "0.4.0",
        "ctypes.stubs": "0.4.0",
        "ocaml-compiler-libs": "v0.11.0",
        "compiler-libs.common": "v0.11.0",
        "ounit2": "2.2.3",
    }
)
