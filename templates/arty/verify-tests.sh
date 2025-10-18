#!/usr/bin/env bash
# Verification script for judge.sh integration

echo "========================================"
echo "Arty.sh Test Suite Verification"
echo "========================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${SCRIPT_DIR}/__tests"

checks_passed=0
checks_failed=0

check() {
    local description="$1"
    local test_command="$2"
    
    printf "%-50s" "$description"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo "✅ PASS"
        ((checks_passed++))
        return 0
    else
        echo "❌ FAIL"
        ((checks_failed++))
        return 1
    fi
}

echo "Checking test suite setup..."
echo ""

# File existence checks
check "arty.yml exists" "[[ -f '${SCRIPT_DIR}/arty.yml' ]]"
check "arty.sh exists" "[[ -f '${SCRIPT_DIR}/arty.sh' ]]"
check "__tests directory exists" "[[ -d '${TESTS_DIR}' ]]"
check "snapshots directory exists" "[[ -d '${TESTS_DIR}/snapshots' ]]"
check "README.md exists" "[[ -f '${TESTS_DIR}/README.md' ]]"

echo ""
echo "Checking test files..."
echo ""

# Test file checks
test_files=(
    "test_arty_cli.sh"
    "test_arty_dependencies.sh"
    "test_arty_errors.sh"
    "test_arty_exec.sh"
    "test_arty_helpers.sh"
    "test_arty_init.sh"
    "test_arty_install.sh"
    "test_arty_integration.sh"
    "test_arty_library_management.sh"
    "test_arty_logging.sh"
    "test_arty_script_execution.sh"
    "test_arty_yaml.sh"
)

for test_file in "${test_files[@]}"; do
    check "  ${test_file}" "[[ -f '${TESTS_DIR}/${test_file}' ]]"
done

echo ""
echo "Checking test file executability..."
echo ""

for test_file in "${test_files[@]}"; do
    if [[ -f "${TESTS_DIR}/${test_file}" ]]; then
        # Make executable if not already
        chmod +x "${TESTS_DIR}/${test_file}" 2>/dev/null || true
    fi
done

check "Test files are executable" "[[ -x '${TESTS_DIR}/test_arty_cli.sh' ]]"

echo ""
echo "Checking arty.yml configuration..."
echo ""

check "judge.sh in references" "grep -q 'judge.sh' '${SCRIPT_DIR}/arty.yml'"
check "test script configured" "grep -q 'test:' '${SCRIPT_DIR}/arty.yml'"
check "test:update script configured" "grep -q 'test:update' '${SCRIPT_DIR}/arty.yml'"

echo ""
echo "Checking dependencies..."
echo ""

check "yq is installed" "command -v yq"

if [[ -d "${SCRIPT_DIR}/.arty" ]]; then
    check "Dependencies installed" "[[ -d '${SCRIPT_DIR}/.arty/libs' ]]"
    
    if [[ -d "${SCRIPT_DIR}/.arty/libs/judge.sh" ]] || [[ -d "${SCRIPT_DIR}/.arty/libs/judge" ]]; then
        check "judge.sh installed" "true"
    else
        check "judge.sh installed" "false"
        echo ""
        echo "Note: Run 'arty deps' or 'arty install' to install judge.sh"
    fi
else
    check "Dependencies installed" "false"
    echo ""
    echo "Note: Run 'arty deps' or 'arty install' to install dependencies"
fi

echo ""
echo "========================================"
echo "Verification Summary"
echo "========================================"
echo ""
echo "Checks passed: ${checks_passed}"
echo "Checks failed: ${checks_failed}"
echo ""

if [[ $checks_failed -eq 0 ]]; then
    echo "✅ All checks passed!"
    echo ""
    echo "Test suite is ready to use."
    echo ""
    echo "Quick start:"
    echo "  1. Install dependencies: arty deps"
    echo "  2. Run tests: arty test"
    echo "  3. See results!"
    echo ""
    exit 0
else
    echo "⚠️  Some checks failed."
    echo ""
    echo "Please review the failed checks above."
    echo "Most issues can be resolved by running: arty deps"
    echo ""
    exit 1
fi
