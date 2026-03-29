# Build file for tools integrating Bazel with clang tooling.

# Tested with bazel 6.4.0

load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

sh_binary(
    name = "generate_compilation_database",
    srcs = ["generate_compilation_database.sh"],
)
