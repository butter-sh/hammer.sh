#!/usr/bin/env bash
# Test suite for arty script execution functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTY_SH="${SCRIPT_DIR}/../arty.sh"

# Source test helpers if available
if [[ -f "${SCRIPT_DIR}/../../judge/test-helpers.sh" ]]; then
    source "${SCRIPT_DIR}/../../judge/test-helpers.sh"
fi

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

# Test: exec script runs script from arty.yml
test_exec_script_from_config() {
    setup
    
    cat > "$TEST_DIR/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
scripts:
  hello: "echo 'Hello from script'"
  test: "echo 'Running tests'"
EOF
    
    output=$(bash "$ARTY_SH" hello 2>&1)
    
    assert_contains "$output" "Hello from script"
    
    teardown
}

# Test: exec script fails for unknown script
test_exec_script_fails_for_unknown() {
    setup
    
    cat > "$TEST_DIR/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
scripts:
  test: "echo test"
EOF
    
    output=$(bash "$ARTY_SH" unknown-script 2>&1 || true)
    
    assert_contains "$output" "Script not found"
    
    teardown
}

# Test: exec script shows available scripts on error
test_exec_script_shows_available_on_error() {
    setup
    
    cat > "$TEST_DIR/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
scripts:
  build: "echo build"
  test: "echo test"
  deploy: "echo deploy"
EOF
    
    output=$(bash "$ARTY_SH" unknown 2>&1 || true)
    
    assert_contains "$output" "Available scripts:"
    assert_contains "$output" "build"
    assert_contains "$output" "test"
    assert_contains "$output" "deploy"
    
    teardown
}

# Test: exec script fails without arty.yml
test_exec_script_fails_without_config() {
    setup
    
    output=$(bash "$ARTY_SH" some-script 2>&1 || true)
    
    assert_contains "$output" "Config file not found"
    
    teardown
}

# Test: exec script with complex command
test_exec_script_complex_command() {
    setup
    
    cat > "$TEST_DIR/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
scripts:
  complex: "echo 'Part 1' && echo 'Part 2' && echo 'Part 3'"
EOF
    
    output=$(bash "$ARTY_SH" complex 2>&1)
    
    assert_contains "$output" "Part 1"
    assert_contains "$output" "Part 2"
    assert_contains "$output" "Part 3"
    
    teardown
}

# Test: exec script with variables
test_exec_script_with_variables() {
    setup
    
    cat > "$TEST_DIR/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
scripts:
  with-var: "NAME='World' && echo \"Hello $NAME\""
EOF
    
    output=$(bash "$ARTY_SH" with-var 2>&1)
    
    assert_contains "$output" "Hello World"
    
    teardown
}

# Test: exec lib command without library name fails
test_exec_lib_without_name_fails() {
    setup
    
    output=$(bash "$ARTY_SH" exec 2>&1 || true)
    
    assert_contains "$output" "Library name required"
    
    teardown
}

# Test: exec lib command with non-existent library fails
test_exec_lib_nonexistent_fails() {
    setup
    
    mkdir -p "$ARTY_HOME/bin"
    output=$(bash "$ARTY_SH" exec nonexistent 2>&1 || true)
    
    assert_contains "$output" "not found"
    
    teardown
}

# Test: exec lib shows available executables on error
test_exec_lib_shows_available_on_error() {
    setup
    
    mkdir -p "$ARTY_HOME/bin"
    touch "$ARTY_HOME/bin/tool1"
    touch "$ARTY_HOME/bin/tool2"
    chmod +x "$ARTY_HOME/bin/tool1"
    chmod +x "$ARTY_HOME/bin/tool2"
    
    output=$(bash "$ARTY_SH" exec nonexistent 2>&1 || true)
    
    assert_contains "$output" "Available executables:"
    assert_contains "$output" "tool1"
    assert_contains "$output" "tool2"
    
    teardown
}

# Run all tests
run_tests() {
    test_exec_script_from_config
    test_exec_script_fails_for_unknown
    test_exec_script_shows_available_on_error
    test_exec_script_fails_without_config
    test_exec_script_complex_command
    test_exec_script_with_variables
    test_exec_lib_without_name_fails
    test_exec_lib_nonexistent_fails
    test_exec_lib_shows_available_on_error
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
