# Color Output Fix - Complete Solution

## The Problem

Test output was showing without colors - all `[PASS]`, `[FAIL]`, `[INFO]` etc. were appearing in plain white text instead of green, red, and blue.

## Root Cause

When the test runner uses `| tee` to capture output to a file while also displaying it, the piping causes:
1. Bash detects that stdout is not connected directly to a TTY (terminal)
2. Even though `echo -e` with ANSI codes is used, programs often auto-disable colors when not writing to a TTY
3. The color codes ARE generated but something in the pipeline strips them or they're not being sent

## The Solution

Use the `script` command to create a **pseudo-TTY** (PTY):
- A PTY fakes a terminal environment
- Programs writing to it think they're connected to a real terminal
- Color codes flow through naturally
- Works on both Linux and macOS (with platform-specific syntax)

## Implementation

**File Modified**: `.arty/libs/judge.sh/run-all-tests.sh`

### Changes Made:

1. **Added color forcing environment variables** (lines 204-206):
```bash
# Force colors to be enabled even when output goes through pipes
export FORCE_COLOR=1
export CLICOLOR_FORCE=1
```

2. **Rewrote `run_test_suite()` to use `script` command** (lines 210-266):
```bash
# Check if we have script command (most Unix systems)
if command -v script > /dev/null 2>&1; then
    # Use script to create a pseudo-TTY, preserving color output
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS version
        script -q "$output_file" bash "${TESTS_DIR}/${test_file}" 2>&1 > /dev/null
        exit_code=$?
        cat "$output_file"
    else
        # Linux version  
        script -q -c "bash ${TESTS_DIR}/${test_file} 2>&1" "$output_file" > /dev/null
        exit_code=$?
        cat "$output_file"
    fi
else
    # Fallback: run without PTY (colors may not work)
    bash "${TESTS_DIR}/${test_file}" 2>&1 | tee "$output_file"
    exit_code=${PIPESTATUS[0]}
fi
```

### How It Works:

1. **Detect Platform**: Check if running on macOS (`Darwin`) or Linux
2. **macOS**: `script -q "$output_file" bash command` - BSD-style syntax
3. **Linux**: `script -q -c "bash command" "$output_file"` - GNU-style syntax
4. **Capture**: Output goes to file AND creates PTY for colors
5. **Display**: `cat` the file to show colorized output to user
6. **Fallback**: If `script` isn't available, use old `tee` method (no colors)

## Benefits

✅ **Colors work on Linux** - Most common testing environment  
✅ **Colors work on macOS** - Developer machines  
✅ **Graceful fallback** - Still works without `script` command  
✅ **Exit codes preserved** - Test pass/fail status maintained  
✅ **Snapshots still work** - Captured output for comparison  

## Expected Output

### Before (No Colors)
```
[PASS] Should show usage
[PASS] Should show commands
[FAIL] Should fail on corrupted YAML
[INFO] Updated master snapshot
```

### After (With Colors)
```
🟢 [PASS] Should show usage
🟢 [PASS] Should show commands  
🔴 [FAIL] Should fail on corrupted YAML
🔵 [INFO] Updated master snapshot
```

(Colors will be actual ANSI green, red, blue in terminal)

## Verification

Run tests to see colors:
```bash
arty test
```

You should now see:
- 🟢 Green `[PASS]` for passing tests
- 🔴 Red `[FAIL]` for failing tests
- 🔵 Blue `[INFO]` for informational messages
- 🟡 Yellow `[WARN]` for warnings
- 🟢 Green `[SUCCESS]` and `[✓]` for completed suites
- 🔴 Red `[ERROR]` and `[✗]` for failed suites
- 🔵 Cyan section headers and separators

## Platform Compatibility

- ✅ **Linux**: Uses GNU `script` with `-c` flag
- ✅ **macOS**: Uses BSD `script` without `-c` flag
- ✅ **Other Unix**: Falls back to pipe (may lose colors)
- ⚠️ **Windows**: Not tested (WSL should work like Linux)

## Technical Notes

- The `script` command is part of util-linux on Linux
- On macOS it's part of BSD utilities
- The `-q` flag makes it quiet (no "Script started" messages)
- Output still goes to file for snapshots (colors stripped during comparison)
- PTY creation is transparent to test scripts

## Alternative Approaches Considered

1. ❌ **`unbuffer` from expect package**: Not always installed
2. ❌ **Force TERM=xterm**: Doesn't help with pipe detection
3. ❌ **Custom TTY detection override**: Complex, fragile
4. ✅ **`script` command**: Universal, simple, effective
