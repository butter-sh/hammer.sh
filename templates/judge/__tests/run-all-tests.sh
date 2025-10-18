#!/usr/bin/env bash
# Test runner for judge.sh test suite

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JUDGE_ROOT="$(dirname "$SCRIPT_DIR")"

# Source test helpers
source "${JUDGE_ROOT}/test-helpers.sh"

# Source test config
source "${SCRIPT_DIR}/test-config.sh"

# Colors
export FORCE_COLOR=1

# Test results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=()

log_section "JUDGE.SH TEST SUITE"

echo "Running tests for judge.sh framework"
echo "Test root: ${TEST_ROOT}"
echo ""

# Run each test file
for test_file in "${TEST_FILES[@]}"; do
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    test_path="${TEST_ROOT}/${test_file}"
    test_name=$(basename "$test_file" .sh)
    
    if [[ ! -f "$test_path" ]]; then
        log_warning "Test file not found: ${test_file}"
        continue
    fi
    
    log_section "Running: ${test_name}"
    
    chmod +x "$test_path"
    
    set +e
    bash "$test_path" 2>&1
    result=$?
    set -e
    
    echo ""
    
    if [[ $result -eq 0 ]]; then
        log_success "✓ ${test_name} passed"
        PASSED_SUITES=$((PASSED_SUITES + 1))
    else
        log_error "✗ ${test_name} failed"
        FAILED_SUITES+=("$test_name")
    fi
    
    echo ""
done

# Final summary
log_section "TEST SUITE SUMMARY"

echo "Total test suites: ${TOTAL_SUITES}"
echo -e "${GREEN}Passed: ${PASSED_SUITES}${NC}"
echo -e "${RED}Failed: ${#FAILED_SUITES[@]}${NC}"
echo ""

if [[ ${#FAILED_SUITES[@]} -eq 0 ]]; then
    echo -e "${GREEN}✓ All test suites passed!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Failed test suites:${NC}"
    for suite in "${FAILED_SUITES[@]}"; do
        echo "  - $suite"
    done
    echo ""
    exit 1
fi
