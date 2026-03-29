load("@protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@rules_cc//cc:extensions.bzl", "compatibility_proxy_repo")
load("@rules_shell//shell:repositories.bzl", "rules_shell_dependencies", "rules_shell_toolchains")

def setup_cdb_generator():
    compatibility_proxy_repo()
    # protobuf_deps()
    # rules_shell_dependencies()
    # rules_shell_toolchains()
