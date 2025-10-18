#!/usr/bin/env bash
# Test configuration for arty.sh test suite
# This file is sourced by test files to set common configuration

# Test directory structure
export TEST_ROOT="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export ARTY_SH_ROOT="${TEST_ROOT}/.."
export SNAPSHOTS_DIR="${TEST_ROOT}/snapshots"

# Test behavior flags
export ARTY_TEST_MODE=1
export ARTY_SKIP_YQ_CHECK=0  # Set to 1 to skip yq availability check in tests

# Color output in tests (set to 0 to disable)
export ARTY_TEST_COLORS=1

# Snapshot configuration
export SNAPSHOT_UPDATE="${UPDATE_SNAPSHOTS:-0}"
export SNAPSHOT_VERBOSE="${VERBOSE:-0}"

# Temp directory base
export ARTY_TEST_TMP_BASE="${TMPDIR:-/tmp}"

# Test utilities
create_test_env() {
    local test_name="${1:-test}"
    local test_dir
    test_dir=$(mktemp -d "${ARTY_TEST_TMP_BASE}/arty-test-${test_name}-XXXXXX")
    echo "$test_dir"
}

cleanup_test_env() {
    local test_dir="$1"
    if [[ -n "$test_dir" ]] && [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
}

# Assert helper shortcuts
assert_dir_exists() {
    assert_directory_exists "$@"
}

assert_success() {
    assert_exit_code 0 "$?" "${1:-Command should succeed}"
}

assert_failure() {
    assert_true "[[ $? -ne 0 ]]" "${1:-Command should fail}"
}

# Export utilities
export -f create_test_env
export -f cleanup_test_env
export -f assert_dir_exists
export -f assert_success
export -f assert_failure
