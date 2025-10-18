#!/usr/bin/env bash
# Test suite for judge.sh logging and output functions

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

# Test: log_test produces output
test_log_test_output() {
    setup
    
    output=$(log_test "Test message" 2>&1)
    
    assert_contains "$output" "Test message" "Should contain message"
    
    teardown
}

# Test: log_pass produces output
test_log_pass_output() {
    setup
    
    TESTS_PASSED=0
    output=$(log_pass "Pass message" 2>&1)
    
    assert_contains "$output" "Pass message" "Should contain message"
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment counter"
    
    teardown
}

# Test: log_fail produces output
test_log_fail_output() {
    setup
    
    TESTS_FAILED=0
    output=$(log_fail "Fail message" 2>&1)
    
    assert_contains "$output" "Fail message" "Should contain message"
    assert_true "[[ $TESTS_FAILED -eq 1 ]]" "Should increment counter"
    
    teardown
}

# Test: log_skip produces output
test_log_skip_output() {
    setup
    
    output=$(log_skip "Skip message" 2>&1)
    
    assert_contains "$output" "Skip message" "Should contain message"
    
    teardown
}

# Test: log_info produces output
test_log_info_output() {
    setup
    
    output=$(log_info "Info message" 2>&1)
    
    assert_contains "$output" "Info message" "Should contain message"
    
    teardown
}

# Test: log_warning produces output
test_log_warning_output() {
    setup
    
    output=$(log_warning "Warning message" 2>&1)
    
    assert_contains "$output" "Warning message" "Should contain message"
    
    teardown
}

# Test: log_error produces output
test_log_error_output() {
    setup
    
    output=$(log_error "Error message" 2>&1)
    
    assert_contains "$output" "Error message" "Should contain message"
    
    teardown
}

# Test: log_success produces output
test_log_success_output() {
    setup
    
    output=$(log_success "Success message" 2>&1)
    
    assert_contains "$output" "Success message" "Should contain message"
    
    teardown
}

# Test: log_section produces formatted output
test_log_section_output() {
    setup
    
    output=$(log_section "Section Title" 2>&1)
    
    assert_contains "$output" "Section Title" "Should contain title"
    
    teardown
}

# Test: logging functions handle empty strings
test_log_empty_strings() {
    setup
    
    set +e
    log_info "" 2>&1
    log_warning "" 2>&1
    log_error "" 2>&1
    result=$?
    set -e
    
    assert_equals 0 $result "Should handle empty strings"
    
    teardown
}

# Test: logging functions handle special characters
test_log_special_characters() {
    setup
    
    output=$(log_info "Test with \$special & <characters>" 2>&1)
    
    assert_contains "$output" "special" "Should handle special characters"
    
    teardown
}

# Test: log_pass increments counter correctly
test_log_pass_counter() {
    setup
    
    TESTS_PASSED=0
    log_pass "Test 1"
    log_pass "Test 2"
    log_pass "Test 3"
    
    assert_true "[[ $TESTS_PASSED -eq 3 ]]" "Should increment to 3"
    
    teardown
}

# Test: log_fail increments counter correctly
test_log_fail_counter() {
    setup
    
    TESTS_FAILED=0
    log_fail "Test 1"
    log_fail "Test 2"
    
    assert_true "[[ $TESTS_FAILED -eq 2 ]]" "Should increment to 2"
    
    teardown
}

# Test: print_test_summary shows counters
test_print_summary() {
    setup
    
    TESTS_RUN=10
    TESTS_PASSED=8
    TESTS_FAILED=2
    
    output=$(print_test_summary 2>&1)
    
    assert_contains "$output" "Total Tests:" "Should show total"
    assert_contains "$output" "Passed:" "Should show passed"
    assert_contains "$output" "Failed:" "Should show failed"
    
    teardown
}

# Test: print_test_summary returns success when all pass
test_summary_success_return() {
    setup
    
    TESTS_RUN=5
    TESTS_PASSED=5
    TESTS_FAILED=0
    
    set +e
    print_test_summary > /dev/null 2>&1
    result=$?
    set -e
    
    assert_equals 0 $result "Should return 0 when all pass"
    
    teardown
}

# Test: print_test_summary returns failure when tests fail
test_summary_failure_return() {
    setup
    
    TESTS_RUN=5
    TESTS_PASSED=3
    TESTS_FAILED=2
    
    set +e
    print_test_summary > /dev/null 2>&1
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero when tests fail"
    
    teardown
}

# Test: print_test_summary handles zero tests
test_summary_zero_tests() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    
    output=$(print_test_summary 2>&1)
    
    assert_contains "$output" "Total Tests:  0" "Should handle zero tests"
    
    teardown
}

# Test: print_test_summary calculates pass rate
test_summary_pass_rate() {
    setup
    
    TESTS_RUN=10
    TESTS_PASSED=8
    TESTS_FAILED=2
    
    output=$(print_test_summary 2>&1)
    
    assert_contains "$output" "80%" "Should show 80% pass rate"
    
    teardown
}

# Run all tests
run_tests() {
    test_log_test_output
    test_log_pass_output
    test_log_fail_output
    test_log_skip_output
    test_log_info_output
    test_log_warning_output
    test_log_error_output
    test_log_success_output
    test_log_section_output
    test_log_empty_strings
    test_log_special_characters
    test_log_pass_counter
    test_log_fail_counter
    test_print_summary
    test_summary_success_return
    test_summary_failure_return
    test_summary_zero_tests
    test_summary_pass_rate
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
