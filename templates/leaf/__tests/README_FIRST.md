# ⚡ QUICK FIX GUIDE

## The Problem
Tests are failing because `leaf.sh` has a bug that makes it crash!

## The Solution (30 seconds)
```bash
cd /home/valknar/Projects/hammer.sh/templates/leaf
```

Open `leaf.sh` in your editor and find line ~186:
```bash
parse_args() {
	local projects_json=""
```

Add this line right after it:
```bash
	PROJECTS_JSON=""
```

So it looks like:
```bash
parse_args() {
	local projects_json=""
	PROJECTS_JSON=""  # <-- ADD THIS!
	
	while [[ $# -gt 0 ]]; do
```

Save and exit.

## Run Tests
```bash
../../judge/judge.sh __tests
```

## Expected Result
```
✓ All 9 test suites pass
✓ 131/131 tests pass
🎉 Success!
```

---

**That's it! One line fixes everything!** 🚀

See [FIX_LEAF_FIRST.md](FIX_LEAF_FIRST.md) for detailed explanation.
