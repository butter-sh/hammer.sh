#!/usr/bin/env bash

# test.sh - Basic test suite for myst.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MYST="${SCRIPT_DIR}/myst.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected: $expected"
        echo "  Got:      $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    local needle="$1"
    local haystack="$2"
    local test_name="$3"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} FAIL: $test_name"
        echo "  Expected to contain: $needle"
        echo "  Got: $haystack"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

echo "Running myst.sh test suite..."
echo

# Source myst.sh for testing
source "$MYST"

#=============================================================================
# Test 1: Variable interpolation
#=============================================================================
echo "Test Suite: Variable Interpolation"
echo "-----------------------------------"

myst_set_var "name" "Alice"
myst_set_var "age" "30"
result=$(myst_render "Hello, {{name}}! You are {{age}} years old.")
assert_equals "Hello, Alice! You are 30 years old." "$result" "Basic variable interpolation"

result=$(myst_render "{{missing}} variable")
assert_equals " variable" "$result" "Missing variable returns empty string"

echo

#=============================================================================
# Test 2: Conditionals
#=============================================================================
echo "Test Suite: Conditionals"
echo "------------------------"

myst_set_var "show" "true"
result=$(myst_render "{{#if show}}visible{{/if}}")
assert_contains "visible" "$result" "If with truthy value"

myst_set_var "show" ""
result=$(myst_render "{{#if show}}visible{{/if}}")
assert_equals "" "$result" "If with falsy value"

myst_set_var "hide" ""
result=$(myst_render "{{#unless hide}}visible{{/unless}}")
assert_contains "visible" "$result" "Unless with falsy value"

myst_set_var "hide" "true"
result=$(myst_render "{{#unless hide}}visible{{/unless}}")
assert_equals "" "$result" "Unless with truthy value"

echo

#=============================================================================
# Test 3: Loops
#=============================================================================
echo "Test Suite: Loops"
echo "-----------------"

myst_set_var "items" "a,b,c"
result=$(myst_render "{{#each items}}{{this}},{{/each}}")
assert_contains "a," "$result" "Loop iteration with comma-separated values"
assert_contains "b," "$result" "Loop contains all items"
assert_contains "c," "$result" "Loop contains all items"

echo

#=============================================================================
# Test 4: JSON Loading
#=============================================================================
echo "Test Suite: JSON Loading"
echo "------------------------"

# Create temp JSON file
TMP_JSON=$(mktemp)
echo '{"user":"Bob","email":"bob@example.com"}' > "$TMP_JSON"

# Reset vars
MYST_VARS=()
myst_load_json "$TMP_JSON"

result=$(myst_get_var "user")
assert_equals "Bob" "$result" "Load variable from JSON"

result=$(myst_get_var "email")
assert_equals "bob@example.com" "$result" "Load email from JSON"

rm "$TMP_JSON"

echo

#=============================================================================
# Test 5: Partials
#=============================================================================
echo "Test Suite: Partials"
echo "--------------------"

MYST_PARTIALS["header"]="<h1>Header</h1>"
result=$(myst_render "{{> header}}")
assert_contains "<h1>Header</h1>" "$result" "Partial inclusion"

echo

#=============================================================================
# Test 6: Environment Variables
#=============================================================================
echo "Test Suite: Environment Variables"
echo "----------------------------------"

export MYST_TEST_VAR="test_value"
export MYST_OTHER="other_value"

MYST_VARS=()
myst_load_env "MYST_"

result=$(myst_get_var "TEST_VAR")
assert_equals "test_value" "$result" "Load from environment with prefix"

result=$(myst_get_var "OTHER")
assert_equals "other_value" "$result" "Load multiple env vars"

unset MYST_TEST_VAR MYST_OTHER

echo

#=============================================================================
# Summary
#=============================================================================
echo "========================================"
echo "Test Results"
echo "========================================"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total:  $((TESTS_PASSED + TESTS_FAILED))"
echo

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
