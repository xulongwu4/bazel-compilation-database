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

'''
Args:
  path: A directory pathlib.Path to look for _compile_command files under.
  command_directory: The directory commands are run from.
Yields strings to stick in compile_commands.json.
'''


def _get_compile_commands(path):
    for f in path.iterdir():
        if f.is_dir():
            yield from _get_compile_commands(f)
        elif f.name.endswith('.compile_command.json'):
            with f.open('r') as db:
                command = db.read()
                if command:
                    yield command


def main(argv):
    source_path = argv[1]
    action_outs = argv[2]
    if not action_outs.startswith("/"):
        action_outs = os.path.join(source_path, action_outs)
    commands = _get_compile_commands(
        pathlib.Path(action_outs))
    with open(os.path.join(source_path, 'compile_commands.json'), 'w') as f:
        f.write('[\n{}\n]\n'.format(',\n'.join(commands)))


if __name__ == '__main__':
    sys.exit(main(sys.argv))
