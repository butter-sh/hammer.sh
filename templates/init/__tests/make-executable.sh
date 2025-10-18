#!/usr/bin/env bash
# Make all test files executable

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Making test files executable..."

chmod +x "$SCRIPT_DIR"/test-init-*.sh
chmod +x "$SCRIPT_DIR"/run-tests.sh

echo "✓ All test files are now executable"
echo ""
echo "Test files:"
for file in "$SCRIPT_DIR"/test-init-*.sh; do
    if [[ -f "$file" ]]; then
        echo "  • $(basename "$file")"
    fi
done
echo ""
echo "Run with: ./run-tests.sh"
