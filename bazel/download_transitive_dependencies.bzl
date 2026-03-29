"""Dependencies for generating compilation database"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def download_transitive_dependencies():
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "3709d1745ba4be4ef054449647b62e424267066eca887bb00dd29242cb8463a0",
        strip_prefix = "rules_shell-0.7.1",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.7.1/rules_shell-v0.7.1.tar.gz",
    )

    maybe(
        http_archive,
        name = "protobuf",
        sha256 = "9c0fd39c7a08dff543c643f0f4baf081988129a411b977a07c46221793605638",
        strip_prefix = "protobuf-3.20.3",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.20.3.tar.gz",
    )

    maybe(
        http_archive,
        name = "rapidjson",
        build_file = "@compile_commands_generator//bazel:rapidjson.BUILD",
        sha256 = "8e00c38829d6785a2dfb951bb87c6974fa07dfe488aa5b25deec4b8bc0f6a3ab",
        strip_prefix = "rapidjson-1.1.0",
        urls = [
            "https://github.com/Tencent/rapidjson/archive/v1.1.0.zip",
        ],
    )
