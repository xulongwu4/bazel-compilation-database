load("@bazel_features//:deps.bzl", "bazel_features_deps")
load("@protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@rules_cc//cc:extensions.bzl", "compatibility_proxy_repo")
load("@rules_shell//shell:repositories.bzl", "rules_shell_dependencies", "rules_shell_toolchains")

def setup_cdb_generator():
    bazel_features_deps()
    rules_shell_dependencies()
    rules_shell_toolchains()
    protobuf_deps()
    compatibility_proxy_repo()
