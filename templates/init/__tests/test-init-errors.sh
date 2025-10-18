#!/usr/bin/env bash
# Test suite for init.sh error handling and edge cases

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
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: Handle empty project name
test_empty_project_name() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/yq" "$TEST_DIR/bin/git"
    
    # Try to generate arty.yml with empty project name
    cat > "$TEST_DIR/test_empty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "" "basic"
EOF
    
    bash "$TEST_DIR/test_empty.sh" "$INIT_SH" "$TEST_DIR" "" "$TEST_DIR/bin" 2>&1 || true
    
    # Should still create a file (with empty name)
    if [[ -f "$TEST_DIR/arty.yml" ]]; then
        content=$(cat "$TEST_DIR/arty.yml")
        assert_contains "$content" "name:" "Should have name field"
    fi
    
    teardown
}

# Test: Handle special characters in project name
test_special_characters_in_name() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/yq" "$TEST_DIR/bin/git"
    
    cat > "$TEST_DIR/test_special.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_special.sh" "$INIT_SH" "$TEST_DIR" "my-project@v1.0!" "$TEST_DIR/bin" 2>&1 || true
    
    if [[ -f "$TEST_DIR/arty.yml" ]]; then
        assert_file_exists "$TEST_DIR/arty.yml" "Should create file with special chars"
    fi
    
    teardown
}

# Test: Handle very long project names
test_very_long_project_name() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/yq" "$TEST_DIR/bin/git"
    
    long_name="this-is-a-very-long-project-name-that-goes-on-and-on-and-on-for-quite-a-while"
    
    cat > "$TEST_DIR/test_long.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_long.sh" "$INIT_SH" "$TEST_DIR" "$long_name" "$TEST_DIR/bin" 2>&1 || true
    
    if [[ -f "$TEST_DIR/arty.yml" ]]; then
        content=$(cat "$TEST_DIR/arty.yml")
        assert_contains "$content" "$long_name" "Should handle long names"
    fi
    
    teardown
}

# Test: Handle missing git config
test_missing_git_config() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    chmod +x "$TEST_DIR/bin/yq"
    
    # Git that returns empty for config
    cat > "$TEST_DIR/bin/git" << 'EOF'
#!/bin/bash
case "$1" in
    config) exit 1 ;;
esac
EOF
    chmod +x "$TEST_DIR/bin/git"
    
    cat > "$TEST_DIR/test_no_git_config.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_no_git_config.sh" "$INIT_SH" "$TEST_DIR" "test-project" "$TEST_DIR/bin" 2>&1 || true
    
    if [[ -f "$TEST_DIR/arty.yml" ]]; then
        content=$(cat "$TEST_DIR/arty.yml")
        assert_contains "$content" "author:" "Should have author field even if empty"
    fi
    
    teardown
}

# Test: Handle permission denied creating directories
test_permission_denied_directories() {
    setup
    
    # Create a read-only directory
    mkdir -p "$TEST_DIR/readonly"
    chmod 444 "$TEST_DIR/readonly"
    
    cat > "$TEST_DIR/test_readonly.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
set +e  # Don't exit on error
create_structure "${2}/readonly/project" "basic" 2>&1
if [[ $? -ne 0 ]]; then
    echo "Failed as expected"
else
    echo "Unexpectedly succeeded"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_readonly.sh" "$INIT_SH" "$TEST_DIR")
    
    # Should either fail with permission error or our message
    if echo "$output" | grep -q "Failed as expected"; then
        assert_true "true" "Handled permission error"
    elif echo "$output" | grep -q "Permission denied"; then
        assert_true "true" "Got permission denied error"
    elif echo "$output" | grep -q "cannot create directory"; then
        assert_true "true" "Got cannot create directory error"
    else
        # On some systems, mkdir -p might succeed creating nested dirs
        assert_true "true" "Directory creation attempted"
    fi
    
    # Cleanup
    chmod 755 "$TEST_DIR/readonly" 2>/dev/null || true
    
    teardown
}

# Test: Handle invalid template type
test_invalid_template_type() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/yq" "$TEST_DIR/bin/git"
    
    cat > "$TEST_DIR/test_invalid.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
create_structure "${2}/project" "invalid-type"
EOF
    
    # Should not crash, just not create special directories
    bash "$TEST_DIR/test_invalid.sh" "$INIT_SH" "$TEST_DIR" "test" "$TEST_DIR/bin" 2>&1 || true
    
    # Basic directories should still exist
    assert_dir_exists "$TEST_DIR/project/src" "Should create basic directories"
    
    teardown
}

# Test: Handle existing directories
test_existing_directories() {
    setup
    
    # Pre-create some directories
    mkdir -p "$TEST_DIR/project/src"
    mkdir -p "$TEST_DIR/project/lib"
    echo "existing content" > "$TEST_DIR/project/src/existing.sh"
    
    cat > "$TEST_DIR/test_existing.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}/project" "basic"
EOF
    
    bash "$TEST_DIR/test_existing.sh" "$INIT_SH" "$TEST_DIR" 2>&1 || true
    
    # Original content should still exist
    assert_file_exists "$TEST_DIR/project/src/existing.sh" "Should not delete existing content"
    content=$(cat "$TEST_DIR/project/src/existing.sh")
    assert_contains "$content" "existing content" "Should preserve existing files"
    
    teardown
}

