#!/usr/bin/env bash
# Test suite for hammer.sh CLI functionality

# Setup before each test
setup() {
    TEST_ENV_DIR=$(create_test_env)
    cd "$TEST_ENV_DIR"
}

teardown() {
    cleanup_test_env
}

# Test: show help message
test_show_help_message() {
    output=$("$HAMMER_SH" --help 2>&1)
    assert_contains "$output" "hammer.sh" "Should show hammer.sh in help"
    assert_contains "$output" "USAGE" "Should show USAGE section"
    assert_contains "$output" "OPTIONS" "Should show OPTIONS section"
}

# Test: show version
test_show_version() {
    output=$("$HAMMER_SH" --version 2>&1)
    assert_contains "$output" "hammer.sh version" "Should show version"
}

# Test: list templates
test_list_templates() {
    output=$("$HAMMER_SH" --list 2>&1)
    assert_contains "$output" "Available templates" "Should show available templates header"
    assert_contains "$output" "example-template" "Should list example-template"
}

# Test: fail without template name
test_fail_without_template_name() {
    set +e
    output=$("$HAMMER_SH" 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should exit with error code 1"
    assert_contains "$output" "Template name is required" "Should show template name required error"
}

# Test: fail with unknown option
test_fail_with_unknown_option() {
    set +e
    output=$("$HAMMER_SH" --unknown-option 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should exit with error code 1"
    assert_contains "$output" "Unknown option" "Should show unknown option error"
}

# Test: accept force flag
test_accept_force_flag() {
    setup
    
    set +e
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/test1" --yes --force >/dev/null 2>&1
    exit_code=$?
    set -e
    
    assert_exit_code 0 "$exit_code" "Should accept --force flag"
    
    teardown
}

# Test: accept yes flag
test_accept_yes_flag() {
    setup
    
    output=$("$HAMMER_SH" example-template "$TEST_ENV_DIR/test2" --yes 2>&1)
    
    assert_contains "$output" "Using default values" "Should use default values with --yes"
    assert_file_exists "$TEST_ENV_DIR/test2/README.md" "Should create README.md"
    
    teardown
}

# Test: accept variable flag
test_accept_variable_flag() {
    setup
    
    set +e
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/test3" \
        -v project_name="TestProject" \
        -v author="TestAuthor" \
        --yes >/dev/null 2>&1
    exit_code=$?
    set -e
    
    assert_exit_code 0 "$exit_code" "Should accept -v flag"
    assert_file_exists "$TEST_ENV_DIR/test3/README.md" "Should create README.md"
    
    teardown
}

# Test: fail with invalid variable format
test_fail_with_invalid_variable_format() {
    setup
    
    set +e
    output=$("$HAMMER_SH" example-template "$TEST_ENV_DIR/test4" -v invalid 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should exit with error"
    assert_contains "$output" "Invalid variable format" "Should show invalid format error"
    
    teardown
}

# Test: accept output directory flag
test_accept_output_directory_flag() {
    setup
    
    "$HAMMER_SH" example-template -o "$TEST_ENV_DIR/test5" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/test5/README.md" "Should create README.md in output dir"
    
    teardown
}

# Test: script is executable
test_script_is_executable() {
    assert_true "[[ -x '$HAMMER_SH' ]]" "hammer.sh should be executable"
}

# Run all tests
run_tests() {
    test_show_help_message
    test_show_version
    test_list_templates
    test_fail_without_template_name
    test_fail_with_unknown_option
    test_accept_force_flag
    test_accept_yes_flag
    test_accept_variable_flag
    test_fail_with_invalid_variable_format
    test_accept_output_directory_flag
    test_script_is_executable
}

export -f run_tests
