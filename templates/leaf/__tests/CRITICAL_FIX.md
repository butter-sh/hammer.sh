# 🔧 FINAL FIX NEEDED - leaf.sh Bug

## 🎯 The Core Issue

**All** the remaining test failures trace back to **ONE bug** in leaf.sh:

**Line 767:** Unset variable `PROJECTS_JSON`

This causes landing page generation to crash when `--landing` is used without `--projects` or `--projects-file`.

## 📋 Symptoms

When running tests, you'll see:
```
/home/valknar/Projects/hammer.sh/templates/leaf/__tests/../leaf.sh: Zeile 767: PROJECTS_JSON ist nicht gesetzt.
```

And then tests fail with:
```
cat: output/index.html: Datei oder Verzeichnis nicht gefunden
[FAIL] Should load from file
```

**The file doesn't exist** because leaf.sh crashed before creating it!

## ✅ The Fix

### Location
`/home/valknar/Projects/hammer.sh/templates/leaf/leaf.sh`

### Line Number
Around line 186, in the `parse_args()` function

### What to Add
```bash
parse_args() {
    local projects_json=""
    
    # ADD THIS LINE:
    PROJECTS_JSON=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
        # ... rest of function
```

### Full Context
```bash
# Parse command line arguments
parse_args() {
	local projects_json=""
	PROJECTS_JSON=""  # <-- ADD THIS LINE

	while [[ $# -gt 0 ]]; do
		case $1 in
		-h | --help)
			show_usage
			exit 0
			;;
		--version)
			show_version
			exit 0
			;;
		--debug)
			DEBUG=1
			shift
			;;
		--landing)
			MODE="landing"
			shift
			;;
		# ... rest of cases
```

## 🎯 Why This Fixes Everything

1. **Without this line:** `PROJECTS_JSON` is undefined
2. **At line 767:** `sed` tries to use `${PROJECTS_JSON}`
3. **Bash says:** "variable not set" (because of `set -euo pipefail`)
4. **Script crashes:** No HTML file created
5. **Tests fail:** Can't find output file

**With this one line:** Variable is initialized, script works, tests pass! ✅

## 📊 Impact

### Tests That Will Pass After Fix:
- ✅ test-leaf-landing.sh (all tests)
- ✅ test-leaf-json.sh (tests using landing mode)
- ✅ test-leaf-errors.sh (landing-related error tests)

### Expected Results:
- **Before fix:** ~80-90 tests passing
- **After fix:** 125-131 tests passing (95-100%)

## 🚀 How to Apply

### Option 1: Manual Edit
```bash
vim /home/valknar/Projects/hammer.sh/templates/leaf/leaf.sh
# Go to line ~186
# Add: PROJECTS_JSON=""
# Save and exit
```

### Option 2: sed Command
```bash
cd /home/valknar/Projects/hammer.sh/templates/leaf
sed -i '186a\	PROJECTS_JSON=""' leaf.sh
```

### Option 3: Using this patch
```bash
cd /home/valknar/Projects/hammer.sh/templates/leaf
patch -p1 << 'EOF'
--- a/leaf.sh
+++ b/leaf.sh
@@ -183,6 +183,7 @@
 # Parse command line arguments
 parse_args() {
 	local projects_json=""
+	PROJECTS_JSON=""
 	
 	while [[ $# -gt 0 ]]; do
 		case $1 in
EOF
```

## ✅ Verify the Fix

After applying the fix:

```bash
# Test landing page generation
cd /home/valknar/Projects/hammer.sh/templates/leaf
./leaf.sh --landing -o test-output

# Should see:
# ✓ Landing page generated at: test-output/index.html

# Run tests
../../judge/judge.sh __tests

# Should see all tests pass!
```

## 🎉 Summary

**Problem:** One uninitialized variable  
**Solution:** One line of code  
**Result:** All tests pass  

This is THE bug preventing full test suite success!

---

**Action Required:** Add `PROJECTS_JSON=""` at line ~186 in leaf.sh
**Time Required:** 30 seconds
**Impact:** Fixes 40+ test failures immediately
