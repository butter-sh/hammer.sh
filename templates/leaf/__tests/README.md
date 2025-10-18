# Leaf.sh Test Suite

Comprehensive test suite for leaf.sh - beautiful documentation and landing page generator.

## Test Files

### Core Functionality Tests

- **test-leaf-cli.sh** - Command-line interface and argument parsing
  - Help and version output
  - Flag handling (--help, --version, --landing, etc.)
  - Output directory options
  - Custom logo and base path
  - Unknown option handling

- **test-leaf-dependencies.sh** - Dependency checking
  - Detection of missing yq
  - Detection of missing jq
  - Installation link display
  - Exit code handling
  - Early dependency checking

- **test-leaf-yaml.sh** - YAML parsing functionality
  - Reading simple and nested fields
  - Handling missing files and fields
  - Null value filtering
  - Quoted and multiline strings
  - Array access

- **test-leaf-json.sh** - JSON parsing and validation
  - Valid and invalid JSON parsing
  - Query extraction with jq
  - Projects JSON validation
  - Array and object validation
  - File reading and error handling

- **test-leaf-helpers.sh** - Helper functions
  - Language detection from file extensions
  - File reading
  - Icon path resolution and priority
  - Logging functions (info, success, warn, error, debug)
  - Source file scanning
  - Example file scanning

### Generation Tests

- **test-leaf-docs.sh** - Documentation generation
  - HTML output creation
  - Project metadata inclusion (name, version, description)
  - README content rendering
  - Source file inclusion with syntax highlighting
  - Example inclusion
  - HTML escaping
  - Tailwind CSS and Highlight.js integration
  - Theme toggle
  - Custom base path and icons

- **test-leaf-landing.sh** - Landing page generation
  - Landing page HTML creation
  - butter.sh branding
  - Default and custom project lists
  - JSON validation and file loading
  - Custom GitHub URLs
  - Theme toggle and mobile menu
  - Hero and projects sections
  - Priority handling (file over argument)

### Error Handling Tests

- **test-leaf-errors.sh** - Error handling and edge cases
  - Missing project directory
  - Missing or corrupted arty.yml
  - Empty YAML files
  - Projects with no source files or examples
  - Invalid JSON input
  - Special characters in names
  - Very long descriptions
  - Binary files in source
  - Permission denied scenarios
  - Missing icon files
  - Special markdown in README
  - Deeply nested directory structures
  - Files without extensions
  - Circular symlinks

### Integration Tests

- **test-leaf-integration.sh** - Complete workflows
  - Full documentation generation workflow
  - Full landing page generation workflow
  - Regenerating and overwriting docs
  - Docs and landing in separate directories
  - Multiple file types in source
  - Debug mode output
  - Special directory names (spaces, etc.)
  - Large projects with many files
  - All options combined

## Running Tests

Tests are designed to be run via the judge.sh test framework from the hammer.sh templates directory.

### Run all leaf tests:
```bash
cd hammer.sh/templates/leaf
../../judge/judge.sh __tests
```

### Run specific test file:
```bash
../../judge/judge.sh __tests/test-leaf-cli.sh
```

### Run with verbose output:
```bash
VERBOSE=1 ../../judge/judge.sh __tests
```

### Update snapshots:
```bash
UPDATE_SNAPSHOTS=1 ../../judge/judge.sh __tests
```

### Enable debug mode:
```bash
DEBUG=1 ../../judge/judge.sh __tests
```

## Test Coverage

The test suite covers:

- ✅ CLI argument parsing and validation
- ✅ Dependency checking (yq, jq)
- ✅ YAML parsing with yq
- ✅ JSON parsing and validation with jq
- ✅ Helper functions (language detection, file reading, logging)
- ✅ Documentation page generation
- ✅ Landing page generation
- ✅ Error handling and edge cases
- ✅ Integration workflows
- ✅ HTML output validation
- ✅ Theme toggle functionality
- ✅ Custom logo and icon handling
- ✅ Projects JSON validation
- ✅ Multiple file type support
- ✅ Source code syntax highlighting
- ✅ Example file inclusion
- ✅ README markdown rendering

## Test Structure

Each test file follows this pattern:

```bash
#!/usr/bin/env bash
# Test suite for leaf.sh [component]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEAF_SH="${SCRIPT_DIR}/../leaf.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: [description]
test_something() {
    setup
    
    # Test implementation
    
    teardown
}

# Run all tests
run_tests() {
    test_something
    # ... more tests
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
```

## Assertions Available

- `assert_equals value1 value2 "message"`
- `assert_contains haystack needle "message"`
- `assert_not_contains haystack needle "message"`
- `assert_file_exists path "message"`
- `assert_dir_exists path "message"`
- `assert_exit_code expected actual "message"`
- `assert_true condition "message"`

## Dependencies

Tests require:
- bash (4.0+)
- yq (for YAML parsing tests)
- jq (for JSON parsing tests)
- mktemp (for temporary directories)
- judge.sh test framework

## Notes

- Each test runs in isolation with its own temporary directory
- Tests clean up after themselves automatically
- Snapshots are stored in `__tests/snapshots/`
- All tests should be idempotent and independent

## Contributing

When adding new tests:

1. Follow the existing naming convention: `test-leaf-[component].sh`
2. Include setup() and teardown() functions
3. Write descriptive test names starting with `test_`
4. Add assertions with clear messages
5. Clean up temporary files in teardown
6. Update this README with new test coverage

## License

MIT License - Part of the hammer.sh ecosystem
