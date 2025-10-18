#!/usr/bin/env bash
# Quick start script for judge.sh test suite

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║              JUDGE.SH TEST SUITE - QUICK START                 ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "This will run all 117 tests across 8 test suites."
echo ""
echo "Test suites:"
echo "  1. CLI Interface (15 tests)"
echo "  2. Assertions (17 tests)"
echo "  3. Snapshots (14 tests)"
echo "  4. Logging (18 tests)"
echo "  5. Environment (15 tests)"
echo "  6. Snapshot Tool (15 tests)"
echo "  7. Colors (8 tests)"
echo "  8. Integration (15 tests)"
echo ""
echo "Press Enter to start, or Ctrl+C to cancel..."
read

echo ""
echo "Starting test suite..."
echo ""

chmod +x "${SCRIPT_DIR}"/*.sh

bash "${SCRIPT_DIR}/run-all-tests.sh"
