# A set of tools to generate compilation databases for `bazel`-based projects

## Usage

### Approach 1: `cpp`-based method

Copy (or symlink) the `kythe` directory to the workspace of your project. Then add
the following lines to the `WORKSPACE` file:

```bzl
load("//kythe/generate_compile_commands:deps.bzl", "load_kythe_deps")

load_kythe_deps()
```

One can generate the compilation database by using the following command in
the workspace directory:

```sh
kythe/generate_compile_commands/generate_compilation_database.sh
```

It is highly recommended to have [`jq`](https://github.com/stedolan/jq) installed
so that the generated `compile_commands.json` is formatted nicely.

### Approach 2: `python`-based method

Copy (or symlink) the `tools` directory to the workspace of your project. Then
run the python script `tools/generate_compilation_database.sh` in the workspace
directory to generate the compilation database:

```sh
tools/generate_compilation_database.sh ...
```
