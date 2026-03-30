"""Dependencies for generating compilation database"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def download_transitive_dependencies():
    maybe(
        http_archive,
        name = "rules_cc",
        sha256 = "8dcd63392f0bb48adf74f413a9f39ba0fedcb8f99bf085a3b450f06d171dbb6d",
        strip_prefix = "rules_cc-0.2.4",
        url = "https://github.com/bazelbuild/rules_cc/releases/download/0.2.4/rules_cc-0.2.4.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "3709d1745ba4be4ef054449647b62e424267066eca887bb00dd29242cb8463a0",
        strip_prefix = "rules_shell-0.7.1",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.7.1/rules_shell-v0.7.1.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "2ef40fdcd797e07f0b6abda446d1d84e2d9570d234fddf8fcd2aa262da852d1c",
        strip_prefix = "rules_python-1.2.0",
        url = "https://github.com/bazelbuild/rules_python/releases/download/1.2.0/rules_python-1.2.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "protobuf",
        sha256 = "136a07aad488cc502b11c4416fe4a7df2dfdea1d0833a7a8211000bf952728ba",
        strip_prefix = "protobuf-33.4",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v33.4.tar.gz",
    )

    maybe(
        http_archive,
        name = "com_github_tencent_rapidjson",
        build_file = "@compile_commands_generator//bazel:rapidjson.BUILD",
        sha256 = "8e00c38829d6785a2dfb951bb87c6974fa07dfe488aa5b25deec4b8bc0f6a3ab",
        strip_prefix = "rapidjson-1.1.0",
        urls = [
            "https://github.com/Tencent/rapidjson/archive/v1.1.0.zip",
        ],
    )
