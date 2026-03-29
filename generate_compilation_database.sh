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

if [ -z "${BUILD_WORKSPACE_DIRECTORY}" ]; then
    echo "The environment variable BUILD_WORKSPACE_DIRECTORY is not set. Did you invoke the script using 'bazel run'?" >>"$LOG_FILE" 2>&1
    exit 1
fi

WORKSPACE="$BUILD_WORKSPACE_DIRECTORY"
cd "$WORKSPACE"
COMPILATION_DATABASE_LOCATION=$(bazel info bazel-bin 2>>"$LOG_FILE")/../extra_actions
BAZEL_OUTPUT_BASE=$(bazel info output_base 2>>"$LOG_FILE")

[ -d "$COMPILATION_DATABASE_LOCATION" ] && find "$COMPILATION_DATABASE_LOCATION" -name '*.compile_command.json' -delete

printInfo "Querying build targets ..."
# BUILD_TARGETS=$(bazel cquery 'kind(cc_.*, //...) - attr(tags, manual, //...) - @compile_commands_generator//...' 2>>"$LOG_FILE" | sed "s/([^)]*)//g")
BUILD_TARGETS=$(bazel cquery 'kind(cc_.*, //...) - attr(tags, manual, //...)' 2>>"$LOG_FILE" | sed "s/([^)]*)//g")

printInfo "Building compilation database ..."
# Do not use double quotes around $BUILD_TARGETS, so shell will perform field splitting and remove newlines between
# build targets
bazel build \
    --color=yes \
    --experimental_action_listener=@compile_commands_generator//:extract_json \
    --nosandbox_debug \
    --noshow_progress \
    --noshow_loading_progress \
    $BUILD_TARGETS >>"$LOG_FILE" 2>&1

TMPFILE=$(mktemp)
printf '[\n' >"$TMPFILE"
find "$COMPILATION_DATABASE_LOCATION" -name '*.compile_command.json' -exec cat {} + >>"$TMPFILE" 2>>"$LOG_FILE"
printf '\n]\n' >>"$TMPFILE"
sed -i "s|@WORKSPACE@|$WORKSPACE|g" "$TMPFILE"
sed -i "s| external/| $BAZEL_OUTPUT_BASE/external/|g" "$TMPFILE"
sed -i 's/}{/},\n{/g' "$TMPFILE"
sed -i 's/-Werror/-Wno-unused-function -Werror/g' "$TMPFILE"

OUTFILE=$WORKSPACE/compile_commands.json

cp --no-preserve=mode "$TMPFILE" "$OUTFILE"

rm "$LOG_FILE" "$TMPFILE"
