#!/usr/bin/env bash
# Test suite for judge.sh assertion functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    source "$TEST_HELPERS"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: assert_equals works with matching values
test_assert_equals_success() {
    setup
    
    # Reset counters
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_equals "test" "test" "Values should match"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_equals fails with non-matching values
test_assert_equals_failure() {
    setup
    
    # Reset counters
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_equals "expected" "actual" "Values should not match"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    assert_true "[[ $TESTS_FAILED -eq 1 ]]" "Should increment failed counter"
    
    teardown
}

# Test: assert_contains detects substring
test_assert_contains_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_contains "Hello World" "World" "Should find substring"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_contains fails when substring absent
test_assert_contains_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_contains "Hello World" "Missing" "Should not find substring"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    assert_true "[[ $TESTS_FAILED -eq 1 ]]" "Should increment failed counter"
    
    teardown
}

# Test: assert_not_contains works correctly
test_assert_not_contains_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_not_contains "Hello World" "Missing" "Should not contain substring"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_not_contains fails when substring present
test_assert_not_contains_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_not_contains "Hello World" "World" "Should fail when substring present"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    
    teardown
}

# Test: assert_exit_code checks correct code
test_assert_exit_code_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_exit_code 0 0 "Exit codes should match"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_exit_code fails on mismatch
test_assert_exit_code_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_exit_code 0 1 "Exit codes should not match"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    
    teardown
}

# Test: assert_file_exists detects existing file
test_assert_file_exists_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    touch "testfile.txt"
    assert_file_exists "testfile.txt" "File should exist"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_file_exists fails for missing file
test_assert_file_exists_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_file_exists "nonexistent.txt" "File should not exist"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    
    teardown
}

# Test: assert_directory_exists detects existing directory
test_assert_directory_exists_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    mkdir "testdir"
    assert_directory_exists "testdir" "Directory should exist"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_directory_exists fails for missing directory
test_assert_directory_exists_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_directory_exists "nonexistent" "Directory should not exist"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    
    teardown
}

# Test: assert_true evaluates commands
test_assert_true_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_true "true" "True command should pass"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_true fails for false commands
test_assert_true_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_true "false" "False command should fail"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    
    teardown
}

# Test: assert_false evaluates commands
test_assert_false_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_false "false" "False command should pass"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment passed counter"
    
    teardown
}

# Test: assert_false fails for true commands
test_assert_false_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_false "true" "True command should fail"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero"
    
    teardown
}

# Test: test counter increments
test_counter_increments() {
    setup
    
    TESTS_RUN=0
    
    assert_equals "a" "a" "Test 1"
    assert_equals "b" "b" "Test 2"
    assert_equals "c" "c" "Test 3"
    
    assert_true "[[ $TESTS_RUN -eq 3 ]]" "Should have run 3 tests"
    
    teardown
}

# Run all tests
run_tests() {
    test_assert_equals_success
    test_assert_equals_failure
    test_assert_contains_success
    test_assert_contains_failure
    test_assert_not_contains_success
    test_assert_not_contains_failure
    test_assert_exit_code_success
    test_assert_exit_code_failure
    test_assert_file_exists_success
    test_assert_file_exists_failure
    test_assert_directory_exists_success
    test_assert_directory_exists_failure
    test_assert_true_success
    test_assert_true_failure
    test_assert_false_success
    test_assert_false_failure
    test_counter_increments
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
