#!/usr/bin/env bash

# Simple test to verify hammer.sh works correctly

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAMMER="$SCRIPT_DIR/hammer.sh"
TEST_DIR="/tmp/hammer_test_$$"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Testing hammer.sh..."
echo

# Test 1: Check if hammer.sh exists
echo -n "Test 1: hammer.sh exists... "
if [[ -f "$HAMMER" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 2: Make executable
echo -n "Test 2: Make executable... "
chmod +x "$HAMMER"
if [[ -x "$HAMMER" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 3: Show help
echo -n "Test 3: Show help... "
if "$HAMMER" --help &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 4: List templates
echo -n "Test 4: List templates... "
if "$HAMMER" --list &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 5: Generate starter project
echo -n "Test 5: Generate starter project... "
mkdir -p "$TEST_DIR"
if "$HAMMER" starter test-project --dir "$TEST_DIR" &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test 6: Check generated files
echo -n "Test 6: Check generated files... "
if [[ -f "$TEST_DIR/test-project/arty.yml" ]] && \
   [[ -f "$TEST_DIR/test-project/index.sh" ]] && \
   [[ -f "$TEST_DIR/test-project/README.md" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test 7: Generate arty project
echo -n "Test 7: Generate arty project... "
if "$HAMMER" arty test-arty --dir "$TEST_DIR" &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Test 8: Check arty.sh exists
echo -n "Test 8: Check arty.sh generated... "
if [[ -f "$TEST_DIR/test-arty/arty.sh" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Cleanup
rm -rf "$TEST_DIR"

echo
echo -e "${GREEN}All tests passed!${NC}"
echo "hammer.sh is working correctly."
