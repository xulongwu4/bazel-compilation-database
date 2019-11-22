#!/usr/bin/env bash

# Generates a compile_commands.json file at $(bazel info execution_root) for
# your Clang tooling needs.

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $(basename $0) BAZEL_TARGET"
    exit 1
fi

WORKSPACE=$(bazel info workspace)
TMPFILE=$(mktemp)
bazel aquery $@ 2> /dev/null | rg Outputs | rg /bin/ > $TMPFILE
KYTHE_WORKSPACE=$(head -n 1 $TMPFILE | cut -f 2 -d: | sed 's/[][]//g' | awk '{$1=$1};1')
KYTHE_WORKSPACE=$WORKSPACE/${KYTHE_WORKSPACE%/bin/*}/extra_actions/kythe/generate_compile_commands
rm -rf $TMPFILE

bazel build \
  --experimental_action_listener=//kythe/generate_compile_commands:extract_json \
  --noshow_progress \
  --noshow_loading_progress \
  $@ > /dev/null

echo $KYTHE_WORKSPACE
pushd $KYTHE_WORKSPACE > /dev/null
echo "[" > $WORKSPACE/compile_commands.json
COUNT=0
find . -name '*.compile_command.json' -print0 | while read -r -d '' fname; do
  if ((COUNT++)); then
    echo ',' >> compile_commands.json
  fi
  cat "$fname" >> compile_commands.json
done
echo "]" >> $WORKSPACE/compile_commands.json
popd > /dev/null

pushd $WORKSPACE > /dev/null
jq . compile_commands.json > formatted_compile_commands.json && mv formatted_compile_commands.json compile_commands.json
popd > /dev/null
