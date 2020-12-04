#!/bin/sh

bazel query "kind(\".*_archive rule\", $1//...:*)" --output label_kind
