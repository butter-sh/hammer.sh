#!/usr/bin/env bash
# Cleanup obsolete documentation and test files

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧹 Cleaning up obsolete files..."

# Remove obsolete documentation files
rm -f "$TESTS_DIR/CRITICAL_BUGS_FIXED.md"
rm -f "$TESTS_DIR/CRITICAL_FIX.md"
rm -f "$TESTS_DIR/EXECUTIVE_SUMMARY.md"
rm -f "$TESTS_DIR/FINAL_STATUS.md"
rm -f "$TESTS_DIR/FIXES_APPLIED.md"
rm -f "$TESTS_DIR/FIX_LEAF_FIRST.md"
rm -f "$TESTS_DIR/FIX_SUMMARY.md"
rm -f "$TESTS_DIR/INDEX.md"
rm -f "$TESTS_DIR/OVERVIEW.md"
rm -f "$TESTS_DIR/QUICK_FIX.md"
rm -f "$TESTS_DIR/QUICK_REFERENCE.md"
rm -f "$TESTS_DIR/README_FIRST.md"
rm -f "$TESTS_DIR/START_HERE.md"
rm -f "$TESTS_DIR/STATUS_REPORT.md"
rm -f "$TESTS_DIR/TEST_CASE_INDEX.md"
rm -f "$TESTS_DIR/TEST_SUITE_SUMMARY.md"

# Remove obsolete test files (testing inline HTML generation)
rm -f "$TESTS_DIR/test-leaf-helpers.sh"  # Tested sed escaping
rm -f "$TESTS_DIR/test-leaf-errors.sh"   # Tested sed-specific errors
rm -f "$TESTS_DIR/test-leaf-docs.sh"     # Tested inline HTML
rm -f "$TESTS_DIR/test-leaf-landing.sh"  # Tested inline HTML

# Keep these test files (still relevant):
# - test-leaf-cli.sh (CLI interface testing)
# - test-leaf-dependencies.sh (dependency checking)
# - test-leaf-json.sh (JSON validation)
# - test-leaf-yaml.sh (YAML parsing)
# - test-leaf-integration.sh (end-to-end testing)

echo "✓ Removed obsolete documentation files"
echo "✓ Removed obsolete test files"
echo ""
echo "Remaining test files:"
ls -1 "$TESTS_DIR"/test-*.sh 2>/dev/null || echo "  (none)"
echo ""
echo "✅ Cleanup complete!"
