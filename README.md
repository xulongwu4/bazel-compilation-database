# A set of tools to generate compilation databases for `bazel`-based projects

## Usage

> [!NOTE]
>
> Use the `main` branch for newer versions of bazel that use the `MODULE.bazel`
> file

Add the following lines to the `WORKSPACE` file of the project:

```bzl
git_repository(
    name = "compile_commands_generator",
    branch = "workspace",
    remote = "https://github.com/xulongwu4/bazel-compilation-database.git"
)

load("@compile_commands_generator//bazel:download_transitive_dependencies.bzl", "download_transitive_dependencies")

download_transitive_dependencies()

load("@compile_commands_generator//bazel:setup_cdb_generator.bzl", "setup_cdb_generator")

setup_cdb_generator()
```

Then run the following command to generate the compilation database:

```bash
bazel run @compile_commands_generator//:generate_compilation_database
```
