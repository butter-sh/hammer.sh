# Init.sh Test Suite - Quick Reference

## Quick Start

```bash
# Make tests executable
cd /home/valknar/Projects/hammer.sh/templates/init/__tests
bash make-executable.sh

# Run all tests
./run-tests.sh

# Run specific test
./run-tests.sh test-init-core.sh

# Verbose mode
./run-tests.sh -v
```

## Test Files at a Glance

| File | Tests | Focus |
|------|-------|-------|
| `test-init-core.sh` | 15 | Core utils, logging, colors |
| `test-init-asciinema.sh` | 20 | Recording, playback, upload |
| `test-init-project.sh` | 16 | Project generation, templates |
| `test-init-cli.sh` | 25 | CLI parsing, flags, args |
| `test-init-integration.sh` | 18 | End-to-end workflows |
| `test-init-errors.sh` | 17 | Error handling, edge cases |
| **TOTAL** | **111** | **Complete coverage** |

## Common Test Commands

```bash
# Run all tests
./run-tests.sh

# Run with verbose output
./run-tests.sh -v

# Run specific suite
./run-tests.sh test-init-asciinema.sh

# Update snapshots
./run-tests.sh -u

# Get help
./run-tests.sh --help
```

## Available Assertions

```bash
assert_equals "actual" "expected" "message"
assert_contains "$output" "substring" "message"
assert_not_contains "$output" "substring" "message"
assert_file_exists "/path/to/file" "message"
assert_dir_exists "/path/to/dir" "message"
assert_exit_code 0 $exit_code "message"
assert_true "[[ condition ]]" "message"
assert_false "[[ condition ]]" "message"
```

## Writing a New Test

```bash
# 1. Choose the right file (or create new)
#    - Core functionality → test-init-core.sh
#    - Asciinema features → test-init-asciinema.sh
#    - Project generation → test-init-project.sh
#    - CLI arguments → test-init-cli.sh
#    - Workflows → test-init-integration.sh
#    - Error cases → test-init-errors.sh

# 2. Add test function
test_my_new_feature() {
    setup  # Creates isolated $TEST_DIR
    
    # Your test code here
    output=$(bash "$INIT_SH" my-command 2>&1)
    assert_contains "$output" "expected" "Should work"
    
    teardown  # Cleans up
}

# 3. Add to run_tests() function
run_tests() {
    log_section "Test Suite Name"
    test_existing_test
    test_my_new_feature  # Add here
    print_test_summary
}
```

## Mock Template

```bash
# Mock yq
mkdir -p "$TEST_DIR/bin"
echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
chmod +x "$TEST_DIR/bin/yq"

# Mock git with behavior
cat > "$TEST_DIR/bin/git" << 'EOF'
#!/bin/bash
case "$1" in
    config) echo "Test User" ;;
    init) mkdir -p .git ;;
esac
EOF
chmod +x "$TEST_DIR/bin/git"

# Mock asciinema
cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
case "$1" in
    rec) echo "Recording" > "$2" ;;
    play) echo "Playing $2" ;;
esac
EOF
chmod +x "$TEST_DIR/bin/asciinema"

# Add to PATH
export PATH="$PATH:$TEST_DIR/bin"
```

## Environment Variables

```bash
TEST_DIR           # Temporary test directory (in setup)
INIT_SH           # Path to init.sh being tested
ARTY_HOME         # Mock arty home directory
CONFIG_FILE       # Mock config file path
DEMOS_DIR         # Mock demos directory

# Control variables
VERBOSE           # Verbose output (0 or 1)
UPDATE_SNAPSHOTS  # Update snapshots (0 or 1)
INIT_TEST_MODE    # Signals test mode to init.sh
INIT_TEST_COLORS  # Force colors in tests
```

## Coverage Checklist

When adding a new feature to init.sh, test:

- ✅ Happy path (feature works as expected)
- ✅ Error cases (missing args, invalid input)
- ✅ Edge cases (empty strings, special chars)
- ✅ Help text (if adding command)
- ✅ Integration (works with other features)

## Common Patterns

### Test a command
```bash
test_my_command() {
    setup
    output=$(bash "$INIT_SH" my-command arg1 2>&1)
    assert_contains "$output" "expected" "message"
    teardown
}
```

### Test file creation
```bash
test_creates_file() {
    setup
    bash "$INIT_SH" create-file 2>&1
    assert_file_exists "$TEST_DIR/file.txt" "Should create file"
    teardown
}
```

### Test error handling
```bash
test_handles_error() {
    setup
    output=$(bash "$INIT_SH" bad-command 2>&1 || true)
    assert_contains "$output" "Error:" "Should show error"
    teardown
}
```

### Test with mock
```bash
test_with_mock() {
    setup
    
    # Create mock
    mkdir -p "$TEST_DIR/bin"
    cat > "$TEST_DIR/bin/tool" << 'EOF'
#!/bin/bash
echo "mocked"
EOF
    chmod +x "$TEST_DIR/bin/tool"
    export PATH="$TEST_DIR/bin:$PATH"
    
    # Test
    output=$(bash "$INIT_SH" use-tool 2>&1)
    assert_contains "$output" "mocked" "Should use mock"
    
    teardown
}
```

## Debugging Failed Tests

```bash
# 1. Run with verbose
./run-tests.sh -v test-init-core.sh

# 2. Run single test by commenting out others in run_tests()

# 3. Add debug output in test
echo "DEBUG: output=$output" >&2

# 4. Check test isolation
# - Is setup/teardown working?
# - Are mocks in PATH?
# - Is TEST_DIR clean?

# 5. Manually inspect
cd /tmp/some-test-dir
bash /path/to/init.sh command
```

## File Permissions

All test files should be executable:

```bash
chmod +x test-init-*.sh
chmod +x run-tests.sh
chmod +x make-executable.sh
```

Or use the convenience script:

```bash
bash make-executable.sh
```

## Integration with CI

```yaml
# GitHub Actions example
- name: Run Init Tests
  run: |
    cd templates/init/__tests
    ./run-tests.sh

# GitLab CI example
test:
  script:
    - cd templates/init/__tests
    - ./run-tests.sh
```

## Test Statistics

- **Total Tests**: 111
- **Test Files**: 6
- **Lines of Code**: ~2,500+
- **Average Tests per File**: 18
- **Coverage**: Core, CLI, Asciinema, Templates, Integration, Errors

## Quick Links

- **Full Documentation**: `README.md`
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md`
- **Test Config**: `test-config.sh`
- **Test Runner**: `run-tests.sh`

## Support

For issues or questions:
1. Check `README.md` for detailed docs
2. Review `IMPLEMENTATION_SUMMARY.md` for architecture
3. Look at existing tests for patterns
4. Ensure judge.sh is available in PATH

---

**Last Updated**: Generated via comprehensive test suite creation
**Compatibility**: judge.sh from butter.sh ecosystem
**License**: MIT