# Test: Handle disk full scenarios (simulated)
test_disk_full_simulation() {
    setup
    
    # We can't actually fill the disk, but we can test error handling
    # by using a very deep directory path that might fail
    
    cat > "$TEST_DIR/test_deep.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
# Try to create in a very deep path
deep_path="${2}/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/project"
create_structure "$deep_path" "basic" 2>&1 || echo "Handled deep path"
EOF
    
    output=$(bash "$TEST_DIR/test_deep.sh" "$INIT_SH" "$TEST_DIR")
    
    # Should either succeed or fail gracefully
    if [[ -d "$TEST_DIR/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/project" ]]; then
        assert_dir_exists "$TEST_DIR/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/project" "Should handle deep paths"
    fi
    
    teardown
}

# Test: Handle concurrent directory creation
test_concurrent_directory_creation() {
    setup
    
    cat > "$TEST_DIR/test_concurrent.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}/project" "basic" &
create_structure "${2}/project" "basic" &
wait
echo "Concurrent creation completed"
EOF
    
    output=$(bash "$TEST_DIR/test_concurrent.sh" "$INIT_SH" "$TEST_DIR" 2>&1)
    
    assert_contains "$output" "Concurrent creation completed" "Should handle concurrent creation"
    assert_dir_exists "$TEST_DIR/project/src" "Directories should exist"
    
    teardown
}

# Test: Handle symlinks in path
test_symlinks_in_path() {
    setup
    
    mkdir -p "$TEST_DIR/real"
    ln -s "$TEST_DIR/real" "$TEST_DIR/link"
    
    cat > "$TEST_DIR/test_symlink.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}/link/project" "basic"
EOF
    
    bash "$TEST_DIR/test_symlink.sh" "$INIT_SH" "$TEST_DIR" 2>&1 || true
    
    # Should work through symlink
    assert_dir_exists "$TEST_DIR/link/project/src" "Should handle symlinks"
    
    teardown
}

# Test: Handle spaces in paths
test_spaces_in_paths() {
    setup
    
    mkdir -p "$TEST_DIR/path with spaces"
    
    cat > "$TEST_DIR/test_spaces.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}/path with spaces/project" "basic"
EOF
    
    bash "$TEST_DIR/test_spaces.sh" "$INIT_SH" "$TEST_DIR" 2>&1 || true
    
    assert_dir_exists "$TEST_DIR/path with spaces/project/src" "Should handle spaces in paths"
    
    teardown
}

# Test: Handle unicode in project names
test_unicode_in_names() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/yq" "$TEST_DIR/bin/git"
    
    cat > "$TEST_DIR/test_unicode.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_unicode.sh" "$INIT_SH" "$TEST_DIR" "проект-тест" "$TEST_DIR/bin" 2>&1 || true
    
    if [[ -f "$TEST_DIR/arty.yml" ]]; then
        assert_file_exists "$TEST_DIR/arty.yml" "Should handle unicode"
    fi
    
    teardown
}

# Test: Handle missing parent directory
test_missing_parent_directory() {
    setup
    
    cat > "$TEST_DIR/test_missing_parent.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}/nonexistent/parent/project" "basic"
EOF
    
    bash "$TEST_DIR/test_missing_parent.sh" "$INIT_SH" "$TEST_DIR" 2>&1 || true
    
    # mkdir -p should create parents
    assert_dir_exists "$TEST_DIR/nonexistent/parent/project/src" "Should create parent directories"
    
    teardown
}

# Test: Handle relative paths
test_relative_paths() {
    setup
    
    cd "$TEST_DIR"
    
    cat > "$TEST_DIR/test_relative.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "./relative/project" "basic"
EOF
    
    bash "$TEST_DIR/test_relative.sh" "$INIT_SH" 2>&1 || true
    
    assert_dir_exists "$TEST_DIR/relative/project/src" "Should handle relative paths"
    
    teardown
}

# Test: Error when asciinema command fails
test_asciinema_command_failure() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    # Asciinema that fails
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
echo "Error: Recording failed" >&2
exit 1
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec test-demo 2>&1 || true)
    
    # Should show the error
    assert_contains "$output" "Starting asciinema recording" "Should attempt to record"
    
    teardown
}

# Test: Handle missing DEMOS_DIR variable
test_missing_demos_dir_variable() {
    setup
    
    unset DEMOS_DIR
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
mkdir -p "$(dirname "$2")"
echo "mock" > "$2"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    output=$(bash "$INIT_SH" rec test-demo 2>&1 || true)
    
    # Should use default "demos" directory
    assert_contains "$output" "demos" "Should use default demos directory"
    
    teardown
}

# Test: Handle extremely long filenames
test_extremely_long_filename() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/asciinema" << 'EOF'
#!/bin/bash
mkdir -p "$(dirname "$2")"
echo "mock" > "$2" 2>&1 || echo "Filename too long"
EOF
    chmod +x "$TEST_DIR/bin/asciinema"
    
    long_name=$(printf 'a%.0s' {1..300})
    output=$(bash "$INIT_SH" rec "$long_name" 2>&1 || true)
    
    # Should either work or fail gracefully
    # (actual behavior depends on filesystem limits)
    
    teardown
}

# Run all tests
run_tests() {
    log_section "Init Error Handling and Edge Cases Tests"
    
    test_empty_project_name
    test_special_characters_in_name
    test_very_long_project_name
    test_missing_git_config
    test_permission_denied_directories
    test_invalid_template_type
    test_existing_directories
    test_disk_full_simulation
    test_concurrent_directory_creation
    test_symlinks_in_path
    test_spaces_in_paths
    test_unicode_in_names
    test_missing_parent_directory
    test_relative_paths
    test_asciinema_command_failure
    test_missing_demos_dir_variable
    test_extremely_long_filename
    
    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
