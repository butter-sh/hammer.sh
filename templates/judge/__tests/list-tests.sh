#!/usr/bin/env bash
# List all available tests with descriptions

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              JUDGE.SH TEST SUITE OVERVIEW                      ║
║              117 Tests across 8 Suites                         ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

AVAILABLE TEST SUITES:

1. test-judge-cli.sh (15 tests)
   ├─ CLI interface and command routing
   ├─ Help system and usage display
   ├─ Command recognition (run, setup, snap)
   └─ Error handling for unknown commands

2. test-judge-assertions.sh (17 tests)
   ├─ assert_equals - equality checks
   ├─ assert_contains - substring presence
   ├─ assert_not_contains - substring absence
   ├─ assert_exit_code - exit code validation
   ├─ assert_file_exists - file checks
   ├─ assert_directory_exists - directory checks
   ├─ assert_true - command success
   ├─ assert_false - command failure
   └─ Test counter incrementation

3. test-judge-snapshots.sh (14 tests)
   ├─ Snapshot creation and updates
   ├─ Snapshot comparison logic
   ├─ Output normalization
   ├─ ANSI code handling
   ├─ Whitespace handling
   ├─ Missing snapshot handling
   ├─ Multiline content support
   └─ Empty content support

4. test-judge-logging.sh (18 tests)
   ├─ log_test - test descriptions
   ├─ log_pass - success messages
   ├─ log_fail - failure messages
   ├─ log_skip - skip messages
   ├─ log_info - informational messages
   ├─ log_warning - warning messages
   ├─ log_error - error messages
   ├─ log_success - success indicators
   ├─ log_section - section headers
   ├─ print_test_summary - result summaries
   └─ Pass rate calculations

5. test-judge-environment.sh (15 tests)
   ├─ setup_test_env - environment setup
   ├─ cleanup_test_env - cleanup operations
   ├─ capture_output - output capturing
   ├─ Temporary directory management
   ├─ Snapshot directory persistence
   ├─ Environment isolation
   └─ Function exports

6. test-judge-snapshot-tool.sh (15 tests)
   ├─ list command - snapshot listing
   ├─ show command - display snapshots
   ├─ diff command - compare snapshots
   ├─ stats command - statistics
   ├─ clean command - cleanup old snapshots
   └─ Error handling and validation

7. test-judge-colors.sh (8 tests)
   ├─ Color enabling/disabling
   ├─ Terminal detection
   ├─ FORCE_COLOR variable
   ├─ Color variable definitions
   ├─ Color exports
   └─ Consistency checks

8. test-judge-integration.sh (15 tests)
   ├─ Complete test lifecycle
   ├─ Multiple assertions
   ├─ Setup/cleanup workflows
   ├─ Snapshot workflows
   ├─ Mixed test results
   ├─ File operations
   ├─ Error handling
   └─ Complex scenarios

────────────────────────────────────────────────────────────────

QUICK COMMANDS:

Run all tests:
  $ bash run-all-tests.sh
  $ bash quick-start.sh

Run specific suite:
  $ bash test-judge-cli.sh
  $ bash test-judge-assertions.sh
  $ bash test-judge-snapshots.sh
  $ bash test-judge-logging.sh
  $ bash test-judge-environment.sh
  $ bash test-judge-snapshot-tool.sh
  $ bash test-judge-colors.sh
  $ bash test-judge-integration.sh

With verbose output:
  $ VERBOSE=1 bash run-all-tests.sh

Update snapshots:
  $ UPDATE_SNAPSHOTS=1 bash run-all-tests.sh

────────────────────────────────────────────────────────────────

DOCUMENTATION:

README.md    - Complete test suite documentation
SUMMARY.md   - Creation summary and metrics
This file    - Quick overview and command reference

────────────────────────────────────────────────────────────────

TEST COVERAGE SUMMARY:

Core Functionality:
  ✓ CLI interface and routing
  ✓ All assertion functions
  ✓ Snapshot creation and comparison
  ✓ Output normalization
  ✓ Logging and reporting

Test Environment:
  ✓ Setup and cleanup
  ✓ Temporary directory management
  ✓ Output capturing
  ✓ Function exports
  ✓ Environment isolation

Snapshot Management:
  ✓ List, show, diff commands
  ✓ Statistics and cleanup
  ✓ Error handling
  ✓ Missing file handling

Integration:
  ✓ Complete workflows
  ✓ Multi-assertion tests
  ✓ File operations
  ✓ Complex scenarios
  ✓ Error handling

────────────────────────────────────────────────────────────────

For detailed information, see README.md

EOF
