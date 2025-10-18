#!/usr/bin/env bash
# Test configuration for init.sh test suite
# This file is sourced by test files to set common configuration

export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test directory structure
export INIT_SH_ROOT="$PWD"

# Test behavior flags
export INIT_TEST_MODE=1

# Color output in tests (set to 0 to disable)
export INIT_TEST_COLORS=1

# Snapshot configuration
export SNAPSHOT_UPDATE="${UPDATE_SNAPSHOTS:-0}"
export SNAPSHOT_VERBOSE="${VERBOSE:-0}"

# Auto-discover all test files matching test-init-*.sh pattern
shopt -s nullglob
TEST_FILES_ARRAY=()
for test_file in ${TEST_ROOT}/test-init-*.sh; do
    if [[ -f "$test_file" ]]; then
        TEST_FILES_ARRAY+=("$(basename "$test_file")")
    fi
done
export TEST_FILES=("${TEST_FILES_ARRAY[@]}")
shopt -u nullglob

# Test helpers - these will be loaded by judge.sh
# but we document them here for reference

# Available assertion functions:
# - assert_equals <actual> <expected> <message>
# - assert_contains <text> <substring> <message>
# - assert_not_contains <text> <substring> <message>
# - assert_file_exists <path> <message>
# - assert_file_not_exists <path> <message>
# - assert_dir_exists <path> <message>
# - assert_directory_exists <path> <message>
# - assert_exit_code <expected_code> <actual_code> <message>
# - assert_true <condition> <message>
# - assert_false <condition> <message>

# Test lifecycle functions:
# - setup() - Called before each test
# - teardown() - Called after each test
# - run_tests() - Main test runner function

# Logging functions:
# - log_section <message> - Log a test section
# - print_test_summary - Print test results summary
