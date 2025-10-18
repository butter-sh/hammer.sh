#!/usr/bin/env bash
# Test configuration for leaf.sh test suite
# This file is sourced by test files to set common configuration
export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test directory structure
export LEAF_SH_ROOT="$PWD"

# Test behavior flags
export LEAF_TEST_MODE=1
export LEAF_SKIP_YQ_CHECK=0  # Set to 1 to skip yq availability check in tests
export LEAF_SKIP_JQ_CHECK=0  # Set to 1 to skip jq availability check in tests

# Color output in tests (set to 0 to disable)
export LEAF_TEST_COLORS=1

# Snapshot configuration
export SNAPSHOT_UPDATE="${UPDATE_SNAPSHOTS:-0}"
export SNAPSHOT_VERBOSE="${VERBOSE:-0}"

# Auto-discover all test files matching test-*.sh pattern
shopt -s nullglob
TEST_FILES_ARRAY=()
for test_file in ${TEST_ROOT}/test-leaf-*.sh; do
    if [[ -f "$test_file" ]]; then
        TEST_FILES_ARRAY+=("$(basename "$test_file")")
    fi
done
export TEST_FILES=("${TEST_FILES_ARRAY[@]}")
shopt -u nullglob
