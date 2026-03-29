# A set of tools to generate compilation databases for `bazel`-based projects

## Usage

Add the following lines to the `MODULE.bazel` file of the project:

```bzl
bazel_dep(name = "compile_commands_generator", dev_dependency = True)
git_override(
    module_name = "compile_commands_generator",
    branch = "lo/bazel-repo-MODULE",
    remote = "https://github.com/xulongwu4/bazel-compilation-database.git",
)
```

Then run the following command to generate the compilation database:

```bash
bazel run @compile_commands_generator//:generate_compilation_database
```
