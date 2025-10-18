#!/usr/bin/env bash
# Test suite for arty CLI interface and commands

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTY_SH="${SCRIPT_DIR}/../arty.sh"

# Source test helpers - they are exported by run-all-tests.sh
# but we check if they exist as functions, if not we're running standalone
if ! declare -f assert_contains > /dev/null; then
    echo "Error: Test helpers not loaded. This test must be run via judge.sh"
    exit 1
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

# Test: arty without arguments shows usage
test_no_args_shows_usage() {
    setup
    
    output=$(bash "$ARTY_SH" 2>&1)
    
    assert_contains "$output" "USAGE:" "Should show usage"
    assert_contains "$output" "COMMANDS:" "Should show commands"
    
    teardown
}

# Test: arty help shows usage
test_help_command() {
    setup
    
    output=$(bash "$ARTY_SH" help 2>&1)
    
    assert_contains "$output" "USAGE:" "Help should show usage"
    assert_contains "$output" "COMMANDS:" "Help should show commands"
    
    teardown
}

# Test: arty --help shows usage
test_help_flag() {
    setup
    
    output=$(bash "$ARTY_SH" --help 2>&1)
    
    assert_contains "$output" "USAGE:" "--help flag should show usage"
    
    teardown
}

# Test: arty -h shows usage
test_help_short_flag() {
    setup
    
    output=$(bash "$ARTY_SH" -h 2>&1)
    
    assert_contains "$output" "USAGE:" "-h flag should show usage"
    
    teardown
}

# Test: unknown command shows error
test_unknown_command() {
    setup
    
    set +e
    bash "$ARTY_SH" nonexistent-command > /dev/null 2>&1
    exit_code=$?
    set -e
    
    # Should either show error or try to run as script
    # Since no arty.yml exists, should show error
    assert_true "[[ $exit_code -ne 0 ]]" "Unknown command should fail"
    
    teardown
}

# Test: remove command requires library name
test_remove_requires_name() {
    setup
    
    output=$(bash "$ARTY_SH" remove 2>&1 || true)
    
    assert_contains "$output" "Library name required" "Should require library name"
    
    teardown
}

# Test: rm alias works
test_rm_alias() {
    setup
    
    output=$(bash "$ARTY_SH" rm 2>&1 || true)
    
    assert_contains "$output" "Library name required" "rm alias should require library name"
    
    teardown
}

# Test: remove non-existent library fails
test_remove_nonexistent() {
    setup
    
    mkdir -p "$ARTY_HOME/libs"
    output=$(bash "$ARTY_SH" remove nonexistent 2>&1 || true)
    
    assert_contains "$output" "not found" "Should report library not found"
    
    teardown
}

# Test: source command requires library name
test_source_requires_name() {
    setup
    
    output=$(bash "$ARTY_SH" source 2>&1 || true)
    
    assert_contains "$output" "Library name required" "Source should require library name"
    
    teardown
}

# Test: usage shows all major commands
test_usage_shows_commands() {
    setup
    
    output=$(bash "$ARTY_SH" help 2>&1)
    
    # Check for all major commands
    assert_contains "$output" "install" "Should document install command"
    assert_contains "$output" "deps" "Should document deps command"
    assert_contains "$output" "list" "Should document list command"
    assert_contains "$output" "remove" "Should document remove command"
    assert_contains "$output" "init" "Should document init command"
    assert_contains "$output" "source" "Should document source command"
    assert_contains "$output" "exec" "Should document exec command"
    assert_contains "$output" "help" "Should document help command"
    
    teardown
}

# Test: usage shows examples
test_usage_shows_examples() {
    setup
    
    output=$(bash "$ARTY_SH" help 2>&1)
    
    assert_contains "$output" "EXAMPLES:" "Help should show examples section"
    
    teardown
}

# Test: usage shows environment variables
test_usage_shows_environment() {
    setup
    
    output=$(bash "$ARTY_SH" help 2>&1)
    
    assert_contains "$output" "ENVIRONMENT:" "Should have ENVIRONMENT section"
    assert_contains "$output" "ARTY_HOME" "Should mention ARTY_HOME variable"
    
    teardown
}

# Test: usage shows project structure
test_usage_shows_structure() {
    setup
    
    output=$(bash "$ARTY_SH" help 2>&1)
    
    assert_contains "$output" "PROJECT STRUCTURE:" "Should have PROJECT STRUCTURE section"
    
    teardown
}

# Test: list works with ls alias
test_list_ls_alias() {
    setup
    
    mkdir -p "$ARTY_HOME/libs"
    output1=$(bash "$ARTY_SH" list 2>&1)
    output2=$(bash "$ARTY_SH" ls 2>&1)
    
    # Both should produce similar output
    assert_contains "$output1" "libraries" "list command should show libraries"
    assert_contains "$output2" "libraries" "ls alias should show libraries"
    
    teardown
}

# Test: command parsing is case-sensitive
test_command_case_sensitive() {
    setup
    
    # HELP (uppercase) should not work
    set +e
    bash "$ARTY_SH" HELP > /dev/null 2>&1
    exit_code=$?
    set -e
    
    # Should fail as unknown command (unless there's a script named HELP)
    assert_true "[[ $exit_code -ne 0 ]]" "Case sensitive command should fail"
    
    teardown
}

# Run all tests
run_tests() {
    log_section "CLI Interface Tests"
    
    test_no_args_shows_usage
    test_help_command
    test_help_flag
    test_help_short_flag
    test_unknown_command
    test_remove_requires_name
    test_rm_alias
    test_remove_nonexistent
    test_source_requires_name
    test_usage_shows_commands
    test_usage_shows_examples
    test_usage_shows_environment
    test_usage_shows_structure
    test_list_ls_alias
    test_command_case_sensitive
    
    print_test_summary
    return $?  # Return the exit code from print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    exit $?  # Exit with the return code from run_tests
fi
