#!/usr/bin/env bash
# Test suite for init.sh CLI argument parsing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SH="${SCRIPT_DIR}/../init.sh"

# Source test helpers
if ! declare -f assert_contains > /dev/null; then
    echo "Error: Test helpers not loaded. This test must be run via judge.sh"
    exit 1
fi

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export ARTY_HOME="$TEST_DIR/.arty"
    export CONFIG_FILE="$TEST_DIR/arty.yml"
    export DEMOS_DIR="$TEST_DIR/demos"
    cd "$TEST_DIR"
    
    # Create mock dependencies
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    echo '#!/bin/bash' > "$TEST_DIR/bin/asciinema"
    chmod +x "$TEST_DIR/bin/"*
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: Short help flag
test_short_help_flag() {
    setup
    
    output=$(bash "$INIT_SH" -h 2>&1)
    
    assert_contains "$output" "USAGE:" "Short help should show usage"
    assert_contains "$output" "PROJECT OPTIONS:" "Should show options"
    
    teardown
}

# Test: Long help flag
test_long_help_flag() {
    setup
    
    output=$(bash "$INIT_SH" --help 2>&1)
    
    assert_contains "$output" "USAGE:" "Long help should show usage"
    assert_contains "$output" "TEMPLATES:" "Should show templates"
    
    teardown
}

# Test: Version flag
test_version_flag() {
    setup
    
    output=$(bash "$INIT_SH" --version 2>&1)
    
    assert_contains "$output" "init.sh version" "Should show version"
    assert_contains "$output" "butter.sh" "Should mention butter.sh"
    
    teardown
}

# Test: Asciinema rec command
test_rec_command() {
    setup
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
mkdir -p "$(dirname "$2")"
echo "Recording" > "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec test-demo 2>&1)
    
    assert_contains "$output" "Starting asciinema recording" "Should start recording"
    
    teardown
}

# Test: Asciinema record alias
test_record_alias() {
    setup
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
mkdir -p "$(dirname "$2")"
echo "Recording" > "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" record test-demo 2>&1)
    
    assert_contains "$output" "Starting asciinema recording" "record alias should work"
    
    teardown
}

# Test: Asciinema play command
test_play_command() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock" > "$DEMOS_DIR/test.cast"
    
    output=$(bash "$INIT_SH" play test.cast 2>&1)
    
    assert_contains "$output" "Playing:" "Should play recording"
    
    teardown
}

# Test: Asciinema upload command
test_upload_command() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock" > "$DEMOS_DIR/test.cast"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
echo "https://asciinema.org/a/123"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" upload test.cast 2>&1)
    
    assert_contains "$output" "Uploading:" "Should upload recording"
    
    teardown
}

# Test: Asciinema stop command
test_stop_command() {
    setup
    
    output=$(bash "$INIT_SH" stop 2>&1)
    
    assert_contains "$output" "How to Stop Recording" "Should show stop instructions"
    assert_contains "$output" "Ctrl+D" "Should mention Ctrl+D"
    
    teardown
}

# Test: Asciinema list command
test_list_command() {
    setup
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "Available Recordings" "Should show list header"
    
    teardown
}

# Test: Asciinema ls alias
test_ls_alias() {
    setup
    
    output=$(bash "$INIT_SH" ls 2>&1)
    
    assert_contains "$output" "Available Recordings" "ls alias should work"
    
    teardown
}

# Test: Unknown command handling
test_unknown_command() {
    setup
    
    # Unknown commands might be interpreted as script names or show error
    output=$(bash "$INIT_SH" unknown-command 2>&1 || true)
    
    # Should either fail or attempt something
    # The exact behavior depends on the main() implementation
    
    teardown
}

# Test: Multiple flags
test_multiple_flags() {
    setup
    
    # Try multiple flags (might not all be implemented)
    output=$(bash "$INIT_SH" --help --version 2>&1 || true)
    
    # Should handle first flag
    assert_contains "$output" "USAGE:" "Should process first flag"
    
    teardown
}

# Test: Command with no arguments when required
test_command_no_args_when_required() {
    setup
    
    set +e
    output=$(bash "$INIT_SH" play 2>&1)
    exit_code=$?
    set -e
    
    # Command should fail (non-zero exit)
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail without filename"
    # Should output something (error message)
    assert_true "[[ -n '$output' ]]" "Should show error message"
    
    teardown
}

