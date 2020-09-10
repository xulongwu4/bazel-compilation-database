# A set of tools to generate compilation databases for `bazel`-based projects

## Usage

Copy (or symlink) the kythe directory to the workspace of your project. Then add
the following lines to the `WORKSPACE` file:

```bzl
load("//kythe/generate_compile_commands:deps.bzl", "load_kythe_deps")

load_kythe_deps()
```

One can generate the compilation database by using the following command in
the workspace directory:

```bash
kythe/generate_compile_commands/generate_compilation_database.sh
```
