licenses(["notice"])

py_library(
    name = "extra_actions_proto_py",
    srcs = ["extra_actions_base_pb2.py"],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "generate_compile_command",
    srcs = ["generate_compile_command.py"],
    deps = [":extra_actions_proto_py"],
)

action_listener(
    name = "generate_compile_commands_listener",
    extra_actions = [":generate_compile_commands_action"],
    mnemonics = ["CppCompile"],
    visibility = ["//visibility:public"],
)

extra_action(
    name = "generate_compile_commands_action",
    cmd = "$(location :generate_compile_command) $(EXTRA_ACTION_FILE)" +
          " $(output $(ACTION_ID)_compile_command)",
    out_templates = ["$(ACTION_ID)_compile_command"],
    tools = [":generate_compile_command"],
)
