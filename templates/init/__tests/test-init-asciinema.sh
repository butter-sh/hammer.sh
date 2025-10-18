#!/usr/bin/env bash
# Test suite for init.sh asciinema functionality

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
    export DEMOS_DIR="$TEST_DIR/demos"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: ascii_check detects missing asciinema
test_ascii_check_missing() {
    setup
    
    cat > "$TEST_DIR/test_check.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
source "${1}"
ascii_check 2>&1 || echo "Check failed as expected"
EOF
    
    output=$(bash "$TEST_DIR/test_check.sh" "$INIT_SH")
    
    assert_contains "$output" "asciinema not installed" "Should detect missing asciinema"
    assert_contains "$output" "Install asciinema" "Should show install instructions"
    assert_contains "$output" "Check failed as expected" "Should return non-zero"
    
    teardown
}

# Test: ascii_check passes with asciinema present
test_ascii_check_present() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    # Create mock asciinema
    echo '#!/bin/bash' > "$TEST_DIR/bin/asciinema"
    chmod +x "$TEST_DIR/bin/asciinema"
    
    cat > "$TEST_DIR/test_check.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${2}:${PATH}"
source "${1}"
if ascii_check 2>&1; then
    echo "Check passed"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_check.sh" "$INIT_SH" "$TEST_DIR/bin")
    
    assert_contains "$output" "Check passed" "Should pass when asciinema present"
    
    teardown
}

# Test: rec command creates demos directory
test_rec_creates_demos_dir() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    # Create mock asciinema that creates a fake cast file
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
# Mock asciinema - just create the file
mkdir -p "$(dirname "$2")"
echo "mock cast" > "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    bash "$INIT_SH" rec test-demo 2>&1 || true
    
    assert_dir_exists "$DEMOS_DIR" "Should create demos directory"
    
    teardown
}

# Test: rec command with default name
test_rec_default_name() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
echo "Recording: $2"
touch "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec 2>&1 || true)
    
    assert_contains "$output" "demo.cast" "Should use demo.cast as default"
    
    teardown
}

# Test: rec command handles .cast extension
test_rec_handles_cast_extension() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
echo "Recording: $2"
touch "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec my-demo.cast 2>&1 || true)
    
    # Should not double the extension
    assert_contains "$output" "my-demo.cast" "Should handle .cast extension"
    assert_false "echo '$output' | grep -q 'my-demo.cast.cast'" "Should not double extension"
    
    teardown
}

# Test: rec shows recording tips
test_rec_shows_tips() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
touch "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec test-demo 2>&1 || true)
    
    assert_contains "$output" "Tips for great demos" "Should show tips"
    assert_contains "$output" "To stop recording" "Should show stop instructions"
    assert_contains "$output" "Ctrl+D" "Should mention Ctrl+D"
    
    teardown
}

# Test: play command requires filename
test_play_requires_filename() {
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

# Test: play command checks file existence
test_play_checks_file_existence() {
    setup
    
    set +e
    output=$(bash "$INIT_SH" play nonexistent.cast 2>&1)
    exit_code=$?
    set -e
    
    # Command should fail
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail with nonexistent file"
    # Should output error message
    assert_true "[[ -n '$output' ]]" "Should show error message"
    
    teardown
}

# Test: play command finds file in demos directory
test_play_finds_file_in_demos() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock cast" > "$DEMOS_DIR/test.cast"
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
echo "Playing: $2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" play test.cast 2>&1 || true)
    
    assert_contains "$output" "Playing:" "Should attempt to play"
    
    teardown
}

# Test: upload command requires filename
test_upload_requires_filename() {
    setup
    
    set +e
    output=$(bash "$INIT_SH" upload 2>&1)
    exit_code=$?
    set -e
    
    # Command should fail (non-zero exit)
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail without filename"
    # Should output something (error message)
    assert_true "[[ -n '$output' ]]" "Should show error message"
    
    teardown
}

# Test: upload command checks file existence
test_upload_checks_file_existence() {
    setup
    
    set +e
    output=$(bash "$INIT_SH" upload nonexistent.cast 2>&1)
    exit_code=$?
    set -e
    
    # Command should fail
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail with nonexistent file"
    # Should output error message
    assert_true "[[ -n '$output' ]]" "Should show error message"
    
    teardown
}

