#!/usr/bin/env sh

# Generates a compile_commands.json file at $(bazel info execution_root) for
# your clang tooling needs.

printError() {
    printf '\033[31mERROR:\033[0m %s\n' "$@"
}

printInfo() {
    printf '\033[32mINFO:\033[0m %s\n' "$@"
}

log_err() {
    printError "See log file at $LOGFILE"
}

set -e

trap '[ $? -eq 0 ] || log_err' EXIT

LOGFILE=$(mktemp)

printInfo "Log file: $LOGFILE"

printInfo "Fetching workspace info ..."

TOOLS_WORKSPACE=$(bazel info bazel-bin 2>>"$LOGFILE")/../extra_actions/tools/generate_compile_commands_action

[ -d "$TOOLS_WORKSPACE" ] && find "$TOOLS_WORKSPACE" -name '*_compile_command' -delete

printInfo "Querying build targets ..."
BUILD_TARGETS=$(bazel cquery 'kind(cc_.*, //...) - attr(tags, manual, //...) - //tools/...' 2>>"$LOGFILE" | sed "s/([^)]*)//g")

printInfo "Building compilation database ..."
# Do not use double quotes around $BUILD_TARGETS, so shell will perform field splitting and remove newlines between
# build targets
bazel build \
    --color=yes \
    --experimental_action_listener=//tools:generate_compile_commands_listener \
    --nosandbox_debug \
    --noshow_progress \
    --noshow_loading_progress \
    $BUILD_TARGETS >>"$LOGFILE" 2>&1

python3 "$(dirname "$0")"/generate_compile_commands_json.py >>"$LOGFILE" 2>&1

WORKSPACE=$(bazel info workspace 2>"$LOGFILE")
OUTFILE=$WORKSPACE/compile_commands.json
BAZEL_OUTPUT_BASE=$(bazel info output_base 2>>"$LOGFILE")
sed -i "s| external/| $BAZEL_OUTPUT_BASE/external/|g" "$OUTFILE"

if hash jq 2>/dev/null; then
    # Use `jq` to format the compilation database
    printInfo "Formatting compilation database ..."
    TMPFILE=$(mktemp)
    jq . "$OUTFILE" >"$TMPFILE" && cp --no-preserve=mode "$TMPFILE" "$OUTFILE" && rm "$TMPFILE"
else
    printInfo "Can not find jq. Skip formatting compilation database."
fi

rm "$LOGFILE"
