#!/usr/bin/env bash
# Integration tests for init.sh - testing complete workflows

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
    
    cat > "$TEST_DIR/bin/yq" << 'EOF'
#!/bin/bash
echo "yq version 4.0.0"
EOF
    chmod +x "$TEST_DIR/bin/yq"
    
    cat > "$TEST_DIR/bin/git" << 'EOF'
#!/bin/bash
case "$1" in
    config)
        case "$2" in
            user.name) echo "Test User" ;;
            user.email) echo "test@example.com" ;;
        esac
        ;;
    init) 
        echo "Initialized empty Git repository"
        mkdir -p .git
        ;;
    *)
        echo "git $*"
        ;;
esac
EOF
    chmod +x "$TEST_DIR/bin/git"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
case "$1" in
    rec)
        echo "Recording to $2"
        mkdir -p "$(dirname "$2")"
        echo "mock recording" > "$2"
        ;;
    play)
        echo "Playing $2"
        ;;
    upload)
        echo "Uploading $2"
        echo "https://asciinema.org/a/mock123"
        ;;
esac
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: Complete asciinema workflow
test_complete_asciinema_workflow() {
    setup
    
    # Record a demo
    output1=$(bash "$INIT_SH" rec my-demo 2>&1)
    assert_contains "$output1" "Starting asciinema recording" "Should start recording"
    assert_file_exists "$DEMOS_DIR/my-demo.cast" "Should create cast file"
    
    # List recordings
    output2=$(bash "$INIT_SH" list 2>&1)
    assert_contains "$output2" "my-demo.cast" "Should list the recording"
    
    # Play recording
    output3=$(bash "$INIT_SH" play my-demo.cast 2>&1)
    assert_contains "$output3" "Playing:" "Should play recording"
    
    # Upload recording
    output4=$(bash "$INIT_SH" upload my-demo.cast 2>&1)
    assert_contains "$output4" "Uploading:" "Should upload recording"
    assert_contains "$output4" "asciinema.org" "Should show URL"
    
    teardown
}

# Test: Multiple recordings workflow
test_multiple_recordings_workflow() {
    setup
    
    # Create multiple recordings
    bash "$INIT_SH" rec demo1 2>&1
    bash "$INIT_SH" rec demo2 2>&1
    bash "$INIT_SH" rec demo3 2>&1
    
    # List should show all
    output=$(bash "$INIT_SH" list 2>&1)
    assert_contains "$output" "demo1.cast" "Should show demo1"
    assert_contains "$output" "demo2.cast" "Should show demo2"
    assert_contains "$output" "demo3.cast" "Should show demo3"
    
    teardown
}

# Test: Recording in both current and demos directory
test_recordings_in_multiple_locations() {
    setup
    
    # Record in demos directory (default)
    bash "$INIT_SH" rec demo-in-demos 2>&1
    assert_file_exists "$DEMOS_DIR/demo-in-demos.cast" "Should create in demos"
    
    # Create a recording directly in current dir
    echo "mock" > "$TEST_DIR/demo-in-current.cast"
    
    # List should show both locations
    output=$(bash "$INIT_SH" list 2>&1)
    assert_contains "$output" "Current directory:" "Should show current dir section"
    assert_contains "$output" "demos directory:" "Should show demos dir section"
    assert_contains "$output" "demo-in-current.cast" "Should show current dir file"
    assert_contains "$output" "demo-in-demos.cast" "Should show demos dir file"
    
    teardown
}

# Test: Stop command provides clear instructions
test_stop_command_workflow() {
    setup
    
    output=$(bash "$INIT_SH" stop 2>&1)
    
    assert_contains "$output" "How to Stop Recording" "Should show title"
    assert_contains "$output" "Ctrl+D" "Should explain Ctrl+D"
    assert_contains "$output" "exit" "Should explain exit"
    assert_contains "$output" "Review:" "Should show next steps"
    assert_contains "$output" "init.sh play" "Should suggest playing back"
    assert_contains "$output" "init.sh upload" "Should suggest uploading"
    
    teardown
}

