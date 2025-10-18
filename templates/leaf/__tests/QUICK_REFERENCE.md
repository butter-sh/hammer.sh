# Leaf.sh Test Suite - Quick Reference

## File Organization

```
__tests/
├── README.md                      # Full documentation
├── TEST_SUITE_SUMMARY.md          # This summary
├── test-config.sh                 # Test configuration
├── test-leaf-cli.sh               # CLI interface (18 tests)
├── test-leaf-dependencies.sh      # Dependency checking (7 tests)
├── test-leaf-yaml.sh              # YAML parsing (10 tests)
├── test-leaf-json.sh              # JSON parsing (14 tests)
├── test-leaf-helpers.sh           # Helper functions (16 tests)
├── test-leaf-docs.sh              # Documentation generation (16 tests)
├── test-leaf-landing.sh           # Landing page generation (22 tests)
├── test-leaf-errors.sh            # Error handling (19 tests)
├── test-leaf-integration.sh       # Integration workflows (9 tests)
└── snapshots/                     # Test snapshots directory
    ├── .gitignore                 # Ignore snapshot logs
    └── .gitkeep                   # Keep in git
```

## Quick Start

```bash
# Navigate to leaf directory
cd hammer.sh/templates/leaf

# Run all tests
../../judge/judge.sh __tests

# Run specific test
../../judge/judge.sh __tests/test-leaf-cli.sh

# Verbose mode
VERBOSE=1 ../../judge/judge.sh __tests

# Debug mode
DEBUG=1 ../../judge/judge.sh __tests
```

## Test Categories

| Category | File | Tests | Coverage |
|----------|------|-------|----------|
| CLI | test-leaf-cli.sh | 18 | Argument parsing, flags, options |
| Dependencies | test-leaf-dependencies.sh | 7 | yq/jq checking |
| YAML | test-leaf-yaml.sh | 10 | YAML parsing with yq |
| JSON | test-leaf-json.sh | 14 | JSON parsing with jq |
| Helpers | test-leaf-helpers.sh | 16 | Utility functions |
| Docs | test-leaf-docs.sh | 16 | Documentation generation |
| Landing | test-leaf-landing.sh | 22 | Landing page generation |
| Errors | test-leaf-errors.sh | 19 | Error handling, edge cases |
| Integration | test-leaf-integration.sh | 9 | Complete workflows |
| **Total** | **9 files** | **131+** | **All functionality** |

## Key Features Tested

### Documentation Mode
- ✅ arty.yml parsing (name, version, description, author, license)
- ✅ README.md rendering
- ✅ Source file scanning and inclusion
- ✅ Example file inclusion
- ✅ Icon detection and usage
- ✅ Syntax highlighting (Highlight.js)
- ✅ Responsive design (Tailwind CSS)
- ✅ Dark/light theme toggle
- ✅ Custom base path
- ✅ Custom logos

### Landing Page Mode
- ✅ butter.sh branding
- ✅ Default project list
- ✅ Custom projects (JSON inline or file)
- ✅ JSON validation
- ✅ Custom GitHub URLs
- ✅ Hero section
- ✅ Project cards
- ✅ Mobile menu
- ✅ Theme toggle
- ✅ Footer

### Error Handling
- ✅ Missing files/directories
- ✅ Corrupted YAML/JSON
- ✅ Invalid input
- ✅ Permission issues
- ✅ Edge cases (empty, special chars, long strings)

## Common Test Patterns

### Basic Test Structure
```bash
test_something() {
    setup
    
    # Arrange
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test"
EOF
    
    # Act
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    # Assert
    assert_file_exists "output/index.html" "Should create output"
    assert_contains "$output" "expected" "Should show message"
    
    teardown
}
```

### Testing Error Cases
```bash
test_error_case() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" invalid-input 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should return error"
    assert_contains "$output" "error message" "Should show error"
    
    teardown
}
```

## Available Assertions

```bash
assert_equals "expected" "$actual" "message"
assert_contains "$haystack" "needle" "message"
assert_not_contains "$haystack" "needle" "message"
assert_file_exists "path/to/file" "message"
assert_dir_exists "path/to/dir" "message"
assert_exit_code 1 $actual_code "message"
assert_true "[[ condition ]]" "message"
```

## Test Isolation

Each test:
1. Creates its own temporary directory via `setup()`
2. Changes to that directory
3. Runs the test
4. Cleans up via `teardown()`
5. Removes temporary directory

This ensures:
- No test pollution
- Parallel execution safety (future)
- Clean test environment
- Reproducible results

## Dependencies Required

- **bash** 4.0+ (shell interpreter)
- **yq** (YAML parser) - for YAML-related tests
- **jq** (JSON processor) - for JSON-related tests
- **mktemp** (temp directory creation)
- **judge.sh** (test framework from hammer.sh)

## Environment Variables

```bash
VERBOSE=1          # Show detailed output
DEBUG=1            # Enable debug mode
UPDATE_SNAPSHOTS=1 # Update test snapshots
LEAF_TEST_MODE=1   # Test mode flag (auto-set)
```

## Maintenance

### Adding New Tests

1. Create test file: `test-leaf-[component].sh`
2. Follow existing structure
3. Include setup/teardown
4. Write clear test names
5. Add descriptive assertions
6. Update README.md
7. Run all tests to verify

### Test Naming Convention

```bash
test_[component]_[behavior]()
test_[error_case]_[scenario]()
test_[integration]_[workflow]()
```

Examples:
- `test_cli_shows_usage()`
- `test_yaml_handles_missing_file()`
- `test_docs_includes_readme()`
- `test_complete_docs_workflow()`

## Coverage Summary

- **Lines of test code:** ~3,500+
- **Test cases:** 131+ individual tests
- **Code coverage:** All major functions
- **Error paths:** Comprehensive edge case coverage
- **Integration:** End-to-end workflows tested

## Success Criteria

A test suite is considered successful when:
- ✅ All tests pass on clean system
- ✅ Tests are isolated and independent
- ✅ Coverage includes happy and error paths
- ✅ Clear, descriptive test and assertion names
- ✅ Tests run quickly (< 1 minute total)
- ✅ Easy to add new tests
- ✅ Well documented

## Related Documentation

- **README.md** - Full test suite documentation
- **TEST_SUITE_SUMMARY.md** - Complete summary with statistics
- **../leaf.sh** - The script being tested
- **../../judge/** - Test framework documentation

## Support

For issues or questions:
1. Check the README.md for detailed documentation
2. Review existing tests for patterns
3. Ensure dependencies (yq, jq) are installed
4. Run with VERBOSE=1 for detailed output
5. Check judge.sh framework documentation

---

**Created:** 2025-10-18  
**Version:** 1.0.0  
**License:** MIT  
**Part of:** hammer.sh/butter.sh ecosystem
