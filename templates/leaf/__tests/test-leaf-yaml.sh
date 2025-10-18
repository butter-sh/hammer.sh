#!/usr/bin/env bash
# Test suite for leaf.sh YAML parsing functionality

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

# Test: parse_yaml retrieves simple field
test_parse_yaml_simple_field() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test_parse.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_yaml "${2}" "name"
EOF
    
    output=$(bash test_parse.sh "$LEAF_SH" test.yml)
    
    assert_equals "test-project" "$output" "Should retrieve name field"
    
    teardown
}

# Test: parse_yaml retrieves version
test_parse_yaml_version() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
version: "2.5.1"
description: "Test description"
EOF
    
    cat > test_parse.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_yaml "${2}" "version"
EOF
    
    output=$(bash test_parse.sh "$LEAF_SH" test.yml)
    
    assert_equals "2.5.1" "$output" "Should retrieve version field"
    
    teardown
}

# Test: parse_yaml handles missing file
test_parse_yaml_missing_file() {
    setup
    
    cat > test_missing.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
result=$(parse_yaml "nonexistent.yml" "name")
if [[ -z "$result" ]]; then
    echo "empty"
else
    echo "not empty"
fi
EOF
    
    output=$(bash test_missing.sh "$LEAF_SH")
    
    assert_equals "empty" "$output" "Should return empty for missing file"
    
    teardown
}

# Test: parse_yaml handles missing field
test_parse_yaml_missing_field() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
EOF
    
    cat > test_field.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
result=$(parse_yaml "${2}" "nonexistent")
if [[ -z "$result" ]]; then
    echo "empty"
else
    echo "$result"
fi
EOF
    
    output=$(bash test_field.sh "$LEAF_SH" test.yml)
    
    assert_equals "empty" "$output" "Should return empty for missing field"
    
    teardown
}

# Test: parse_yaml handles nested fields
test_parse_yaml_nested() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
config:
  setting: "value"
EOF
    
    cat > test_nested.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_yaml "${2}" "config.setting"
EOF
    
    output=$(bash test_nested.sh "$LEAF_SH" test.yml)
    
    assert_equals "value" "$output" "Should retrieve nested field"
    
    teardown
}

# Test: parse_yaml handles null values
test_parse_yaml_null() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
description: null
EOF
    
    cat > test_null.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
result=$(parse_yaml "${2}" "description")
if [[ -z "$result" ]]; then
    echo "empty"
else
    echo "$result"
fi
EOF
    
    output=$(bash test_null.sh "$LEAF_SH" test.yml)
    
    assert_equals "empty" "$output" "Should filter out null values"
    
    teardown
}

# Test: parse_yaml handles quoted strings
test_parse_yaml_quoted_strings() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
description: "A project with \"quotes\" inside"
EOF
    
    cat > test_quotes.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_yaml "${2}" "description"
EOF
    
    output=$(bash test_quotes.sh "$LEAF_SH" test.yml)
    
    assert_contains "$output" "quotes" "Should handle quoted strings"
    
    teardown
}

# Test: parse_yaml handles multiline strings
test_parse_yaml_multiline() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
description: |
  This is a
  multiline description
EOF
    
    cat > test_multiline.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_yaml "${2}" "description"
EOF
    
    output=$(bash test_multiline.sh "$LEAF_SH" test.yml)
    
    assert_contains "$output" "multiline" "Should handle multiline strings"
    
    teardown
}

# Test: parse_yaml handles special characters
test_parse_yaml_special_chars() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
url: "https://example.com/path?query=value&other=123"
EOF
    
    cat > test_special.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_yaml "${2}" "url"
EOF
    
    output=$(bash test_special.sh "$LEAF_SH" test.yml)
    
    assert_contains "$output" "example.com" "Should handle special characters in URLs"
    
    teardown
}

# Test: parse_yaml handles arrays
test_parse_yaml_arrays() {
    setup
    
    cat > test.yml << 'EOF'
name: "test-project"
references:
  - https://github.com/user/repo1
  - https://github.com/user/repo2
EOF
    
    cat > test_array.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_yaml "${2}" "references[0]"
EOF
    
    output=$(bash test_array.sh "$LEAF_SH" test.yml)
    
    assert_contains "$output" "repo1" "Should handle array access"
    
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
    test_parse_yaml_arrays
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
