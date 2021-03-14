# CONFIG_MLH = ["//mina/config"]

CONFIG_MLH = select({
    "//:profile_debug": ["//src/config/debug"],
    "//:profile_dev": ["//src:dev"],
    "//:profile_release": ["//src:release"],
}, no_match_error = "Unknown profile")

