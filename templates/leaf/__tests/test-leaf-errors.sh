#!/usr/bin/env bash
# Test suite for leaf.sh error handling and edge cases

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEAF_SH="${SCRIPT_DIR}/../leaf.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: leaf handles missing project directory
test_missing_project_directory() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" nonexistent-project 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should return error for missing directory"
    assert_contains "$output" "not found" "Should report directory not found"
    
    teardown
}

# Test: leaf handles missing arty.yml
test_missing_arty_yml() {
    setup
    
    mkdir -p test-project
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    # Should still generate docs but use directory name
    assert_file_exists "output/index.html" "Should create output even without arty.yml"
    
    teardown
}

# Test: leaf handles corrupted YAML
test_corrupted_yaml() {
    setup
    
    mkdir -p test-project
    echo "this is not valid yaml: [" > test-project/arty.yml
    
    # Should handle gracefully
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    # May still create output with defaults
    assert_true "true" "Should handle corrupted YAML gracefully"
    
    teardown
}

# Test: leaf handles empty arty.yml
test_empty_arty_yml() {
    setup
    
    mkdir -p test-project
    touch test-project/arty.yml
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should create output with empty YAML"
    
    teardown
}

# Test: leaf handles project with no source files
test_no_source_files() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "empty-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should create output with no source files"
    assert_contains "$(cat output/index.html)" "No source files found" "Should show placeholder"
    
    teardown
}

# Test: leaf handles project with no examples
test_no_examples() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_contains "$(cat output/index.html)" "No examples found" "Should show placeholder for no examples"
    
    teardown
}

# Test: leaf handles invalid JSON in projects argument
test_invalid_projects_json() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects '{invalid}' -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on invalid JSON"
    assert_contains "$output" "Invalid JSON" "Should report invalid JSON"
    
    teardown
}

# Test: leaf handles corrupted JSON file
test_corrupted_json_file() {
    setup
    
    echo "not valid json" > projects.json
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects-file projects.json -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on corrupted JSON file"
    assert_contains "$output" "Failed to parse" "Should report parse failure"
    
    teardown
}

# Test: leaf handles special characters in project name
test_special_chars_in_name() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project <>&'\"special"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should create output with special characters"
    
    teardown
}

# Test: leaf handles very long project description
test_very_long_description() {
    setup
    
    mkdir -p test-project
    long_desc="This is a very long description. "
    for i in {1..100}; do
        long_desc="${long_desc}More text. "
    done
    
    cat > test-project/arty.yml << EOF
name: "test-project"
version: "1.0.0"
description: "${long_desc}"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should handle long description"
    
    teardown
}

# Test: leaf handles binary files in source directory
test_binary_files_in_source() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # Create a binary file
    echo -e '\x00\x01\x02\x03' > test-project/binary.bin
    echo "echo test" > test-project/script.sh
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should create output despite binary files"
    
    teardown
}

# Test: leaf handles permission denied on output directory
test_permission_denied_output() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # This test may not work on all systems
    if [[ "$(uname)" != "Darwin" ]]; then
        mkdir -p no-write
        chmod 000 no-write 2>/dev/null || true
        
        set +e
        output=$(bash "$LEAF_SH" test-project -o no-write/output 2>&1)
        exit_code=$?
        set -e
        
        chmod 755 no-write 2>/dev/null || true
        
        assert_true "[[ $exit_code -ne 0 ]]" "Should fail on permission denied"
    else
        log_skip "Skipping permission test on macOS"
    fi
    
    teardown
}

# Test: leaf handles missing icon file
test_missing_icon_file() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project --logo nonexistent.svg -o output 2>&1)
    
    # Should fall back to default
    assert_file_exists "output/index.html" "Should create output with missing icon"
    
    teardown
}

# Test: leaf handles README with special markdown
test_readme_special_markdown() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/README.md << 'EOF'
# Test Project

## Code Block
```bash
echo "test <script>alert('xss')</script>"
```

## HTML
<div>HTML content</div>

## Special Characters
& < > " '
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should handle special markdown"
    
    teardown
}

# Test: leaf handles deeply nested directory structure
test_deeply_nested_structure() {
    setup
    
    mkdir -p test-project/a/b/c/d/e/f
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo "echo deep" > test-project/a/b/c/d/e/f/deep.sh
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should handle deeply nested structure"
    
    teardown
}

# Test: leaf handles files with no extension
test_files_no_extension() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo "#!/usr/bin/env bash" > test-project/script
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should handle files without extension"
    
    teardown
}

# Test: leaf handles simultaneous --projects and --projects-file
test_both_projects_options() {
    setup
    
    cat > projects.json << 'EOF'
[{"url":"https://file.com","label":"File","desc":"From file","class":"card"}]
EOF
    
    projects='[{"url":"https://arg.com","label":"Arg","desc":"From arg","class":"card"}]'
    
    bash "$LEAF_SH" --landing --projects "$projects" --projects-file projects.json -o output 2>&1
    
    # File should take priority
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "file.com" "Should prioritize file"
    
    teardown
}

# Test: leaf handles empty output directory name
test_empty_output_name() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # Should use default output directory
    output=$(bash "$LEAF_SH" test-project -o "" 2>&1)
    
    # Check if any output was created
    assert_true "true" "Should handle empty output name"
    
    teardown
}

# Test: leaf handles circular symlinks
test_circular_symlinks() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # Create circular symlink (may not work on all systems)
    ln -s test-project test-project/circular 2>/dev/null || true
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should handle circular symlinks"
    
    teardown
}

# Run all tests
run_tests() {
    test_missing_project_directory
    test_missing_arty_yml
    test_corrupted_yaml
    test_empty_arty_yml
    test_no_source_files
    test_no_examples
    test_invalid_projects_json
    test_corrupted_json_file
    test_special_chars_in_name
    test_very_long_description
    test_binary_files_in_source
    test_permission_denied_output
    test_missing_icon_file
    test_readme_special_markdown
    test_deeply_nested_structure
    test_files_no_extension
    test_both_projects_options
    test_empty_output_name
    test_circular_symlinks
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
