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

WORKSPACE=$(bazel info workspace)
OUTFILE=$WORKSPACE/compile_commands.json
KYTHE_WORKSPACE=$(bazel aquery \
  --experimental_action_listener=//kythe/generate_compile_commands:extract_json \
  --nosandbox_debug \
  $@ 2> /dev/null \
  | rg Outputs | rg /bin/ | tail -1 \
  | cut -f 2 -d: | sed 's/[][]//g' | awk '{$1=$1};1')
KYTHE_WORKSPACE=$WORKSPACE/${KYTHE_WORKSPACE%/bin/*}/extra_actions/kythe/generate_compile_commands

pushd $KYTHE_WORKSPACE > /dev/null
echo "[" > $OUTFILE
fd -g '*.compile_command.json' -x sed -e '$s/$/,/'>> $OUTFILE
sed -i '$s/,$//' $OUTFILE
echo "]" >> $OUTFILE

jq . $OUTFILE > formatted.json && mv formatted.json $OUTFILE
popd > /dev/null
