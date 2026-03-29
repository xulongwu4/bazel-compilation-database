"""Dependencies for generating compilation database"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def download_transitive_dependencies():
    maybe(
        http_archive,
        name = "protobuf",
        sha256 = "ccff8964efdc4052f0b3579ad503dba28729c28fb0cf4245c060ec17667666aa",
        strip_prefix = "protobuf-3.29.5",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v3.29.5.tar.gz",
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
