load("@protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@rules_shell//shell:repositories.bzl", "rules_shell_dependencies", "rules_shell_toolchains")

def setup_cdb_generator():
    rules_shell_dependencies()
    rules_shell_toolchains()
    protobuf_deps()
