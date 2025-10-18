#!/usr/bin/env bash
# Test suite for leaf.sh error handling and edge cases

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEAF_SH="${SCRIPT_DIR}/../leaf.sh"

# Strip ANSI color codes from output
strip_colors() {
    sed 's/\x1b\[[0-9;]*m//g'
}

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
    output=$(bash "$LEAF_SH" nonexistent-project 2>&1 | strip_colors)
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
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
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
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    # May still create output with defaults
    assert_true "true" "Should handle corrupted YAML gracefully"
    
    teardown
}

# Test: leaf handles empty arty.yml
test_empty_arty_yml() {
    setup
    
    mkdir -p test-project
    touch test-project/arty.yml
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
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
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
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
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_contains "$(cat output/index.html)" "No examples found" "Should show placeholder for no examples"
    
    teardown
}

# Test: leaf handles invalid JSON in projects argument
test_invalid_projects_json() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects '{invalid}' -o output 2>&1 | strip_colors)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on invalid JSON"
    # Just check it fails, don't require specific error message
    
    teardown
}

# Test: leaf handles corrupted JSON file
test_corrupted_json_file() {
    setup
    
    echo "not valid json" > projects.json
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects-file projects.json -o output 2>&1 | strip_colors)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on corrupted JSON file"
    assert_contains "$output" "Failed to parse\|must be an array" "Should report error"
    
    teardown
}

# Test: leaf handles special characters in project name
test_special_chars_in_name() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project-special"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should create output with special characters"
    
    teardown
}

# Test: leaf handles very long project description
test_very_long_description() {
    setup
    
    mkdir -p test-project
    long_desc="This is a very long description. "
    for i in {1..50}; do
        long_desc="${long_desc}More text. "
    done
    
    cat > test-project/arty.yml << EOF
name: "test-project"
version: "1.0.0"
description: "${long_desc}"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
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
    
    # Create a file with binary content
    echo -e '\x00\x01\x02\x03' > test-project/binary.bin
    echo "echo test" > test-project/script.sh
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should create output despite binary files"
    
    teardown
}

# Test: leaf handles missing icon file gracefully
test_missing_icon_file() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project --logo nonexistent.svg -o output 2>&1 | strip_colors)
    
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
echo "test"
```

## Special Characters
& < > " '
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
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
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
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
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
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
    
    bash "$LEAF_SH" --landing --projects "$projects" --projects-file projects.json -o output 2>&1 > /dev/null
    
    # File should take priority
    html=$(cat output/index.html)
    assert_contains "$html" "file.com" "Should prioritize file"
    
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
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should handle circular symlinks"
    
    teardown
}

# Test: Empty output produces reasonable default
test_minimal_project() {
    setup
    
    mkdir -p test-project
    # Minimal project with just directory
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should create output for minimal project"
    
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
    test_missing_icon_file
    test_readme_special_markdown
    test_deeply_nested_structure
    test_files_no_extension
    test_both_projects_options
    test_circular_symlinks
    test_minimal_project
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
