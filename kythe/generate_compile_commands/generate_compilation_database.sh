#!/usr/bin/env bash

# Generates a compile_commands.json file at $(bazel info execution_root) for
# your Clang tooling needs.

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $(basename $0) BAZEL_TARGET"
    exit 1
fi

bazel build \
  --experimental_action_listener=//kythe/generate_compile_commands:extract_json \
  --nosandbox_debug \
  --noshow_progress \
  --noshow_loading_progress \
  $@ > /dev/null

WORKSPACE=$(bazel info workspace)
OUTFILE=$WORKSPACE/compile_commands.json
TMPFILE=$(mktemp)
bazel aquery \
  --experimental_action_listener=//kythe/generate_compile_commands:extract_json \
  --nosandbox_debug \
  --noshow_progress \
  --noshow_loading_progress \
  $@ 2> /dev/null | rg Outputs | rg /bin/ > $TMPFILE
KYTHE_WORKSPACE=$(head -n 1 $TMPFILE | cut -f 2 -d: | sed 's/[][]//g' | awk '{$1=$1};1')
KYTHE_WORKSPACE=$WORKSPACE/${KYTHE_WORKSPACE%/bin/*}/extra_actions/kythe/generate_compile_commands

pushd $KYTHE_WORKSPACE > /dev/null
echo "[" > $OUTFILE
COUNT=0
find . -name '*.compile_command.json' -print0 | while read -r -d '' fname; do
  if ((COUNT++)); then
    echo ',' >> $OUTFILE
  fi
  cat "$fname" >> $OUTFILE
done
echo "]" >> $OUTFILE
popd > /dev/null

jq . $OUTFILE > $TMPFILE && mv $TMPFILE $OUTFILE
