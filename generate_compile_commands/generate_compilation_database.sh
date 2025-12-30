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
    printError "See log file at $LOG_FILE"
}

set -e
trap '[ $? -eq 0 ] || log_err' EXIT

LOG_FILE=$(mktemp)

printInfo "Log file: $LOG_FILE"

printInfo "Fetching workspace info ..."

printInfo "$BUILD_WORKSPACE_DIRECTORY"
cd "$BUILD_WORKSPACE_DIRECTORY"
printInfo "$PWD"

WORKSPACE=$(bazel info workspace 2>"$LOG_FILE")
KYTHE_WORKSPACE=$(bazel info bazel-bin 2>>"$LOG_FILE")/../extra_actions/generate_compile_commands
BAZEL_OUTPUT_BASE=$(bazel info output_base 2>>"$LOG_FILE")

[ -d "$KYTHE_WORKSPACE" ] && find "$KYTHE_WORKSPACE" -name '*.compile_command.json' -delete

printInfo "Querying build targets ..."
BUILD_TARGETS=$(bazel cquery 'kind(cc_.*, //...) - attr(tags, manual, //...)' 2>>"$LOG_FILE" | sed "s/([^)]*)//g")

printInfo "Building compilation database ..."
# Do not use double quotes around $BUILD_TARGETS, so shell will perform field splitting and remove newlines between
# build targets
bazel build \
    --color=yes \
    --experimental_action_listener=@bazel_compile_commands_generator//generate_compile_commands:extract_json \
    --nosandbox_debug \
    --noshow_progress \
    --noshow_loading_progress \
    $BUILD_TARGETS >>"$LOG_FILE" 2>&1

TMPFILE=$(mktemp)
printf '[\n' >"$TMPFILE"
find "$KYTHE_WORKSPACE" -name '*.compile_command.json' -exec cat {} + >>"$TMPFILE"
printf '\n]\n' >>"$TMPFILE"
sed -i "s|@WORKSPACE@|$WORKSPACE|g" "$TMPFILE"
sed -i "s| external/| $BAZEL_OUTPUT_BASE/external/|g" "$TMPFILE"
sed -i 's/}{/},\n{/g' "$TMPFILE"
sed -i 's/-Werror/-Wno-unused-function -Werror/g' "$TMPFILE"

OUTFILE=$WORKSPACE/compile_commands.json

# Use `jq` to format the compilation database
if hash jq 2>/dev/null; then
    printInfo "Formatting compilation database ..."
    jq . "$TMPFILE" >"$OUTFILE"
else
    printInfo "Can not find jq. Skip formatting compilation database."
    cp --no-preserve=mode "$TMPFILE" "$OUTFILE"
fi

rm "$LOG_FILE" "$TMPFILE"
