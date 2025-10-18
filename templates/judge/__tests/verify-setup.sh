#!/usr/bin/env bash
# Verify test suite setup and dependencies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JUDGE_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Verifying Judge.sh Test Suite Setup"
echo "====================================="
echo ""

# Check for judge.sh
echo -n "Checking for judge.sh... "
if [[ -f "${JUDGE_ROOT}/judge.sh" ]]; then
    echo "✓ Found"
else
    echo "✗ Not found"
    exit 1
fi

# Check for test-helpers.sh
echo -n "Checking for test-helpers.sh... "
if [[ -f "${JUDGE_ROOT}/test-helpers.sh" ]]; then
    echo "✓ Found"
else
    echo "✗ Not found"
    exit 1
fi

# Check for snapshot directory
echo -n "Checking for snapshot directory... "
if [[ -d "${SCRIPT_DIR}/snapshots" ]]; then
    echo "✓ Found"
else
    echo "✗ Not found - creating..."
    mkdir -p "${SCRIPT_DIR}/snapshots"
    echo "✓ Created"
fi

# Check all test files
echo ""
echo "Checking test files:"

test_files=(
    "test-config.sh"
    "test-judge-cli.sh"
    "test-judge-assertions.sh"
    "test-judge-snapshots.sh"
    "test-judge-logging.sh"
    "test-judge-environment.sh"
    "test-judge-snapshot-tool.sh"
    "test-judge-colors.sh"
    "test-judge-integration.sh"
)

missing_files=0
for file in "${test_files[@]}"; do
    echo -n "  ${file}... "
    if [[ -f "${SCRIPT_DIR}/${file}" ]]; then
        echo "✓"
        # Make executable
        chmod +x "${SCRIPT_DIR}/${file}" 2>/dev/null || true
    else
        echo "✗ Missing"
        missing_files=$((missing_files + 1))
    fi
done

if [[ $missing_files -gt 0 ]]; then
    echo ""
    echo "✗ Missing ${missing_files} test file(s)"
    exit 1
fi

# Check runner scripts
echo ""
echo "Checking runner scripts:"

runner_files=(
    "run-all-tests.sh"
    "quick-start.sh"
    "list-tests.sh"
)

for file in "${runner_files[@]}"; do
    echo -n "  ${file}... "
    if [[ -f "${SCRIPT_DIR}/${file}" ]]; then
        echo "✓"
        chmod +x "${SCRIPT_DIR}/${file}" 2>/dev/null || true
    else
        echo "✗ Missing"
    fi
done

# Check documentation
echo ""
echo "Checking documentation:"

doc_files=(
    "README.md"
    "SUMMARY.md"
)

for file in "${doc_files[@]}"; do
    echo -n "  ${file}... "
    if [[ -f "${SCRIPT_DIR}/${file}" ]]; then
        echo "✓"
    else
        echo "✗ Missing"
    fi
done

# Summary
echo ""
echo "====================================="
echo "Test Suite Verification Complete"
echo ""
echo "Test suites found: ${#test_files[@]}"
echo "Runner scripts found: ${#runner_files[@]}"
echo "Documentation found: ${#doc_files[@]}"
echo ""
echo "✓ Test suite is ready to run"
echo ""
echo "To run tests:"
echo "  bash run-all-tests.sh"
echo ""
echo "To see test overview:"
echo "  bash list-tests.sh"
echo ""
echo "For quick start:"
echo "  bash quick-start.sh"
echo ""
