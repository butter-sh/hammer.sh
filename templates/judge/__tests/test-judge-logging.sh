#!/usr/bin/env bash
# Test suite for judge.sh logging and output functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    source "$TEST_HELPERS" 2>/dev/null
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
    
    if [[ "$output" == *"Test message"* ]]; then
        echo "✓ log_test produces output"
        teardown
        return 0
    else
        echo "✗ log_test output failed"
        teardown
        return 1
    fi
}

# Test: log_pass produces output and increments counter
test_log_pass_output() {
    setup
    
    TESTS_PASSED=0
    output=$(log_pass "Pass message" 2>&1)
    
    if [[ "$output" == *"Pass message"* ]] && [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ log_pass works correctly"
        teardown
        return 0
    else
        echo "✗ log_pass failed"
        teardown
        return 1
    fi
}

# Test: log_fail produces output and increments counter
test_log_fail_output() {
    setup
    
    TESTS_FAILED=0
    output=$(log_fail "Fail message" 2>&1)
    
    if [[ "$output" == *"Fail message"* ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ log_fail works correctly"
        teardown
        return 0
    else
        echo "✗ log_fail failed"
        teardown
        return 1
    fi
}

# Test: log_skip produces output
test_log_skip_output() {
    setup
    
    output=$(log_skip "Skip message" 2>&1)
    
    if [[ "$output" == *"Skip message"* ]]; then
        echo "✓ log_skip produces output"
        teardown
        return 0
    else
        echo "✗ log_skip output failed"
        teardown
        return 1
    fi
}

# Test: log_info produces output
test_log_info_output() {
    setup
    
    output=$(log_info "Info message" 2>&1)
    
    if [[ "$output" == *"Info message"* ]]; then
        echo "✓ log_info produces output"
        teardown
        return 0
    else
        echo "✗ log_info output failed"
        teardown
        return 1
    fi
}

# Test: log_warning produces output
test_log_warning_output() {
    setup
    
    output=$(log_warning "Warning message" 2>&1)
    
    if [[ "$output" == *"Warning message"* ]]; then
        echo "✓ log_warning produces output"
        teardown
        return 0
    else
        echo "✗ log_warning output failed"
        teardown
        return 1
    fi
}

# Test: log_error produces output
test_log_error_output() {
    setup
    
    output=$(log_error "Error message" 2>&1)
    
    if [[ "$output" == *"Error message"* ]]; then
        echo "✓ log_error produces output"
        teardown
        return 0
    else
        echo "✗ log_error output failed"
        teardown
        return 1
    fi
}

# Test: log_success produces output
test_log_success_output() {
    setup
    
    output=$(log_success "Success message" 2>&1)
    
    if [[ "$output" == *"Success message"* ]]; then
        echo "✓ log_success produces output"
        teardown
        return 0
    else
        echo "✗ log_success output failed"
        teardown
        return 1
    fi
}

# Test: log_section produces formatted output
test_log_section_output() {
    setup
    
    output=$(log_section "Section Title" 2>&1)
    
    if [[ "$output" == *"Section Title"* ]]; then
        echo "✓ log_section produces formatted output"
        teardown
        return 0
    else
        echo "✗ log_section output failed"
        teardown
        return 1
    fi
}

# Test: logging functions handle empty strings
test_log_empty_strings() {
    setup
    
    set +e
    log_info "" 2>&1 >/dev/null
    log_warning "" 2>&1 >/dev/null
    log_error "" 2>&1 >/dev/null
    result=$?
    set -e
    
    if [[ $result -eq 0 ]]; then
        echo "✓ Logging handles empty strings"
        teardown
        return 0
    else
        echo "✗ Logging empty strings failed"
        teardown
        return 1
    fi
}

# Test: logging functions handle special characters
test_log_special_characters() {
    setup
    
    output=$(log_info "Test with \$special & <characters>" 2>&1)
    
    if [[ "$output" == *"special"* ]]; then
        echo "✓ Logging handles special characters"
        teardown
        return 0
    else
        echo "✗ Special character handling failed"
        teardown
        return 1
    fi
}

# Test: log_pass increments counter correctly
test_log_pass_counter() {
    setup
    
    TESTS_PASSED=0
    log_pass "Test 1" >/dev/null 2>&1
    log_pass "Test 2" >/dev/null 2>&1
    log_pass "Test 3" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 3 ]]; then
        echo "✓ log_pass counter increments"
        teardown
        return 0
    else
        echo "✗ log_pass counter failed (got $TESTS_PASSED)"
        teardown
        return 1
    fi
}

# Test: log_fail increments counter correctly
test_log_fail_counter() {
    setup
    
    TESTS_FAILED=0
    log_fail "Test 1" >/dev/null 2>&1
    log_fail "Test 2" >/dev/null 2>&1
    
    if [[ $TESTS_FAILED -eq 2 ]]; then
        echo "✓ log_fail counter increments"
        teardown
        return 0
    else
        echo "✗ log_fail counter failed (got $TESTS_FAILED)"
        teardown
        return 1
    fi
}

# Test: print_test_summary shows counters
test_print_summary() {
    setup
    
    TESTS_RUN=10
    TESTS_PASSED=8
    TESTS_FAILED=2
    
    output=$(print_test_summary 2>&1)
    
    if [[ "$output" == *"Total Tests:"* ]] && \
       [[ "$output" == *"Passed:"* ]] && \
       [[ "$output" == *"Failed:"* ]]; then
        echo "✓ Summary shows counters"
        teardown
        return 0
    else
        echo "✗ Summary format failed"
        teardown
        return 1
    fi
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
    
    if [[ $result -eq 0 ]]; then
        echo "✓ Summary returns 0 on success"
        teardown
        return 0
    else
        echo "✗ Summary should return 0"
        teardown
        return 1
    fi
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
    
    if [[ $result -ne 0 ]]; then
        echo "✓ Summary returns non-zero on failure"
        teardown
        return 0
    else
        echo "✗ Summary should return non-zero"
        teardown
        return 1
    fi
}

# Test: print_test_summary handles zero tests
test_summary_zero_tests() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    
    output=$(print_test_summary 2>&1)
    
    if [[ "$output" == *"Total Tests:  0"* ]]; then
        echo "✓ Summary handles zero tests"
        teardown
        return 0
    else
        echo "✗ Zero tests handling failed"
        teardown
        return 1
    fi
}

