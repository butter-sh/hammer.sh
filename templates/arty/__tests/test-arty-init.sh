#!/usr/bin/env bash
# Test suite for arty init functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTY_SH="${SCRIPT_DIR}/../arty.sh"


# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export ARTY_HOME="$TEST_DIR/.arty"
    export ARTY_CONFIG_FILE="$TEST_DIR/arty.yml"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: arty init creates arty.yml
test_init_creates_config() {
    setup
    
    bash "$ARTY_SH" init test-project
    
    assert_file_exists "$TEST_DIR/arty.yml"
    assert_contains "$(cat $TEST_DIR/arty.yml)" "name: \"test-project\""
    
    teardown
}

# Test: arty init creates directory structure
test_init_creates_directories() {
    setup
    
    bash "$ARTY_SH" init test-project
    
    assert_dir_exists "$TEST_DIR/.arty"
    assert_dir_exists "$TEST_DIR/.arty/bin"
    assert_dir_exists "$TEST_DIR/.arty/libs"
    
    teardown
}

# Test: arty init fails if arty.yml exists
test_init_fails_if_config_exists() {
    setup
    
    echo "existing" > "$TEST_DIR/arty.yml"
    output=$(bash "$ARTY_SH" init test-project 2>&1 || true)
    
    assert_contains "$output" "already exists"
    
    teardown
}

# Test: arty init uses current directory name as default
test_init_uses_directory_name() {
    setup
    
    mkdir -p "$TEST_DIR/my-cool-project"
    cd "$TEST_DIR/my-cool-project"
    bash "$ARTY_SH" init
    
    assert_file_exists "arty.yml"
    assert_contains "$(cat arty.yml)" "my-cool-project"
    
    teardown
}

# Test: arty init creates valid YAML structure
test_init_creates_valid_yaml() {
    setup
    
    bash "$ARTY_SH" init test-project
    
    # Check for required fields
    assert_contains "$(cat $TEST_DIR/arty.yml)" "name:"
    assert_contains "$(cat $TEST_DIR/arty.yml)" "version:"
    assert_contains "$(cat $TEST_DIR/arty.yml)" "description:"
    assert_contains "$(cat $TEST_DIR/arty.yml)" "license:"
    assert_contains "$(cat $TEST_DIR/arty.yml)" "references:"
    assert_contains "$(cat $TEST_DIR/arty.yml)" "main:"
    assert_contains "$(cat $TEST_DIR/arty.yml)" "scripts:"
    
    teardown
}

# Test: arty init sets default version
test_init_sets_default_version() {
    setup
    
    bash "$ARTY_SH" init test-project
    
    assert_contains "$(cat $TEST_DIR/arty.yml)" "version: \"0.1.0\""
    
    teardown
}

# Test: arty init sets MIT license by default
test_init_sets_mit_license() {
    setup
    
    bash "$ARTY_SH" init test-project
    
    assert_contains "$(cat $TEST_DIR/arty.yml)" "license: \"MIT\""
    
    teardown
}

# Run all tests
run_tests() {
    test_init_creates_config
    test_init_creates_directories
    test_init_fails_if_config_exists
    test_init_uses_directory_name
    test_init_creates_valid_yaml
    test_init_sets_default_version
    test_init_sets_mit_license
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
