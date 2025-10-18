#!/usr/bin/env bash
# Test suite for arty install functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTY_SH="${SCRIPT_DIR}/../arty.sh"


# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export ARTY_HOME="$TEST_DIR/.arty"
    export ARTY_CONFIG_FILE="$TEST_DIR/arty.yml"
    cd "$TEST_DIR"
    
    # Create a minimal arty.yml for testing
    cat > "$TEST_DIR/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
references: []
scripts:
  test: "echo test"
EOF
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: arty deps creates .arty directory
test_deps_creates_arty_directory() {
    setup
    
    bash "$ARTY_SH" deps 2>/dev/null || true
    
    assert_dir_exists "$ARTY_HOME"
    assert_dir_exists "$ARTY_HOME/libs"
    assert_dir_exists "$ARTY_HOME/bin"
    
    teardown
}

# Test: arty deps with empty references does not fail
test_deps_with_empty_references() {
    setup
    
    output=$(bash "$ARTY_SH" deps 2>&1)
    exit_code=$?
    
    assert_equals "$exit_code" "0"
    
    teardown
}

# Test: arty deps fails without arty.yml
test_deps_fails_without_config() {
    setup
    
    rm "$TEST_DIR/arty.yml"
    output=$(bash "$ARTY_SH" deps 2>&1 || true)
    
    assert_contains "$output" "not found"
    
    teardown
}

# Test: install creates libs directory
test_install_creates_libs_directory() {
    setup
    
    # Try to install (will fail without actual repo, but should create directory)
    bash "$ARTY_SH" deps 2>/dev/null || true
    
    assert_dir_exists "$ARTY_HOME/libs"
    
    teardown
}

# Test: arty install command alias works
test_install_command_works() {
    setup
    
    # When no repo URL provided, should fall back to install_references
    output=$(bash "$ARTY_SH" install 2>&1)
    exit_code=$?
    
    # Should not crash
    assert_equals "$exit_code" "0"
    
    teardown
}

# Test: library name extraction from URL
test_library_name_extraction() {
    setup
    
    # Create a test script that uses get_lib_name function
    cat > "$TEST_DIR/test_name.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

echo $(get_lib_name "https://github.com/user/my-lib.git")
echo $(get_lib_name "https://github.com/user/another-lib")
EOF
    
    output=$(bash "$TEST_DIR/test_name.sh" "$ARTY_SH")
    
    assert_contains "$output" "my-lib"
    assert_contains "$output" "another-lib"
    
    teardown
}

# Test: normalize_lib_id removes .git and lowercases
test_normalize_lib_id() {
    setup
    
    # Create a test script that uses normalize_lib_id function
    cat > "$TEST_DIR/test_normalize.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

echo $(normalize_lib_id "https://github.com/User/My-Lib.git")
echo $(normalize_lib_id "https://github.com/USER/MY-LIB")
EOF
    
    output=$(bash "$TEST_DIR/test_normalize.sh" "$ARTY_SH")
    
    # Both should normalize to the same value
    first_line=$(echo "$output" | head -n1)
    second_line=$(echo "$output" | tail -n1)
    
    assert_equals "$first_line" "$second_line"
    assert_contains "$first_line" "my-lib"
    
    teardown
}

# Test: arty list shows no libraries initially
test_list_empty_initially() {
    setup
    
    bash "$ARTY_SH" deps 2>/dev/null || true
    output=$(bash "$ARTY_SH" list 2>&1)
    
    assert_contains "$output" "No libraries installed"
    
    teardown
}

# Test: arty ls alias works
test_ls_alias_works() {
    setup
    
    bash "$ARTY_SH" deps 2>/dev/null || true
    output=$(bash "$ARTY_SH" ls 2>&1)
    
    # Should not error
    assert_success
    
    teardown
}

# Run all tests
run_tests() {
    test_deps_creates_arty_directory
    test_deps_with_empty_references
    test_deps_fails_without_config
    test_install_creates_libs_directory
    test_install_command_works
    test_library_name_extraction
    test_normalize_lib_id
    test_list_empty_initially
    test_ls_alias_works
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
