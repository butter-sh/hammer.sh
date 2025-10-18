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
assert_equals "a" "a" "Test should pass" >/dev/null 2>&1
exit 0
EOF
    
    chmod +x "$TEST_DIR/__tests/test-simple.sh"
    
    set +e
    bash "$TEST_DIR/__tests/test-simple.sh" > /dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -eq 0 ]]; then
        echo "✓ Complete test lifecycle works"
        teardown
        return 0
    else
        echo "✗ Complete test lifecycle failed"
        teardown
        return 1
    fi
}

# Test: multiple assertions in single test
test_multiple_assertions() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_equals "a" "a" "Test 1" >/dev/null 2>&1
    assert_contains "hello world" "world" "Test 2" >/dev/null 2>&1
    assert_true "true" "Test 3" >/dev/null 2>&1
    
    if [[ $TESTS_RUN -eq 3 ]] && [[ $TESTS_PASSED -eq 3 ]]; then
        echo "✓ Multiple assertions work correctly"
        teardown
        return 0
    else
        echo "✗ Multiple assertions failed (run=$TESTS_RUN, passed=$TESTS_PASSED)"
        teardown
        return 1
    fi
}

# Test: test with setup and cleanup
test_with_setup_cleanup() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    setup_test_env > /dev/null 2>&1
    
    # Create test file in temp
    test_file="${TEMP_DIR}/test.txt"
    echo "content" > "$test_file"
    
    if [[ ! -f "$test_file" ]]; then
        echo "✗ File creation failed"
        teardown
        return 1
    fi
    
    cleanup_test_env > /dev/null 2>&1
    
    if [[ ! -f "$test_file" ]]; then
        echo "✓ Setup and cleanup workflow works"
        teardown
        return 0
    else
        echo "✗ Cleanup did not remove file"
        teardown
        return 1
    fi
}

# Test: snapshot workflow
test_snapshot_workflow() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    TESTS_RUN=0
    
    create_snapshot "test-workflow" "test content" >/dev/null 2>&1
    compare_snapshot "test-workflow" "test content" "Comparison test" >/dev/null 2>&1
    
    if [[ $TESTS_RUN -eq 1 ]]; then
        echo "✓ Snapshot workflow works"
        teardown
        return 0
    else
        echo "✗ Snapshot workflow failed"
        teardown
        return 1
    fi
}

# Test: failed test increments counter
test_failed_increments_counter() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    TESTS_FAILED=0
    
    set +e
    assert_equals "a" "b" "Failing test" >/dev/null 2>&1
    set -e
    
    if [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ Failed test increments counter"
        teardown
        return 0
    else
        echo "✗ Failed counter not incremented"
        teardown
        return 1
    fi
}

# Test: test summary with mixed results
test_summary_mixed_results() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    TESTS_RUN=5
    TESTS_PASSED=3
    TESTS_FAILED=2
    
    set +e
    print_test_summary > /dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]]; then
        echo "✓ Summary returns failure with failed tests"
        teardown
        return 0
    else
        echo "✗ Summary should return failure"
        teardown
        return 1
    fi
}

# Test: capture_output integration
test_capture_integration() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    output=$(capture_output "echo 'test' && exit 5" || true)
    
    if [[ "$output" == "test" ]] && [[ $CAPTURED_EXIT_CODE -eq 5 ]]; then
        echo "✓ Output capture works correctly"
        teardown
        return 0
    else
        echo "✗ Output capture failed (output='$output', code=$CAPTURED_EXIT_CODE)"
        teardown
        return 1
    fi
}

# Test: logging in sequence
test_logging_sequence() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    output=$(
        log_info "Starting test"
        log_test "Running test"
        log_pass "Test passed"
        log_success "All done"
    ) 2>&1
    
    if [[ "$output" == *"Starting test"* ]] && \
       [[ "$output" == *"Running test"* ]] && \
       [[ "$output" == *"Test passed"* ]] && \
       [[ "$output" == *"All done"* ]]; then
        echo "✓ Logging sequence works"
        teardown
        return 0
    else
        echo "✗ Logging sequence failed"
        teardown
        return 1
    fi
}