# Test: print_test_summary calculates pass rate
test_summary_pass_rate() {
    setup
    
    TESTS_RUN=10
    TESTS_PASSED=8
    TESTS_FAILED=2
    
    output=$(print_test_summary 2>&1)
    
    if [[ "$output" == *"80%"* ]]; then
        echo "✓ Pass rate calculated correctly"
        teardown
        return 0
    else
        echo "✗ Pass rate calculation failed"
        teardown
        return 1
    fi
}

# Run all tests
run_tests() {
    local total=18
    local passed=0
    
    echo "Running logging function tests..."
    echo ""
    
    test_log_test_output && passed=$((passed + 1))
    test_log_pass_output && passed=$((passed + 1))
    test_log_fail_output && passed=$((passed + 1))
    test_log_skip_output && passed=$((passed + 1))
    test_log_info_output && passed=$((passed + 1))
    test_log_warning_output && passed=$((passed + 1))
    test_log_error_output && passed=$((passed + 1))
    test_log_success_output && passed=$((passed + 1))
    test_log_section_output && passed=$((passed + 1))
    test_log_empty_strings && passed=$((passed + 1))
    test_log_special_characters && passed=$((passed + 1))
    test_log_pass_counter && passed=$((passed + 1))
    test_log_fail_counter && passed=$((passed + 1))
    test_print_summary && passed=$((passed + 1))
    test_summary_success_return && passed=$((passed + 1))
    test_summary_failure_return && passed=$((passed + 1))
    test_summary_zero_tests && passed=$((passed + 1))
    test_summary_pass_rate && passed=$((passed + 1))
    
    echo ""
    echo "═══════════════════════════════════════"
    echo "Logging Tests: $passed/$total passed"
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
