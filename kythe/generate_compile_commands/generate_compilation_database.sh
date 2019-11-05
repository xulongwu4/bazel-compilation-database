#!/usr/bin/env bash

# Generates a compile_commands.json file at $(bazel info execution_root) for
# your Clang tooling needs.

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $(basename $0) BAZEL_TARGET"
    exit 1
fi

bazel build $@ \
  --experimental_action_listener=//kythe/generate_compile_commands:extract_json \
  --noshow_progress \
  --noshow_loading_progress \
  #$@ > /dev/null

pushd $(bazel info execution_root) > /dev/null
echo "[" > compile_commands.json
COUNT=0
find . -name '*.compile_command.json' -print0 | while read -r -d '' fname; do
  if ((COUNT++)); then
    echo ',' >> compile_commands.json
  fi
  cat "$fname" >> compile_commands.json
done
echo "]" >> compile_commands.json

jq . compile_commands.json > formatted_compile_commands.json && mv formatted_compile_commands.json compile_commands.json
cp compile_commands.json $(bazel info workspace)
popd > /dev/null
