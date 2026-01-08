def _impl(repository_ctx):
    # repository.symlink(repository_ctx.path(Label("@//:WORKSPACE")).dirname + "/generate_compilation_database.sh", repository_ctx.path(Label("@//:WORKSPACE")).dirname + "/test")
    # repository.symlink(repository_ctx.path(Label("@//:MODULE.bazel")).dirname + "/generate_compilation_database.sh", repository_ctx.path(Label("@//:MODULE.bazel")).dirname + "/test")
    print(repository_ctx.path(Label("@//:MODULE.bazel")).dirname)

compile_commands_generator = repository_rule(
    implementation = _impl,
)