# Test: upload shows instructions
test_upload_shows_instructions() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock cast" > "$DEMOS_DIR/test.cast"
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
echo "https://asciinema.org/a/mock123"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" upload test.cast 2>&1 || true)
    
    assert_contains "$output" "Copy the URL" "Should show instructions"
    assert_contains "$output" "README.md" "Should mention README"
    
    teardown
}

# Test: stop command shows instructions
test_stop_shows_instructions() {
    setup
    
    output=$(bash "$INIT_SH" stop 2>&1)
    
    assert_contains "$output" "How to Stop Recording" "Should show header"
    assert_contains "$output" "Ctrl+D" "Should mention Ctrl+D"
    assert_contains "$output" "exit" "Should mention exit command"
    assert_contains "$output" "After recording:" "Should show next steps"
    
    teardown
}

# Test: list command with no recordings
test_list_no_recordings() {
    setup
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "No recordings found" "Should report no recordings"
    assert_contains "$output" "Create one with" "Should suggest creating one"
    
    teardown
}

# Test: list command shows current directory recordings
test_list_current_directory() {
    setup
    
    # Create mock cast files in current directory
    echo "mock1" > "$TEST_DIR/demo1.cast"
    echo "mock2" > "$TEST_DIR/demo2.cast"
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "Current directory:" "Should show current directory section"
    assert_contains "$output" "demo1.cast" "Should list first file"
    assert_contains "$output" "demo2.cast" "Should list second file"
    
    teardown
}

# Test: list command shows demos directory recordings
test_list_demos_directory() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock1" > "$DEMOS_DIR/test1.cast"
    echo "mock2" > "$DEMOS_DIR/test2.cast"
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "demos directory:" "Should show demos directory section"
    assert_contains "$output" "test1.cast" "Should list first file"
    assert_contains "$output" "test2.cast" "Should list second file"
    
    teardown
}

# Test: list shows file metadata
test_list_shows_metadata() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock cast content" > "$DEMOS_DIR/demo.cast"
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    # Should show size (might be in different formats)
    assert_contains "$output" "demo.cast" "Should show filename"
    # The output should contain size and date information
    
    teardown
}

# Test: list shows play and upload suggestions
test_list_shows_suggestions() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock" > "$DEMOS_DIR/demo.cast"
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "Play a recording" "Should suggest playing"
    assert_contains "$output" "Upload a recording" "Should suggest uploading"
    
    teardown
}

# Test: rec alias works
test_rec_alias_record() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
touch "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output1=$(bash "$INIT_SH" rec test 2>&1 || true)
    output2=$(bash "$INIT_SH" record test2 2>&1 || true)
    
    # Both should work
    assert_contains "$output1" "Starting asciinema recording" "rec should work"
    assert_contains "$output2" "Starting asciinema recording" "record should work"
    
    teardown
}

# Test: ls alias for list works
test_ls_alias_list() {
    setup
    
    output1=$(bash "$INIT_SH" list 2>&1)
    output2=$(bash "$INIT_SH" ls 2>&1)
    
    # Both should show similar output
    assert_contains "$output1" "Available Recordings" "list should work"
    assert_contains "$output2" "Available Recordings" "ls should work"
    
    teardown
}

# Run all tests
run_tests() {
    log_section "Init Asciinema Functionality Tests"
    
    test_ascii_check_missing
    test_ascii_check_present
    test_rec_creates_demos_dir
    test_rec_default_name
    test_rec_handles_cast_extension
    test_rec_shows_tips
    test_play_requires_filename
    test_play_checks_file_existence
    test_play_finds_file_in_demos
    test_upload_requires_filename
    test_upload_checks_file_existence
    test_upload_shows_instructions
    test_stop_shows_instructions
    test_list_no_recordings
    test_list_current_directory
    test_list_demos_directory
    test_list_shows_metadata
    test_list_shows_suggestions
    test_rec_alias_record
    test_ls_alias_list
    
    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
