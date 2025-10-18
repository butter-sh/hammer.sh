#!/bin/bash
# Quick test of the actual output to verify our fixes

cd "$(dirname "$0")/.."

echo "════════════════════════════════════════════════════════"
echo "Testing actual init.sh output to verify test assertions"
echo "════════════════════════════════════════════════════════"
echo ""

echo "1. Testing 'play' without arguments:"
echo "────────────────────────────────────"
./init.sh play 2>&1 || true
echo ""

echo "2. Testing 'upload' without arguments:"
echo "────────────────────────────────────"
./init.sh upload 2>&1 || true
echo ""

echo "3. Testing FORCE_COLOR=1:"
echo "────────────────────────────────────"
FORCE_COLOR=1 bash -c 'source ./init.sh && echo "GREEN=${GREEN:+SET}" "RED=${RED:+SET}" "BLUE=${BLUE:+SET}"'
echo ""

echo "4. Testing permission denied (mkdir in readonly dir):"
echo "────────────────────────────────────"
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/readonly"
chmod 444 "$TEST_DIR/readonly"
(
    source ./init.sh
    create_structure "$TEST_DIR/readonly/project" "basic" 2>&1 || echo "Exit code: $?"
)
chmod 755 "$TEST_DIR/readonly" 2>/dev/null || true
rm -rf "$TEST_DIR"
echo ""

echo "════════════════════════════════════════════════════════"
echo "Test complete. Compare output above with test assertions"
echo "════════════════════════════════════════════════════════"
