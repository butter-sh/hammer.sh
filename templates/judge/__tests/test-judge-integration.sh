#!/usr/bin/env bash
# Integration tests for judge.sh - tests complete workflows

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JUDGE_SH="${SCRIPT_DIR}/../judge.sh"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export PROJECT_ROOT="$TEST_DIR"
    export SNAPSHOT_DIR="$TEST_DIR/snapshots"
    mkdir -p "$SNAPSHOT_DIR"
    mkdir -p "$TEST_DIR/__tests"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: complete test lifecycle
test_complete_lifecycle() {
    setup
    
    # Create a simple test file
    cat > "$TEST_DIR/__tests/test-simple.sh" << 'EOF'
#!/usr/bin/env bash
source "../test-helpers.sh"
log_test "Simple test"
assert_equals "a" "a" "Test should pass"
print_test_summary
EOF
    
    chmod +x "$TEST_DIR/__tests/test-simple.sh"
    
    # Run the test
    set +e
    bash "$TEST_DIR/__tests/test-simple.sh" > /dev/null 2>&1
    result=$?
    set -e
    
    assert_equals 0 $result "Test should pass"
    
    teardown
}

# Test: multiple assertions in single test
test_multiple_assertions() {
    setup
    
    source "$TEST_HELPERS"
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_equals "a" "a" "Test 1"
    assert_contains "hello world" "world" "Test 2"
    assert_true "true" "Test 3"
    
    assert_equals 3 $TESTS_RUN "Should run 3 tests"
    assert_equals 3 $TESTS_PASSED "All should pass"
    
    teardown
}

# Test: test with setup and cleanup
test_with_setup_cleanup() {
    setup
    
    source "$TEST_HELPERS"
    
    setup_test_env > /dev/null 2>&1
    
    # Create test file in temp
    test_file="${TEMP_DIR}/test.txt"
    echo "content" > "$test_file"
    
    assert_file_exists "$test_file" "File should exist"
    
    cleanup_test_env > /dev/null 2>&1
    
    assert_false "[[ -f \"$test_file\" ]]" "File should be cleaned up"
    
    teardown
}

# Test: snapshot workflow
test_snapshot_workflow() {
    setup
    
    source "$TEST_HELPERS"
    
    TESTS_RUN=0
    
    # Create snapshot
    create_snapshot "test-workflow" "test content"
    
    # Compare with same content
    compare_snapshot "test-workflow" "test content" "Comparison test"
    
    assert_equals 1 $TESTS_RUN "Should run comparison"
    
    teardown
}

# Test: failed test increments counter
test_failed_increments_counter() {
    setup
    
    source "$TEST_HELPERS"
    
    TESTS_FAILED=0
    
    set +e
    assert_equals "a" "b" "Failing test"
    set -e
    
    assert_equals 1 $TESTS_FAILED "Should increment failure counter"
    
    teardown
}

# Test: test summary with mixed results
test_summary_mixed_results() {
    setup
    
    source "$TEST_HELPERS"
    
    TESTS_RUN=5
    TESTS_PASSED=3
    TESTS_FAILED=2
    
    set +e
    print_test_summary > /dev/null 2>&1
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return failure with failed tests"
    
    teardown
}

# Test: capture_output integration
test_capture_integration() {
    setup
    
    source "$TEST_HELPERS"
    
    output=$(capture_output "echo 'test' && exit 5" || true)
    
    assert_equals "test" "$output" "Should capture output"
    assert_equals 5 $CAPTURED_EXIT_CODE "Should capture exit code"
    
    teardown
}

# Test: logging in sequence
test_logging_sequence() {
    setup
    
    source "$TEST_HELPERS"
    
    output=$(
        log_info "Starting test"
        log_test "Running test"
        log_pass "Test passed"
        log_success "All done"
    ) 2>&1
    
    assert_contains "$output" "Starting test" "Should contain info"
    assert_contains "$output" "Running test" "Should contain test"
    assert_contains "$output" "Test passed" "Should contain pass"
    assert_contains "$output" "All done" "Should contain success"
    
    teardown
}

