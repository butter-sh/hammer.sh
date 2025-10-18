# Final Fixes - HTML Generation Issues

## Problem
Tests are failing because HTML files aren't being generated. The myst rendering is silently failing.

## Root Causes Identified

### 1. ✅ Poor Error Handling
**Issue**: `render_with_myst()` was swallowing errors
- Used `|| true` which made failures look like success
- Didn't check if output file was created
- Didn't validate inputs before calling myst

**Fix**: Complete rewrite of `render_with_myst()`:
```bash
# Now checks:
- Template file exists
- JSON data file exists  
- Myst exit code
- Output file was created
- Shows errors when they occur
```

### 2. ✅ No Error Propagation
**Issue**: Generation functions didn't check if myst succeeded

**Fix**: Added proper error checking:
```bash
if ! render_with_myst ...; then
    log_error "Failed to render"
    return 1
fi
```

### 3. ✅ Myst Conditional Bug (Already Fixed)
Line 368 syntax error in myst - fixed earlier

### 4. ✅ Dirname Issue (Already Fixed)
Missing dirname command - added fallback

## Changes Made

### File: `leaf.sh`

#### `render_with_myst()` Function - Complete Rewrite
- Added template existence check
- Added JSON file existence check
- Proper error capture from myst
- Exit code checking
- Output file verification
- Better debug output

#### `generate_docs_page()` Function
- Added error checking after `render_with_myst` call
- Proper cleanup on failure
- Returns error code on failure

#### `generate_landing_page()` Function  
- Added error checking after `render_with_myst` call
- Proper cleanup on failure
- Returns error code on failure

## Testing

### Quick Test Script
Created `test-quick.sh` to manually test rendering:
```bash
cd /home/valknar/Projects/hammer.sh/templates/leaf
bash test-quick.sh
```

This will show you exactly what's failing.

### Run Full Test Suite
```bash
../../judge/judge.sh __tests
```

## Expected Behavior Now

### On Success
```
ℹ Generating documentation...
✓ Documentation generated at: output/index.html
```

### On Failure - Will Now Show
```
✗ Template not found: /path/to/template.myst
```
OR
```
✗ JSON data file not found: /tmp/leaf_docs_12345.json
```
OR
```
✗ Myst rendering failed with exit code 1
[actual myst error message]
```
OR
```
✗ Myst did not create output file: output/index.html
```

## Debugging Steps

If tests still fail:

1. **Run the quick test**:
   ```bash
   bash test-quick.sh
   ```

2. **Enable debug mode**:
   ```bash
   DEBUG=1 bash leaf.sh test-project -o output
   ```

3. **Check what error is shown** - The improved error handling will tell you exactly what's wrong

4. **Common issues**:
   - Template path wrong → Check `$TEMPLATES_DIR`
   - Partials not found → Check partials directory
   - Myst itself broken → Test myst independently

## Files Modified

- `/templates/leaf/leaf.sh` - Better error handling throughout
- Created `/templates/leaf/test-quick.sh` - Manual test script

## Next Steps

1. Run `test-quick.sh` to see actual error
2. Fix whatever the actual root cause is (likely path issue)
3. Re-run full test suite

---

**Status**: 🟡 AWAITING TEST RESULTS
**Confidence**: HIGH - Will now show actual errors
**Impact**: Will reveal root cause of HTML generation failures