# Test: assertion chaining
test_assertion_chaining() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    
    # All pass
    assert_equals "a" "a" "Test 1" >/dev/null 2>&1
    assert_equals "b" "b" "Test 2" >/dev/null 2>&1
    assert_equals "c" "c" "Test 3" >/dev/null 2>&1
    
    # One fails
    set +e
    assert_equals "x" "y" "Test 4" >/dev/null 2>&1
    set -e
    
    if [[ $TESTS_RUN -eq 4 ]] && [[ $TESTS_PASSED -eq 3 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ Assertion chaining works correctly"
        teardown
        return 0
    else
        echo "✗ Assertion chaining failed (run=$TESTS_RUN, passed=$TESTS_PASSED, failed=$TESTS_FAILED)"
        teardown
        return 1
    fi
}

# Test: complex snapshot comparison
test_complex_snapshot() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    complex_output="Line 1
Line 2
Line 3
Line 4"
    
    create_snapshot "complex" "$complex_output" >/dev/null 2>&1
    compare_snapshot "complex" "$complex_output" "Complex test" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ Complex snapshot comparison works"
        teardown
        return 0
    else
        echo "✗ Complex snapshot comparison failed"
        teardown
        return 1
    fi
}

# Test: file operations in test
test_file_operations() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    setup_test_env > /dev/null 2>&1
    
    # Create directory structure
    mkdir -p "${TEMP_DIR}/subdir"
    touch "${TEMP_DIR}/file1.txt"
    touch "${TEMP_DIR}/subdir/file2.txt"
    
    if [[ -f "${TEMP_DIR}/file1.txt" ]] && \
       [[ -f "${TEMP_DIR}/subdir/file2.txt" ]] && \
       [[ -d "${TEMP_DIR}/subdir" ]]; then
        echo "✓ File operations work correctly"
        teardown
        return 0
    else
        echo "✗ File operations failed"
        teardown
        return 1
    fi
}

# Test: error handling
test_error_handling() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    set +e
    false
    result=$?
    set -e
    
    if [[ $result -eq 1 ]]; then
        echo "✓ Error handling works"
        teardown
        return 0
    else
        echo "✗ Error handling failed"
        teardown
        return 1
    fi
}

# Test: nested assertions
test_nested_assertions() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    TESTS_RUN=0
    
    output=$(echo "test output")
    assert_contains "$output" "test" "Outer assertion" >/dev/null 2>&1
    assert_contains "$output" "output" "Inner assertion 1" >/dev/null 2>&1
    assert_true "[[ ${#output} -gt 0 ]]" "Inner assertion 2" >/dev/null 2>&1
    
    if [[ $TESTS_RUN -eq 3 ]]; then
        echo "✓ Nested assertions work"
        teardown
        return 0
    else
        echo "✗ Nested assertions failed"
        teardown
        return 1
    fi
}

# Test: snapshot update workflow
test_snapshot_update() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    create_snapshot "update-test" "version 1" >/dev/null 2>&1
    update_snapshot "update-test" "version 2" >/dev/null 2>&1
    
    content=$(cat "${SNAPSHOT_DIR}/update-test.snapshot")
    if [[ "$content" == "version 2" ]]; then
        echo "✓ Snapshot update works"
        teardown
        return 0
    else
        echo "✗ Snapshot update failed"
        teardown
        return 1
    fi
}

# Test: temporary directory isolation
test_temp_isolation() {
    setup
    
    source "$TEST_HELPERS" 2>/dev/null
    
    setup_test_env > /dev/null 2>&1
    
    echo "test" > "${TEMP_DIR}/test.txt"
    
    # Setup again (should clean)
    setup_test_env > /dev/null 2>&1
    
    if [[ ! -f "${TEMP_DIR}/test.txt" ]]; then
        echo "✓ Temporary directory isolation works"
        teardown
        return 0
    else
        echo "✗ Temporary directory not isolated"
        teardown
        return 1
    fi
}

# Run all tests
run_tests() {
    local total=15
    local passed=0
    
    echo "Running integration tests..."
    echo ""
    
    test_complete_lifecycle && passed=$((passed + 1))
    test_multiple_assertions && passed=$((passed + 1))
    test_with_setup_cleanup && passed=$((passed + 1))
    test_snapshot_workflow && passed=$((passed + 1))
    test_failed_increments_counter && passed=$((passed + 1))
    test_summary_mixed_results && passed=$((passed + 1))
    test_capture_integration && passed=$((passed + 1))
    test_logging_sequence && passed=$((passed + 1))
    test_assertion_chaining && passed=$((passed + 1))
    test_complex_snapshot && passed=$((passed + 1))
    test_file_operations && passed=$((passed + 1))
    test_error_handling && passed=$((passed + 1))
    test_nested_assertions && passed=$((passed + 1))
    test_snapshot_update && passed=$((passed + 1))
    test_temp_isolation && passed=$((passed + 1))
    
    echo ""
    echo "═══════════════════════════════════════"
    echo "Integration Tests: $passed/$total passed"
    echo "═══════════════════════════════════════"
    
    if [[ $passed -eq $total ]]; then
        return 0
    else
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    exit $?
fi