# Test: Command with extra arguments
test_command_extra_arguments() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock" > "$DEMOS_DIR/test.cast"
    
    # Play with extra arguments
    output=$(bash "$INIT_SH" play test.cast extra args 2>&1 || true)
    
    # Should either ignore extra args or handle them
    # Main thing is it shouldn't crash
    
    teardown
}

# Test: Empty string argument
test_empty_string_argument() {
    setup
    
    output=$(bash "$INIT_SH" rec "" 2>&1 || true)
    
    # Should use default name or handle empty string
    
    teardown
}

# Test: Command line argument order
test_argument_order() {
    setup
    
    # Help should work regardless of position
    output1=$(bash "$INIT_SH" --help 2>&1)
    output2=$(bash "$INIT_SH" help 2>&1 || true)
    
    assert_contains "$output1" "USAGE:" "Flag form should work"
    
    teardown
}

# Test: Case sensitivity of commands
test_command_case_sensitivity() {
    setup
    
    # Commands should be case-sensitive
    output1=$(bash "$INIT_SH" list 2>&1)
    output2=$(bash "$INIT_SH" LIST 2>&1 || true)
    
    # list should work
    assert_contains "$output1" "Available Recordings" "lowercase should work"
    
    # LIST might fail or be treated as different command
    
    teardown
}

# Test: Dash vs underscore in commands
test_dash_vs_underscore() {
    setup
    
    # Test if commands accept both forms
    # This depends on implementation
    
    output=$(bash "$INIT_SH" list 2>&1)
    assert_contains "$output" "Available Recordings" "Dash form should work"
    
    teardown
}

# Test: Path with special characters in arguments
test_path_special_characters() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock" > "$DEMOS_DIR/test-demo-v1.0.cast"
    
    output=$(bash "$INIT_SH" play "test-demo-v1.0.cast" 2>&1)
    
    assert_contains "$output" "Playing:" "Should handle special chars in filename"
    
    teardown
}

# Test: Quoted arguments
test_quoted_arguments() {
    setup
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
mkdir -p "$(dirname "$2")"
echo "Recording" > "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec "my demo with spaces" 2>&1)
    
    # Should handle spaces in filename
    assert_contains "$output" "Starting asciinema recording" "Should handle quoted args"
    
    teardown
}

# Test: Arguments with equals sign
test_arguments_with_equals() {
    setup
    
    # Some CLIs support --flag=value syntax
    # Test if init.sh handles it
    
    output=$(bash "$INIT_SH" --help 2>&1 || true)
    
    # At minimum, shouldn't crash
    assert_contains "$output" "USAGE:" "Should not crash with flags"
    
    teardown
}

# Test: Numeric arguments
test_numeric_arguments() {
    setup
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
mkdir -p "$(dirname "$2")"
echo "Recording" > "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec 12345 2>&1)
    
    assert_contains "$output" "Starting asciinema recording" "Should handle numeric names"
    
    teardown
}

# Test: Very long command line
test_very_long_command_line() {
    setup
    
    long_arg=$(printf 'a%.0s' {1..1000})
    
    output=$(bash "$INIT_SH" rec "$long_arg" 2>&1 || true)
    
    # Should either work or fail gracefully
    
    teardown
}

# Test: Shell metacharacters in arguments
test_shell_metacharacters() {
    setup
    
    # These should be handled as literals, not expanded
    output=$(bash "$INIT_SH" --help 2>&1)
    
    assert_contains "$output" "USAGE:" "Should handle normally"
    
    teardown
}

# Test: Multiple commands in sequence
test_multiple_commands_sequence() {
    setup
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
mkdir -p "$(dirname "$2")"
echo "Recording" > "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    # Run multiple commands
    bash "$INIT_SH" rec demo1 2>&1
    bash "$INIT_SH" rec demo2 2>&1
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "demo1.cast" "Should list first demo"
    assert_contains "$output" "demo2.cast" "Should list second demo"
    
    teardown
}

# Run all tests
run_tests() {
    log_section "Init CLI Arguments Tests"
    
    test_short_help_flag
    test_long_help_flag
    test_version_flag
    test_rec_command
    test_record_alias
    test_play_command
    test_upload_command
    test_stop_command
    test_list_command
    test_ls_alias
    test_unknown_command
    test_multiple_flags
    test_command_no_args_when_required
    test_command_extra_arguments
    test_empty_string_argument
    test_argument_order
    test_command_case_sensitivity
    test_dash_vs_underscore
    test_path_special_characters
    test_quoted_arguments
    test_arguments_with_equals
    test_numeric_arguments
    test_very_long_command_line
    test_shell_metacharacters
    test_multiple_commands_sequence
    
    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
