#!/bin/sh

# Generates tablegen_compile_commands.yml for tblgen-lsp-server
# Similar to bazel-compilation-database but for TableGen files

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
OUTFILE=$WORKSPACE/tablegen_compile_commands.yml

# Function to get include paths for a specific target
get_includes_for_target() {
    target="$1"

    # Collect all unique include paths from dependencies
    includes=""

    for dep_target in $(bazel query "labels(deps, \"$target\")" 2>>"$LOG_FILE"); do
        package=$(dirname "$(bazel query --output=location "$dep_target" 2>>"$LOG_FILE" | cut -d: -f1)")
        for include in $(bazel query --output=build "$dep_target" 2>>"$LOG_FILE" | grep "includes =" | sed 's/.*includes = \[\(.*\)\].*/\1/' | tr -d '"' | sed 's/, */\n/g'); do
            if [ -z "$include" ]; then
                continue
            fi

            full_include="$package/$include"
            if [ -z "$includes" ]; then
                includes="$full_include"
            elif ! echo "$includes" | grep -q "$full_include"; then
                includes="$includes;$full_include"
            fi
        done
    done

    echo "$includes"
}

printInfo "Querying Bazel for TableGen targets ..."

# Query all targets with td_file attribute
TABLEGEN_TARGETS=$(bazel query 'attr(td_file, ".*", //...)' 2>>"$LOG_FILE")

if [ -z "$TABLEGEN_TARGETS" ]; then
    printInfo "No TableGen targets found"
    rm -f "$OUTFILE"
    touch "$OUTFILE"
    exit 0
fi

printInfo "Generating tablegen_compile_commands.yml ..."

# Generate YAML entries for each target's td_file with its specific include paths
TMPFILE=$(mktemp)

# Track processed td_files to avoid duplicates
processed_files=""

for target in $TABLEGEN_TARGETS; do
    # Get the td_file label from this target
    td_file_label=$(bazel query "labels(td_file, \"$target\")" 2>>"$LOG_FILE")

    if [ -z "$td_file_label" ]; then
        continue
    fi

    # Skip if we've already processed this td_file
    if echo "$processed_files" | grep -q "$td_file_label"; then
        continue
    fi

    processed_files="$processed_files $td_file_label"

    # Convert label to absolute path
    td_file_path=$(bazel query --output=location "$td_file_label" 2>>"$LOG_FILE" | cut -d: -f1)

    printInfo "Processing $td_file_path ..."

    # Get include paths specific to this target
    includes=$(get_includes_for_target "$target")

    if [ -z "$includes" ]; then
        printInfo "  Warning: No include paths found for $td_file_path, skipping"
        continue
    fi

    cat >>"$TMPFILE" <<EOF
--- !FileInfo:
  filepath: "$td_file_path"
  includes: "$includes"
EOF
done

cp --no-preserve=mode "$TMPFILE" "$OUTFILE"

printInfo "Generated $OUTFILE"
printInfo "Found $(echo "$processed_files" | wc -w) unique .td files"

rm "$LOG_FILE" "$TMPFILE"