# Test: assertion chaining
test_assertion_chaining() {
    setup
    
    source "$TEST_HELPERS"
    
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    
    # All pass
    assert_equals "a" "a" "Test 1"
    assert_equals "b" "b" "Test 2"
    assert_equals "c" "c" "Test 3"
    
    # One fails
    set +e
    assert_equals "x" "y" "Test 4"
    set -e
    
    assert_equals 4 $TESTS_RUN "Should run 4 tests"
    assert_equals 3 $TESTS_PASSED "Should have 3 passed"
    assert_equals 1 $TESTS_FAILED "Should have 1 failed"
    
    teardown
}

# Test: complex snapshot comparison
test_complex_snapshot() {
    setup
    
    source "$TEST_HELPERS"
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    complex_output="Line 1
Line 2
Line 3
Line 4"
    
    create_snapshot "complex" "$complex_output"
    compare_snapshot "complex" "$complex_output" "Complex test"
    
    assert_equals 1 $TESTS_PASSED "Should pass complex comparison"
    
    teardown
}

# Test: file operations in test
test_file_operations() {
    setup
    
    source "$TEST_HELPERS"
    
    setup_test_env > /dev/null 2>&1
    
    # Create directory structure
    mkdir -p "${TEMP_DIR}/subdir"
    touch "${TEMP_DIR}/file1.txt"
    touch "${TEMP_DIR}/subdir/file2.txt"
    
    assert_file_exists "${TEMP_DIR}/file1.txt" "File 1 should exist"
    assert_file_exists "${TEMP_DIR}/subdir/file2.txt" "File 2 should exist"
    assert_directory_exists "${TEMP_DIR}/subdir" "Subdir should exist"
    
    teardown
}

# Test: error handling
test_error_handling() {
    setup
    
    source "$TEST_HELPERS"
    
    # Test that errors don't crash the test
    set +e
    false
    result=$?
    set -e
    
    assert_equals 1 $result "Should capture failure"
    
    teardown
}

# Test: nested assertions
test_nested_assertions() {
    setup
    
    source "$TEST_HELPERS"
    
    TESTS_RUN=0
    
    # Outer assertion
    output=$(echo "test output")
    assert_contains "$output" "test" "Outer assertion"
    
    # Inner assertions
    assert_contains "$output" "output" "Inner assertion 1"
    assert_true "[[ ${#output} -gt 0 ]]" "Inner assertion 2"
    
    assert_equals 3 $TESTS_RUN "Should run all assertions"
    
    teardown
}

# Test: snapshot update workflow
test_snapshot_update() {
    setup
    
    source "$TEST_HELPERS"
    
    # Create initial snapshot
    create_snapshot "update-test" "version 1"
    
    # Update it
    update_snapshot "update-test" "version 2"
    
    # Verify update
    content=$(cat "${SNAPSHOT_DIR}/update-test.snapshot")
    assert_equals "version 2" "$content" "Should be updated"
    
    teardown
}

# Test: temporary directory isolation
test_temp_isolation() {
    setup
    
    source "$TEST_HELPERS"
    
    setup_test_env > /dev/null 2>&1
    
    # Create file in temp
    echo "test" > "${TEMP_DIR}/test.txt"
    
    # Setup again (should clean)
    setup_test_env > /dev/null 2>&1
    
    # File should be gone
    assert_false "[[ -f \"${TEMP_DIR}/test.txt\" ]]" "Should clean temp"
    
    teardown
}

# Run all tests
run_tests() {
    test_complete_lifecycle
    test_multiple_assertions
    test_with_setup_cleanup
    test_snapshot_workflow
    test_failed_increments_counter
    test_summary_mixed_results
    test_capture_integration
    test_logging_sequence
    test_assertion_chaining
    test_complex_snapshot
    test_file_operations
    test_error_handling
    test_nested_assertions
    test_snapshot_update
    test_temp_isolation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
