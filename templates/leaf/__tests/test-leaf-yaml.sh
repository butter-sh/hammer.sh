#!/usr/bin/env bash
# Test suite for leaf.sh YAML parsing functionality
# Tests YAML parsing through actual documentation generation

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

# Test: parse_yaml retrieves simple field through docs generation
test_parse_yaml_simple_field() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    # Check if name appears in generated HTML
    assert_file_exists "output/index.html" "Should create output"
    assert_contains "$(cat output/index.html)" "test-project" "Should include project name"
    
    teardown
}

# Test: parse_yaml retrieves version
test_parse_yaml_version() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "2.5.1"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_contains "$(cat output/index.html)" "2.5.1" "Should include version"
    
    teardown
}

# Test: parse_yaml handles missing file gracefully
test_parse_yaml_missing_file() {
    setup
    
    mkdir -p test-project
    # No arty.yml file
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    # Should still generate output
    assert_file_exists "output/index.html" "Should create output without arty.yml"
    
    teardown
}

# Test: parse_yaml handles missing field
test_parse_yaml_missing_field() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    # Should still generate with defaults
    assert_file_exists "output/index.html" "Should create output with missing fields"
    
    teardown
}

# Test: parse_yaml handles nested fields
test_parse_yaml_nested() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
author: "Test Author"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should handle nested fields"
    
    teardown
}

# Test: parse_yaml handles null values
test_parse_yaml_null() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
description: null
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    # Should not crash, should generate output
    assert_file_exists "output/index.html" "Should handle null values"
    
    teardown
}

# Test: parse_yaml handles quoted strings
test_parse_yaml_quoted_strings() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
description: "A project with \"quotes\" inside"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should handle quoted strings"
    assert_contains "$(cat output/index.html)" "quotes" "Should include content with quotes"
    
    teardown
}

# Test: parse_yaml handles multiline strings
test_parse_yaml_multiline() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
description: |
  This is a
  multiline description
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should handle multiline"
    assert_contains "$(cat output/index.html)" "multiline" "Should include multiline content"
    
    teardown
}

# Test: parse_yaml handles special characters
test_parse_yaml_special_chars() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
description: "Special chars: @#$%"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should handle special characters"
    
    teardown
}

# Test: parse_yaml works with complete project
test_parse_yaml_complete() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "complete-project"
version: "1.2.3"
description: "A complete test project"
author: "Test Author"
license: "MIT"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 > /dev/null
    
    html=$(cat output/index.html)
    assert_contains "$html" "complete-project" "Should include name"
    assert_contains "$html" "1.2.3" "Should include version"
    assert_contains "$html" "complete test project" "Should include description"
    
    teardown
}

# Run all tests
run_tests() {
    test_parse_yaml_simple_field
    test_parse_yaml_version
    test_parse_yaml_missing_file
    test_parse_yaml_missing_field
    test_parse_yaml_nested
    test_parse_yaml_null
    test_parse_yaml_quoted_strings
    test_parse_yaml_multiline
    test_parse_yaml_special_chars
    test_parse_yaml_complete
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
