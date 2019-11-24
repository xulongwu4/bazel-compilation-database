#!/bin/bash
set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $(basename $0) BAZEL_TARGET"
    exit 1
fi

bazel build \
    --experimental_action_listener=//tools:generate_compile_commands_listener \
    --nosandbox_debug \
    --noshow_progress \
    --noshow_loading_progress \
    $@ > /dev/null
python3 $(dirname $0)/generate_compile_commands_json.py
exit 0
