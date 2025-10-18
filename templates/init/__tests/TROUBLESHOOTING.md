# Troubleshooting Guide for Init.sh Tests

## Common Issues and Solutions

### 1. Tests Fail: "Usage:" Not Found

**Symptom:**
```
[FAIL] Should show usage
  Expected to contain: Usage:
```

**Cause:** Test expects generic "Usage:" but init.sh outputs specific usage like "Usage: init.sh play <file>"

**Solution:**
Update assertion to match exact output:
```bash
# Wrong:
assert_contains "$output" "Usage:" "Should show usage"

# Right:
assert_contains "$output" "Usage: init.sh play" "Should show usage"
```

**Status:** ✅ Fixed in test-init-asciinema.sh, test-init-cli.sh, test-init-integration.sh

### 2. Tests Fail: judge.sh Not Found

**Symptom:**
```
./run-tests.sh: judge.sh: command not found
```

**Cause:** judge.sh not in PATH

**Solutions:**
```bash
# Option 1: Add judge.sh to PATH
export PATH="/path/to/judge:$PATH"

# Option 2: Specify JUDGE_SH environment variable
JUDGE_SH=/path/to/judge.sh ./run-tests.sh

# Option 3: Install judge.sh globally
# Follow judge.sh installation instructions
```

### 3. Tests Fail: Permission Denied

**Symptom:**
```
bash: ./test-init-core.sh: Permission denied
```

**Cause:** Test files not executable

**Solution:**
```bash
cd /home/valknar/Projects/hammer.sh/templates/init/__tests
bash make-executable.sh
# Or manually:
chmod +x test-init-*.sh run-tests.sh
```

### 4. Tests Fail: Temp Directory Issues

**Symptom:**
```
mkdir: cannot create directory '/tmp/...': No space left on device
```

**Cause:** /tmp is full or has permission issues

**Solutions:**
```bash
# Check disk space
df -h /tmp

# Clean old temp directories
find /tmp -name "tmp.*" -type d -mtime +7 -exec rm -rf {} +

# Set alternative temp directory
export TMPDIR=/path/to/other/temp
```

### 5. Mock Commands Not Working

**Symptom:**
```
[FAIL] Should use mock
  Expected to contain: mocked
  Actual output: real command output
```

**Cause:** Mocks not in PATH or PATH order wrong

**Solution:**
```bash
# In test, ensure mocks come FIRST in PATH
export PATH="$TEST_DIR/bin:$PATH"  # ✅ Correct
export PATH="$PATH:$TEST_DIR/bin"  # ❌ Wrong (mocks at end)

# Verify in test:
which command  # Should show mock path
```

### 6. Tests Pass Locally But Fail in CI

**Common Causes:**

#### A. Different Shell
```yaml
# Ensure bash is used in CI
script:
  - bash run-tests.sh  # Not sh run-tests.sh
```

#### B. Missing Dependencies
```yaml
# Install judge.sh in CI
before_script:
  - git clone https://github.com/butter-sh/judge.sh
  - export PATH="$PWD/judge.sh:$PATH"
```

#### C. Different date Command
```bash
# Use portable date format in tests
date -r "$file" "+%Y-%m-%d" 2>/dev/null || \
stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || \
echo "unknown"
```

### 7. Assertion Failures

**Symptom:**
```
[FAIL] Should contain expected text
  Expected to contain: foo
  Actual output: bar
```

**Debugging Steps:**
```bash
# 1. Run with verbose mode
./run-tests.sh -v test-init-core.sh

# 2. Add debug output in test
test_something() {
    setup
    output=$(bash "$INIT_SH" command 2>&1)
    echo "DEBUG OUTPUT: $output" >&2  # Add this
    assert_contains "$output" "expected" "message"
    teardown
}

# 3. Run single test manually
cd /tmp
bash /path/to/init.sh command
```

### 8. Test Hangs or Takes Too Long

**Causes:**
- Interactive prompt waiting for input
- Sleep command in init.sh
- External command blocking

**Solutions:**
```bash
# Provide input to interactive prompts
echo "y" | bash "$INIT_SH" command

# Skip sleep in tests
export INIT_TEST_MODE=1  # If init.sh checks this

# Set timeout
timeout 30s bash "$INIT_SH" command
```

### 9. File Already Exists Errors

**Symptom:**
```
mkdir: cannot create directory: File exists
```

**Cause:** Teardown not cleaning up or tests running concurrently

