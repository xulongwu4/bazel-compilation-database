# Build file for tools integrating Bazel with clang tooling.

# Extracts a single compile command from an extra action.
sh_binary(
    name = "extract_compile_command_binary",
    srcs = ["extract_compile_command"],
)

action_listener(
    name = "extract_json",
    extra_actions = [":extra_action"],
    mnemonics = ["CppCompile"],
    visibility = ["//visibility:public"],
)

extra_action(
    name = "extra_action",
    cmd = "$(location :extract_compile_command_binary) \
        $(EXTRA_ACTION_FILE) \
        $(output $(ACTION_ID).compile_command.json)",
    out_templates = ["$(ACTION_ID).compile_command.json"],
    tools = [":extract_compile_command_binary"],
)
