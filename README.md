# A set of tools to generate compilation databases for `bazel`-based projects

## Usage

> [!NOTE]
>
> It is highly recommended to have [`jq`](https://github.com/stedolan/jq)
> installed so that the generated `compile_commands.json` is formatted nicely.

Add the following lines to `MODULE.bazel`:

```bzl
bazel_dep(name = "bazel_compile_commands_generator", dev_dependency = True)
git_override(
    module_name = "bazel_compile_commands_generator",
    remote = "https://github.com/xulongwu4/bazel-compilation-database.git",
    branch = "main",
)
```

Copy the `generate_compile_commands/generate_compilation_database.sh` to the
workspace of your project.

Then one can generate `compile_commands.json` by running the following command
from the workspace of the project:

```sh
./generate_compilation_database.sh
```
