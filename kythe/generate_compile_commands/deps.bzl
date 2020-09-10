"""Dependencies for generating compilation database using kythe"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def load_kythe_deps():
    http_archive(
        name = "com_github_tencent_rapidjson",
        build_file = "//kythe/generate_compile_commands:rapidjson.BUILD",
        sha256 = "8e00c38829d6785a2dfb951bb87c6974fa07dfe488aa5b25deec4b8bc0f6a3ab",
        strip_prefix = "rapidjson-1.1.0",
        urls = [
            "https://github.com/Tencent/rapidjson/archive/v1.1.0.zip",
        ],
    )

    http_archive(
        name = "com_google_absl",
        sha256 = "f41868f7a938605c92936230081175d1eae87f6ea2c248f41077c8f88316f111",
        strip_prefix = "abseil-cpp-20200225.2",
        urls = [
            "https://github.com/abseil/abseil-cpp/archive/20200225.2.tar.gz",
        ],
    )