**Solution:**
```bash
# Ensure unique test directories
TEST_DIR=$(mktemp -d -t init-test-XXXXXX)

# Ensure teardown runs even on failure
teardown() {
    cd /
    [[ -d "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}

# Don't run tests in parallel (yet)
./run-tests.sh  # Runs sequentially
```

### 10. Color/Emoji Display Issues

**Symptom:**
Weird characters in output: `\033[0;31m` or `��`

**Cause:** Terminal doesn't support colors/unicode

**Solutions:**
```bash
# Disable colors in tests
export FORCE_COLOR=0

# Or in init.sh, detect test mode
if [[ -n "$INIT_TEST_MODE" ]]; then
    # Disable colors
fi
```

## Test-Specific Issues

### test-init-asciinema.sh

**Issue:** asciinema mock not working
```bash
# Ensure mock is executable and has correct behavior
cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
case "$1" in
    rec) echo "Recording to $2"; touch "$2" ;;
    play) echo "Playing $2" ;;
    upload) echo "https://asciinema.org/a/123" ;;
esac
EOF
chmod +x "$TEST_DIR/bin/asciinema"
```

### test-init-project.sh

**Issue:** git config fails in tests
```bash
# Mock git to return test user
cat > "$TEST_DIR/bin/git" << 'EOF'
#!/bin/bash
case "$1" in
    config)
        case "$2" in
            user.name) echo "Test User" ;;
            user.email) echo "test@example.com" ;;
        esac
        ;;
esac
EOF
```

### test-init-errors.sh

**Issue:** Can't create read-only directories
```bash
# Remember to restore permissions in teardown
teardown() {
    chmod -R 755 "$TEST_DIR" 2>/dev/null || true
    rm -rf "$TEST_DIR"
}
```

## Environment Variables

### Required
None - tests set all needed variables

### Optional
```bash
VERBOSE=1              # Verbose test output
UPDATE_SNAPSHOTS=1     # Update test snapshots
INIT_TEST_MODE=1       # Signal test mode to init.sh
FORCE_COLOR=0          # Disable colors
TMPDIR=/custom/path    # Custom temp directory
```

## Getting Help

### Check Documentation
1. `README.md` - Complete test documentation
2. `QUICK_REFERENCE.md` - Quick command reference
3. `IMPLEMENTATION_SUMMARY.md` - Architecture details

### Debug Checklist
- [ ] Files are executable (`bash make-executable.sh`)
- [ ] judge.sh is in PATH
- [ ] Running from correct directory
- [ ] Temp directory has space
- [ ] Mocks are created and executable
- [ ] PATH includes mock directory first
- [ ] Assertions match actual output
- [ ] No stale temp directories

### Still Stuck?

1. **Run with verbose**: `./run-tests.sh -v`
2. **Run single test**: Comment out others in `run_tests()`
3. **Add debug output**: `echo "DEBUG: $var" >&2`
4. **Check snapshots**: `__tests/snapshots/*.log`
5. **Verify mocks**: `ls -la $TEST_DIR/bin/`
6. **Test manually**: Run init.sh commands directly

## Quick Fixes

```bash
# Clean and restart
cd /home/valknar/Projects/hammer.sh/templates/init/__tests
rm -rf snapshots/
bash make-executable.sh
./run-tests.sh

# Run specific failing test
./run-tests.sh test-init-asciinema.sh

# Run with maximum debug info
VERBOSE=1 ./run-tests.sh -v test-init-core.sh 2>&1 | less

# Check what judge.sh sees
which judge.sh
judge.sh --version

# Verify init.sh is correct version
head -n 5 ../init.sh
```

## Prevention Tips

1. **Always use setup/teardown** - Prevents state leakage
2. **Mock external dependencies** - Tests run anywhere
3. **Use specific assertions** - Catch exact failures
4. **Test isolation** - Each test in own temp dir
5. **Clean up properly** - Remove temp files
6. **Document assumptions** - Clear comments
7. **Test the tests** - Verify mocks work as expected

## Success Indicators

✅ All tests pass
✅ No temp directories left behind
✅ Tests run in under 30 seconds
✅ Mocks are used (not real commands)
✅ Output is clear and readable
✅ Can run tests repeatedly
✅ Tests are independent

## Emergency Reset

If everything is broken:

```bash
cd /home/valknar/Projects/hammer.sh/templates/init/__tests

# Nuclear option - start fresh
rm -rf snapshots/
bash make-executable.sh

# Verify files
ls -lh test-init-*.sh

# Simple test
bash test-init-core.sh

# Full test
./run-tests.sh
```

---

**Last Updated**: October 18, 2025
**Version**: 1.0
**Status**: Complete troubleshooting guide
