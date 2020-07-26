#!/usr/bin/env bash

# Generates a compile_commands.json file at $(bazel info execution_root) for
# your Clang tooling needs.

printError() {
    printf '\e[1;31mERROR:\e[0m %s\n' "$@"
}

printInfo() {
    printf '\e[1;32mINFO:\e[0m %s\n' "$@"
}

err_exit() {
    local EXIT_STATUS=$?
    printError "See log file at $LOG_FILE"
    exit $EXIT_STATUS
}

trap err_exit ERR

LOG_FILE=$(mktemp)

printInfo "Log file: $LOG_FILE"

printInfo "Fetching workspace info ..."

WORKSPACE=$(bazel info workspace 2>"$LOG_FILE")
KYTHE_WORKSPACE=$(bazel info bazel-bin 2>>"$LOG_FILE")/../extra_actions/kythe/generate_compile_commands
BAZEL_ROOT=$(bazel info execution_root 2>>"$LOG_FILE")

[ -d "$KYTHE_WORKSPACE" ] && find "$KYTHE_WORKSPACE" -name '*.compile_command.json' -delete

printInfo "Querying build targets ..."
BUILD_TARGETS=$(bazel query 'kind(cc_.*, //...) - attr(tags, manual, //...) - //kythe/...' 2>>"$LOG_FILE")

printInfo "Building compilation database ..."
# Do not use double quotes around $BUILD_TARGETS, so shell will perform field splitting and remove newlines between
# build targets
bazel build \
    --color=yes \
    --experimental_action_listener=//kythe/generate_compile_commands:extract_json \
    --nosandbox_debug \
    --noshow_progress \
    --noshow_loading_progress \
    $BUILD_TARGETS >>"$LOG_FILE" 2>&1

OUTFILE=$WORKSPACE/compile_commands.json
echo "[" >"$OUTFILE"
find "$KYTHE_WORKSPACE" -name '*.compile_command.json' -exec cat {} + >>"$OUTFILE"
echo -e '\n]' >>"$OUTFILE"
sed -i "s|@BAZEL_ROOT@|$BAZEL_ROOT|g" "$OUTFILE"
sed -i 's/}{/},\n{/g' "$OUTFILE"

# Use `jq` to format the compilation database
if hash jq 2>/dev/null; then
    printInfo "Formatting compilation database ..."
    TMPFILE=$(mktemp)
    jq . "$OUTFILE" >"$TMPFILE" && mv "$TMPFILE" "$OUTFILE" || rm "$TMPFILE"
else
    printInfo "Can not find jq. Skip formatting compilation database."
fi

rm "$LOG_FILE"
