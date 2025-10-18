# Init.sh Test Suite

Comprehensive test suite for the init.sh project initialization system.

## Test Files

### Core Functionality Tests
- **test-init-core.sh** - Core functionality, logging, color output, environment variables
- **test-init-asciinema.sh** - Asciinema recording, playback, upload, and listing
- **test-init-project.sh** - Project structure generation, arty.yml, README creation
- **test-init-cli.sh** - CLI argument parsing, flags, commands, and aliases

### Integration Tests
- **test-init-integration.sh** - End-to-end workflows and integration scenarios

### Edge Cases and Error Handling
- **test-init-errors.sh** - Error handling, edge cases, special characters, permissions

### Configuration
- **test-config.sh** - Test configuration and environment setup

## Running Tests

### Run All Tests
```bash
# From the project root
judge.sh templates/init/__tests

# Or from the __tests directory
cd templates/init/__tests
judge.sh .
```

### Run Specific Test File
```bash
judge.sh templates/init/__tests/test-init-core.sh
```

### Run with Verbose Output
```bash
VERBOSE=1 judge.sh templates/init/__tests
```

### Update Snapshots
```bash
UPDATE_SNAPSHOTS=1 judge.sh templates/init/__tests
```

## Test Coverage

### Core Functionality (test-init-core.sh)
- ✅ Help and version display
- ✅ Banner display
- ✅ Command existence detection
- ✅ Dependency checking
- ✅ Logging functions (info, success, warn, error, header)
- ✅ Color variable setup
- ✅ Emoji support
- ✅ Environment variable defaults
- ✅ Script sourcing capability
- ✅ FORCE_COLOR environment variable

### Asciinema Functionality (test-init-asciinema.sh)
- ✅ asciinema availability checking
- ✅ Recording demos (rec command)
- ✅ Playing recordings (play command)
- ✅ Uploading recordings (upload command)
- ✅ Stop instructions (stop command)
- ✅ Listing recordings (list/ls commands)
- ✅ Default demo names
- ✅ .cast extension handling
- ✅ demos directory creation
- ✅ File location resolution (current dir vs demos/)
- ✅ Recording tips display
- ✅ Upload instructions with README snippets
- ✅ File metadata display
- ✅ Missing asciinema error messages

### Project Generation (test-init-project.sh)
- ✅ Directory structure creation (basic, cli, web, lib)
- ✅ Template-specific directories
- ✅ arty.yml generation with correct structure
- ✅ Template-specific main script paths
- ✅ Asciinema scripts in arty.yml
- ✅ Standard scripts (start, test, build, lint, docs, clean)
- ✅ Environment variables section
- ✅ README.md generation
- ✅ Asciinema section in README
- ✅ Project structure documentation
- ✅ Ecosystem links (butter.sh, arty.sh, leaf.sh, hammer.sh)
- ✅ Features list

### CLI Arguments (test-init-cli.sh)
- ✅ Help flags (-h, --help)
- ✅ Version flag (--version)
- ✅ Asciinema commands (rec, play, upload, stop, list)
- ✅ Command aliases (record, ls)
- ✅ Unknown command handling
- ✅ Missing required arguments
- ✅ Extra arguments handling
- ✅ Empty string arguments
- ✅ Command case sensitivity
- ✅ Special characters in paths
- ✅ Quoted arguments
- ✅ Numeric arguments
- ✅ Shell metacharacters

### Integration Tests (test-init-integration.sh)
- ✅ Complete asciinema workflow
- ✅ Multiple recordings management
- ✅ Recordings in multiple locations
- ✅ Stop command workflow
- ✅ .cast extension handling in workflows
- ✅ Playing from different directories
- ✅ Uploading from different directories
- ✅ Error handling for missing files
- ✅ Error handling for missing arguments
- ✅ Empty directory listing
- ✅ Recording overwrites
- ✅ Help display completeness
- ✅ Command aliases functionality
- ✅ Recording tips display
- ✅ Upload instructions
- ✅ Missing asciinema installation guidance

### Error Handling (test-init-errors.sh)
- ✅ Empty project names
- ✅ Special characters in names
- ✅ Very long project names
- ✅ Missing git configuration
- ✅ Permission denied scenarios
- ✅ Invalid template types
- ✅ Existing directories
- ✅ Deep directory paths
- ✅ Concurrent directory creation
- ✅ Symlinks in paths
- ✅ Spaces in paths
- ✅ Unicode in names
- ✅ Missing parent directories
- ✅ Relative paths
- ✅ Asciinema command failures
- ✅ Missing environment variables
- ✅ Extremely long filenames

## Test Architecture

### Test Structure
Each test file follows this pattern:

```bash
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SH="${SCRIPT_DIR}/../init.sh"

# Source test helpers (loaded by judge.sh)
if ! declare -f assert_contains > /dev/null; then
    echo "Error: Test helpers not loaded"
    exit 1
fi

setup() {
    # Create isolated test environment
    TEST_DIR=$(mktemp -d)
    export ARTY_HOME="$TEST_DIR/.arty"
    # ... other setup
}

teardown() {
    # Clean up test environment
    rm -rf "$TEST_DIR"
}

test_something() {
    setup
    # Test implementation
    assert_contains "$output" "expected" "message"
    teardown
}

run_tests() {
    log_section "Test Suite Name"
    test_something
    # ... more tests
    print_test_summary
}
```

### Available Assertions

- `assert_equals <actual> <expected> <message>`
- `assert_contains <text> <substring> <message>`
- `assert_not_contains <text> <substring> <message>`
- `assert_file_exists <path> <message>`
- `assert_file_not_exists <path> <message>`
- `assert_dir_exists <path> <message>`
- `assert_directory_exists <path> <message>`
- `assert_exit_code <expected> <actual> <message>`
- `assert_true <condition> <message>`
- `assert_false <condition> <message>`

### Test Isolation

Each test:
- Runs in a temporary directory
- Has isolated environment variables
- Uses mock dependencies (yq, git, asciinema)
- Cleans up after itself

### Mock Strategy

Tests create mock binaries for external dependencies:
```bash
mkdir -p "$TEST_DIR/bin"
cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
# Mock implementation
EOF
chmod +x "$TEST_DIR/bin/asciinema"
export PATH="$PATH:$TEST_DIR/bin"
```

## Test Statistics

- **Total Test Files**: 6
- **Total Test Cases**: 100+
- **Coverage Areas**: 6 major functional areas
- **Mock Dependencies**: yq, git, asciinema

## Continuous Integration

These tests are designed to run in CI environments:

```yaml
# Example GitHub Actions usage
- name: Run Tests
  run: |
    cd templates/init/__tests
    ../../../judge.sh .
```

## Contributing

When adding new features to init.sh:

1. Add tests to the appropriate test file
2. Create new test file if adding major functionality
3. Ensure all tests pass before submitting PR
4. Aim for comprehensive coverage of edge cases

## Dependencies

- **judge.sh** - Test runner (from butter.sh ecosystem)
- **bash** 4.0+ - Shell interpreter
- **mktemp** - Temporary directory creation
- **standard Unix tools** - cd, rm, mkdir, etc.

## License

MIT License - Same as init.sh project