# Test: Recording with .cast extension handling
test_cast_extension_handling_workflow() {
    setup
    
    # Record with .cast extension provided
    bash "$INIT_SH" rec my-demo.cast 2>&1
    
    # Should create file without double extension
    assert_file_exists "$DEMOS_DIR/my-demo.cast" "Should create file"
    assert_false "[[ -f '$DEMOS_DIR/my-demo.cast.cast' ]]" "Should not double extension"
    
    teardown
}

# Test: Playing from different directories
test_play_from_different_dirs_workflow() {
    setup
    
    # Create recordings in both locations
    echo "mock1" > "$TEST_DIR/current.cast"
    mkdir -p "$DEMOS_DIR"
    echo "mock2" > "$DEMOS_DIR/demos.cast"
    
    # Play from current directory
    output1=$(bash "$INIT_SH" play current.cast 2>&1)
    assert_contains "$output1" "Playing:" "Should play from current dir"
    
    # Play from demos directory (without path)
    output2=$(bash "$INIT_SH" play demos.cast 2>&1)
    assert_contains "$output2" "Playing:" "Should find in demos dir"
    
    teardown
}

# Test: Upload from different directories
test_upload_from_different_dirs_workflow() {
    setup
    
    # Create recordings in both locations
    echo "mock1" > "$TEST_DIR/current.cast"
    mkdir -p "$DEMOS_DIR"
    echo "mock2" > "$DEMOS_DIR/demos.cast"
    
    # Upload from current directory
    output1=$(bash "$INIT_SH" upload current.cast 2>&1)
    assert_contains "$output1" "Uploading:" "Should upload from current dir"
    
    # Upload from demos directory (without path)
    output2=$(bash "$INIT_SH" upload demos.cast 2>&1)
    assert_contains "$output2" "Uploading:" "Should find in demos dir"
    
    teardown
}

# Test: Error handling for missing files
test_error_handling_missing_files() {
    setup
    
    # Try to play non-existent file
    output1=$(bash "$INIT_SH" play nonexistent.cast 2>&1 || true)
    assert_contains "$output1" "File not found" "Should report file not found for play"
    assert_contains "$output1" "Try: init.sh list" "Should suggest list command"
    
    # Try to upload non-existent file
    output2=$(bash "$INIT_SH" upload nonexistent.cast 2>&1 || true)
    assert_contains "$output2" "File not found" "Should report file not found for upload"
    
    teardown
}

# Test: Error handling for missing arguments
test_error_handling_missing_arguments() {
    setup
    
    # Play without filename
    set +e
    output1=$(bash "$INIT_SH" play 2>&1)
    exit_code1=$?
    set -e
    assert_true "[[ $exit_code1 -ne 0 ]]" "Play should fail without filename"
    assert_true "[[ -n '$output1' ]]" "Play should show error message"
    
    # Upload without filename
    set +e
    output2=$(bash "$INIT_SH" upload 2>&1)
    exit_code2=$?
    set -e
    assert_true "[[ $exit_code2 -ne 0 ]]" "Upload should fail without filename"
    assert_true "[[ -n '$output2' ]]" "Upload should show error message"
    
    teardown
}

# Test: List with empty directories
test_list_empty_directories() {
    setup
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "No recordings found" "Should report no recordings"
    assert_contains "$output" "Create one with:" "Should suggest creating"
    assert_contains "$output" "init.sh rec" "Should show rec command"
    
    teardown
}

# Test: Recording overwrites existing files
test_recording_overwrites() {
    setup
    
    # Create initial recording
    bash "$INIT_SH" rec test-demo 2>&1
    first_content=$(cat "$DEMOS_DIR/test-demo.cast")
    
    # Modify the mock to produce different content
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
case "$1" in
    rec)
        mkdir -p "$(dirname "$2")"
        echo "new recording content" > "$2"
        ;;
esac
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    # Record again with same name
    bash "$INIT_SH" rec test-demo 2>&1
    second_content=$(cat "$DEMOS_DIR/test-demo.cast")
    
    # Content should be different (overwritten)
    assert_false "[[ '$first_content' == '$second_content' ]]" "Should overwrite recording"
    
    teardown
}

