# Build file for tools integrating Bazel with clang tooling.

# load("@bazel_tools//tools/build_defs/shell:sh_binary.bzl", "sh_binary")
# load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_proto_library")

# load("@rules_proto//proto:defs.bzl", "cc_proto_library", "proto_library")
# load("@rules_sh//sh:sh_binary.bzl", "sh_binary")

# load("@protobuf//bazel:cc_proto_library.bzl", "cc_proto_library")

proto_library(
    name = "extra_actions_base_proto",
    srcs = ["extra_actions_base.proto"],
)

cc_proto_library(
    name = "extra_actions_base_cc_proto",
    deps = [":extra_actions_base_proto"],
)

cc_binary(
    name = "extract_compile_command",
    srcs = ["extract_compile_command.cc"],
    deps = [
        ":extra_actions_base_cc_proto",
        "@protobuf",
        "@rapidjson",
    ],
)

action_listener(
    name = "extract_json",
    extra_actions = [":extra_action"],
    mnemonics = ["CppCompile"],
    visibility = ["//visibility:public"],
)

extra_action(
    name = "extra_action",
    cmd = "$(location :extract_compile_command) \
        $(EXTRA_ACTION_FILE) \
        $(output $(ACTION_ID).compile_command.json)",
    out_templates = ["$(ACTION_ID).compile_command.json"],
    tools = [":extract_compile_command"],
)

sh_binary(
    name = "generate_compilation_database",
    srcs = ["generate_compilation_database.sh"],
)
