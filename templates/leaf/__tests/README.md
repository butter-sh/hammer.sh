# Leaf.sh Test Suite - Post-Refactoring

## Overview

Leaf.sh has been completely refactored to use **myst.sh templating engine** instead of inline HTML generation with sed.

## What Changed

### ✅ Removed (Obsolete)
- Inline HTML heredocs (~400 lines)
- Sed-based variable substitution
- Manual escaping logic
- Tests for sed escaping issues

### ✅ Added (New Architecture)
- Myst.sh integration
- JSON-based data passing
- Template-based rendering
- Clean separation of concerns

## Current Test Suite

### Active Tests

1. **test-leaf-cli.sh** - CLI interface and argument parsing
2. **test-leaf-dependencies.sh** - Dependency checking (yq, jq, myst)
3. **test-leaf-json.sh** - JSON validation for projects
4. **test-leaf-yaml.sh** - YAML parsing for arty.yml
5. **test-leaf-integration.sh** - End-to-end generation tests

### Removed Tests (No Longer Applicable)

1. ~~test-leaf-helpers.sh~~ - Tested sed escaping (now handled by myst)
2. ~~test-leaf-errors.sh~~ - Tested sed-specific errors (obsolete)
3. ~~test-leaf-docs.sh~~ - Tested inline HTML generation (obsolete)
4. ~~test-leaf-landing.sh~~ - Tested inline HTML generation (obsolete)

## Running Tests

```bash
cd /home/valknar/Projects/hammer.sh/templates/leaf

# Clean up obsolete files first
bash __tests/cleanup.sh

# Run remaining test suite
../../judge/judge.sh __tests
```

## Expected Results

With the refactoring:
- ✅ No more sed syntax errors
- ✅ No more escaping issues
- ✅ Clean HTML output via myst
- ✅ All remaining tests should pass

## Test Focus

Tests now focus on:
- ✅ CLI argument parsing
- ✅ Dependency availability
- ✅ JSON/YAML validation
- ✅ End-to-end generation
- ✅ Template rendering via myst

Tests no longer check:
- ❌ Sed escaping
- ❌ Inline HTML structure
- ❌ Manual variable substitution

## Benefits

1. **Fewer Tests Needed** - Template rendering is myst's responsibility
2. **More Focused** - Tests check leaf-specific logic only
3. **More Maintainable** - Less brittle assertions
4. **Better Coverage** - Tests actual functionality, not implementation details

## Migration Notes

If you need to test HTML output:
- Check the generated file exists
- Validate it's well-formed HTML
- Don't test exact HTML structure (that's in templates)

## Version

- Leaf.sh: v2.3.0
- Refactored: 2025-10-18
- Architecture: Myst-based templating
