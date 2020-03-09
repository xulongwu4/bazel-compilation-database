#!/usr/bin/env bash

# Generates a compile_commands.json file at $(bazel info execution_root) for
# your Clang tooling needs.

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $(basename $0) BAZEL_TARGET"
    exit 1
fi

bazel build \
  --color=yes \
  --experimental_action_listener=//kythe/generate_compile_commands:extract_json \
  --nosandbox_debug \
  --noshow_progress \
  --noshow_loading_progress \
  $@ > /dev/null

WORKSPACE=$(bazel info workspace 2>/dev/null)
OUTFILE=$WORKSPACE/compile_commands.json
KYTHE_WORKSPACE=$(bazel info bazel-bin 2>/dev/null)/../extra_actions/kythe/generate_compile_commands

echo "[" > $OUTFILE
find $KYTHE_WORKSPACE -name '*.compile_command.json' -exec cat {} \+ >> $OUTFILE
sed -i "s/@BAZEL_ROOT@/$BAZEL_ROOT/g" $OUTFILE
sed -i "s/}/},\n/g" $OUTFILE
sed -i "$ s/},/}/g" $OUTFILE
echo "]" >> $OUTFILE
jq . $OUTFILE > $WORKSPACE/formatted.json && mv $WORKSPACE/formatted.json $OUTFILE
