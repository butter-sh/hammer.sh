#!/usr/bin/env bash
# Arty Test Runner - Integrates with judge.sh
# This script discovers and runs all test suites in __tests directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${SCRIPT_DIR}/__tests"

# Check if judge.sh is available
JUDGE_PATH="${SCRIPT_DIR}/.arty/bin/judge"

if [[ ! -x "$JUDGE_PATH" ]]; then
    echo "Error: judge.sh not found at $JUDGE_PATH"
    echo ""
    echo "Please install judge.sh first:"
    echo "  arty install https://github.com/butter-sh/judge.sh.git"
    echo ""
    echo "Or run:"
    echo "  arty deps"
    exit 1
fi

# Forward all arguments to judge.sh
exec "$JUDGE_PATH" "$@"
