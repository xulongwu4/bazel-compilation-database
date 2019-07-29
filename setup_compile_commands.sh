#!/bin/bash
set -e

WORKSPACE=$(bazel info workspace)

force=0

if [ "$1" = "-f" ]; then
  force=1
fi

pushd $WORKSPACE > /dev/null

current_file=tools/BUILD
if [ "$force" -eq 1 ] || [ ! -f "$current_file" ]; then
    current_file_dir="$(dirname "$current_file")"

    mkdir -p "$current_file_dir"
    echo "Create $current_file" 1>&2
    more > "$current_file" <<'//MY_CODE_STREAM' 
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
//MY_CODE_STREAM
else 
echo "File $current_file already exists, aborted! (you can use -f to force overwrite)" 
exit 1
fi
current_file=tools/generate_compile_command.py
if [ "$force" -eq 1 ] || [ ! -f "$current_file" ]; then
    current_file_dir="$(dirname "$current_file")"

    mkdir -p "$current_file_dir"
    echo "Create $current_file" 1>&2
    more > "$current_file" <<'//MY_CODE_STREAM' 
# This is the implementation of a Bazel extra_action which generates
# _compile_command files for generate_compile_commands.py to consume.

import sys

import tools.extra_actions_base_pb2 as extra_actions_base_pb2

def _get_cpp_command(cpp_compile_info):
  compiler = cpp_compile_info.tool
  options = ' '.join(cpp_compile_info.compiler_option)
  source = cpp_compile_info.source_file
  return '%s %s' % (compiler, options), source

def main(argv):
  action = extra_actions_base_pb2.ExtraActionInfo()
  with open(argv[1], 'rb') as f:
    action.MergeFromString(f.read())
    command, source_file = _get_cpp_command(
      action.Extensions[extra_actions_base_pb2.CppCompileInfo.cpp_compile_info])
  with open(argv[2], 'w') as f:
    f.write(command)
    f.write('\0')
    f.write(source_file)

if __name__ == '__main__':
  sys.exit(main(sys.argv))
//MY_CODE_STREAM
else 
echo "File $current_file already exists, aborted! (you can use -f to force overwrite)" 
exit 1
fi
current_file=tools/generate_compile_commands_json.py
if [ "$force" -eq 1 ] || [ ! -f "$current_file" ]; then
    current_file_dir="$(dirname "$current_file")"

    mkdir -p "$current_file_dir"
    echo "Create $current_file" 1>&2
    more > "$current_file" <<'//MY_CODE_STREAM' 
#!/usr/bin/python3

# This reads the _compile_command files :generate_compile_commands_action
# generates a outputs a compile_commands.json file at the top of the source
# tree for things like clang-tidy to read.

# Overall usage directions: run Bazel with
# --experimental_action_listener=//tools:generate_compile_commands_listener
# for all the files you want to use clang-tidy with and then run this script.
# After that, `clang-tidy build_tests/gflags.cc` should work.

import sys
import pathlib
import os.path
import subprocess

'''
Args:
  path: The pathlib.Path to _compile_command file.
  command_directory: The directory commands are run from.
Returns a string to stick in compile_commands.json.
'''
def _get_command(path, command_directory):
  with path.open('r') as f:
    contents = f.read().split('\0')
    if len(contents) != 2:
      # Old/incomplete file or something; silently ignore it.
      return None
    return '''  {
    "directory": "%s",
    "command": "%s",
    "file": "%s"
  }''' % (command_directory, contents[0].replace('"', '\\"'), contents[1])

'''
Args:
  path: A directory pathlib.Path to look for _compile_command files under.
  command_directory: The directory commands are run from.
Yields strings to stick in compile_commands.json.
'''
def _get_compile_commands(path, command_directory):
  for f in path.iterdir():
    if f.is_dir():
      yield from _get_compile_commands(f, command_directory)
    elif f.name.endswith('_compile_command'):
      command = _get_command(f, command_directory)
      if command:
        yield command

def main(argv):
  source_path = subprocess.check_output(
    ('bazel', 'info', 'workspace')).decode('utf-8').rstrip()
  action_outs = os.path.join(source_path,
                             'bazel-bin/../extra_actions',
                             'tools/generate_compile_commands_action')
  command_directory = subprocess.check_output(
    ('bazel', 'info', 'execution_root'),
    cwd=source_path).decode('utf-8').rstrip()
  commands = _get_compile_commands(pathlib.Path(action_outs), command_directory)
  with open(os.path.join(source_path, 'compile_commands.json'), 'w') as f:
    f.write('[\n{}\n]\n'.format(',\n'.join(commands)))
    
if __name__ == '__main__':
  sys.exit(main(sys.argv))
//MY_CODE_STREAM
else 
echo "File $current_file already exists, aborted! (you can use -f to force overwrite)" 
exit 1
fi
current_file=tools/extra_actions_base.proto
if [ "$force" -eq 1 ] || [ ! -f "$current_file" ]; then
    current_file_dir="$(dirname "$current_file")"

    mkdir -p "$current_file_dir"
    echo "Create $current_file" 1>&2
    #wget https://github.com/bazelbuild/bazel/raw/master/src/main/protobuf/extra_actions_base.proto -O $current_file
    if hash curl 2>/dev/null; then
        curl -L https://github.com/bazelbuild/bazel/raw/master/src/main/protobuf/extra_actions_base.proto --output $current_file --silent
    else
        wget https://github.com/bazelbuild/bazel/raw/master/src/main/protobuf/extra_actions_base.proto -O $current_file --quiet
    fi
else 
echo "File $current_file already exists, aborted! (you can use -f to force overwrite)" 
exit 1
fi
echo "Generate extra_actions_base_pb2.py" 1>&2
protoc tools/extra_actions_base.proto --python_out=.

current_file=tools/generate_compilation_database.sh
if [ "$force" -eq 1 ] || [ ! -f "$current_file" ]; then
    current_file_dir="$(dirname "$current_file")"

    mkdir -p "$current_file_dir"
    echo "Create $current_file" 1>&2
    more > "$current_file" <<'//MY_CODE_STREAM' 
#!/bin/bash
set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $(basename $0) BAZEL_TARGET"
    exit 1
fi

bazel build \
    --experimental_action_listener=//tools:generate_compile_commands_listener \
    --noshow_progress \
    --noshow_loading_progress \
    $@ > /dev/null
python3 $(dirname $0)/generate_compile_commands_json.py
exit 0
//MY_CODE_STREAM
else 
echo "File $current_file already exists, aborted! (you can use -f to force overwrite)" 
exit 1
fi

popd > /dev/null

exit 0
