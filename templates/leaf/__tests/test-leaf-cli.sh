#!/usr/bin/env bash
# Test suite for leaf.sh CLI interface and commands

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

# Test: leaf without arguments shows usage
test_no_args_shows_usage() {
    setup
    
    output=$(bash "$LEAF_SH" 2>&1)
    
    assert_contains "$output" "leaf.sh" "Should show leaf.sh name"
    assert_contains "$output" "USAGE:" "Should show usage"
    assert_contains "$output" "OPTIONS:" "Should show options"
    
    teardown
}

# Test: leaf --help shows usage
test_help_flag() {
    setup
    
    output=$(bash "$LEAF_SH" --help 2>&1)
    
    assert_contains "$output" "USAGE:" "Should show usage"
    assert_contains "$output" "DOCUMENTATION MODE:" "Should show documentation mode"
    assert_contains "$output" "LANDING PAGE MODE:" "Should show landing page mode"
    
    teardown
}

# Test: leaf -h shows usage
test_help_short_flag() {
    setup
    
    output=$(bash "$LEAF_SH" -h 2>&1)
    
    assert_contains "$output" "USAGE:" "Should show usage"
    
    teardown
}

# Test: leaf --version shows version
test_version_flag() {
    setup
    
    output=$(bash "$LEAF_SH" --version 2>&1)
    
    assert_contains "$output" "leaf.sh version" "Should show version"
    assert_contains "$output" "2.2.0" "Should show version number"
    
    teardown
}

# Test: leaf --landing switches to landing mode
test_landing_mode_flag() {
    setup
    
    mkdir -p docs
    output=$(bash "$LEAF_SH" --landing -o docs 2>&1)
    
    assert_file_exists "docs/index.html" "Should create landing page"
    assert_contains "$(cat docs/index.html)" "butter.sh" "Landing page should contain butter.sh"
    
    teardown
}

# Test: leaf --output sets custom output directory
test_output_flag() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
description: "Test project"
EOF
    
    cat > test-project/README.md << 'EOF'
# Test Project
This is a test.
EOF
    
    bash "$LEAF_SH" test-project --output custom-output 2>&1
    
    assert_file_exists "custom-output/index.html" "Should create output in custom directory"
    
    teardown
}

# Test: leaf -o short flag works
test_output_short_flag() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o short-output 2>&1
    
    assert_file_exists "short-output/index.html" "Should work with -o flag"
    
    teardown
}

# Test: leaf --logo accepts custom logo path
test_logo_flag() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo '<svg></svg>' > custom-logo.svg
    
    bash "$LEAF_SH" test-project --logo custom-logo.svg -o output 2>&1
    
    assert_file_exists "output/index.html" "Should create output with custom logo"
    
    teardown
}

# Test: leaf --base-path sets base path
test_base_path_flag() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project --base-path /docs/ -o output 2>&1
    
    assert_file_exists "output/index.html" "Should create output"
    assert_contains "$(cat output/index.html)" 'base href="/docs/"' "Should set base path"
    
    teardown
}

# Test: leaf --github sets GitHub URL
test_github_flag() {
    setup
    
    bash "$LEAF_SH" --landing --github https://github.com/custom-org -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "github.com/custom-org" "Should set custom GitHub URL"
    
    teardown
}

# Test: leaf --debug enables debug output
test_debug_flag() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project --debug -o output 2>&1)
    
    assert_contains "$output" "🔍" "Should show debug output"
    
    teardown
}

# Test: unknown option shows error
test_unknown_option() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --unknown-option 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should return error for unknown option"
    assert_contains "$output" "Unknown option" "Should show unknown option error"
    
    teardown
}

# Test: usage shows examples
test_usage_shows_examples() {
    setup
    
    output=$(bash "$LEAF_SH" --help 2>&1)
    
    assert_contains "$output" "EXAMPLES:" "Should show examples section"
    assert_contains "$output" "leaf.sh" "Should show leaf.sh usage examples"
    
    teardown
}

# Test: usage shows dependencies
test_usage_shows_dependencies() {
    setup
    
    output=$(bash "$LEAF_SH" --help 2>&1)
    
    assert_contains "$output" "DEPENDENCIES:" "Should show dependencies"
    assert_contains "$output" "yq" "Should mention yq dependency"
    assert_contains "$output" "jq" "Should mention jq dependency"
    
    teardown
}

# Test: usage shows project structure
test_usage_shows_project_structure() {
    setup
    
    output=$(bash "$LEAF_SH" --help 2>&1)
    
    assert_contains "$output" "PROJECT STRUCTURE:" "Should show project structure"
    assert_contains "$output" "arty.yml" "Should mention arty.yml"
    
    teardown
}

# Test: usage shows projects JSON format
test_usage_shows_json_format() {
    setup
    
    output=$(bash "$LEAF_SH" --help 2>&1)
    
    assert_contains "$output" "PROJECTS JSON FORMAT:" "Should show JSON format"
    assert_contains "$output" '"url"' "Should show JSON structure"
    
    teardown
}

# Test: usage shows supported file types
test_usage_shows_file_types() {
    setup
    
    output=$(bash "$LEAF_SH" --help 2>&1)
    
    assert_contains "$output" "SUPPORTED FILE TYPES:" "Should show file types"
    assert_contains "$output" "Shell" "Should mention shell files"
    
    teardown
}

# Run all tests
run_tests() {
    test_no_args_shows_usage
    test_help_flag
    test_help_short_flag
    test_version_flag
    test_landing_mode_flag
    test_output_flag
    test_output_short_flag
    test_logo_flag
    test_base_path_flag
    test_github_flag
    test_debug_flag
    test_unknown_option
    test_usage_shows_examples
    test_usage_shows_dependencies
    test_usage_shows_project_structure
    test_usage_shows_json_format
    test_usage_shows_file_types
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