# Test: Help displays all asciinema commands
test_help_shows_asciinema_commands() {
    setup
    
    output=$(bash "$INIT_SH" --help 2>&1)
    
    assert_contains "$output" "ASCIINEMA COMMANDS:" "Should show asciinema section"
    assert_contains "$output" "rec" "Should show rec command"
    assert_contains "$output" "play" "Should show play command"
    assert_contains "$output" "upload" "Should show upload command"
    assert_contains "$output" "stop" "Should show stop command"
    assert_contains "$output" "list" "Should show list command"
    
    teardown
}

# Test: Version shows asciinema feature
test_version_shows_asciinema() {
    setup
    
    output=$(bash "$INIT_SH" --version 2>&1)
    
    assert_contains "$output" "asciinema" "Should mention asciinema"
    assert_contains "$output" "demo recording" "Should mention demo recording"
    
    teardown
}

# Test: Aliases work correctly
test_command_aliases() {
    setup
    
    # Test rec/record aliases
    output1=$(bash "$INIT_SH" rec test1 2>&1)
    output2=$(bash "$INIT_SH" record test2 2>&1)
    
    assert_contains "$output1" "Starting asciinema recording" "rec should work"
    assert_contains "$output2" "Starting asciinema recording" "record should work"
    
    # Test list/ls aliases
    output3=$(bash "$INIT_SH" list 2>&1)
    output4=$(bash "$INIT_SH" ls 2>&1)
    
    assert_contains "$output3" "Available Recordings" "list should work"
    assert_contains "$output4" "Available Recordings" "ls should work"
    
    teardown
}

# Test: Recording tips are shown
test_recording_tips_shown() {
    setup
    
    output=$(bash "$INIT_SH" rec my-demo 2>&1)
    
    assert_contains "$output" "Tips for great demos" "Should show tips header"
    assert_contains "$output" "Clear your terminal" "Should suggest clearing"
    assert_contains "$output" "Type commands slowly" "Should suggest slow typing"
    assert_contains "$output" "Add pauses" "Should suggest pauses"
    assert_contains "$output" "To stop recording:" "Should explain stopping"
    
    teardown
}

# Test: Upload shows README instructions
test_upload_shows_readme_instructions() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "mock" > "$DEMOS_DIR/demo.cast"
    
    output=$(bash "$INIT_SH" upload demo.cast 2>&1)
    
    assert_contains "$output" "Copy the URL" "Should prompt to copy URL"
    assert_contains "$output" "README.md" "Should mention README"
    assert_contains "$output" "<a href=" "Should show HTML embed code"
    assert_contains "$output" "asciinema.org/a/" "Should show URL pattern"
    
    teardown
}

# Test: List shows file metadata
test_list_shows_file_metadata() {
    setup
    
    mkdir -p "$DEMOS_DIR"
    echo "some content here" > "$DEMOS_DIR/demo.cast"
    
    output=$(bash "$INIT_SH" list 2>&1)
    
    assert_contains "$output" "demo.cast" "Should show filename"
    # File size and date info should be present (format varies by system)
    
    teardown
}

# Test: Missing asciinema shows install instructions
test_missing_asciinema_shows_instructions() {
    setup
    
    # Remove asciinema from path
    rm "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec demo 2>&1 || true)
    
    assert_contains "$output" "asciinema not installed" "Should report missing"
    assert_contains "$output" "brew install asciinema" "Should show macOS install"
    assert_contains "$output" "apt-get install asciinema" "Should show Ubuntu install"
    assert_contains "$output" "pip3 install asciinema" "Should show pip install"
    assert_contains "$output" "docs.asciinema.org" "Should link to docs"
    
    teardown
}

# Run all tests
run_tests() {
    log_section "Init Integration Tests"
    
    test_complete_asciinema_workflow
    test_multiple_recordings_workflow
    test_recordings_in_multiple_locations
    test_stop_command_workflow
    test_cast_extension_handling_workflow
    test_play_from_different_dirs_workflow
    test_upload_from_different_dirs_workflow
    test_error_handling_missing_files
    test_error_handling_missing_arguments
    test_list_empty_directories
    test_recording_overwrites
    test_help_shows_asciinema_commands
    test_version_shows_asciinema
    test_command_aliases
    test_recording_tips_shown
    test_upload_shows_readme_instructions
    test_list_shows_file_metadata
    test_missing_asciinema_shows_instructions
    
    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
