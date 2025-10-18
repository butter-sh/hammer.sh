#!/usr/bin/env bash
# Test suite for leaf.sh JSON parsing and validation

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

# Test: parse_json parses valid JSON
test_parse_json_valid() {
    setup
    
    cat > test_parse.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_json '{"name":"test","value":123}'
EOF
    
    output=$(bash test_parse.sh "$LEAF_SH")
    
    assert_contains "$output" "test" "Should parse valid JSON"
    
    teardown
}

# Test: parse_json with query extracts field
test_parse_json_with_query() {
    setup
    
    cat > test_query.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_json '{"name":"test","value":123}' '.name'
EOF
    
    output=$(bash test_query.sh "$LEAF_SH")
    
    assert_equals "test" "$output" "Should extract field with query"
    
    teardown
}

# Test: parse_json detects invalid JSON
test_parse_json_invalid() {
    setup
    
    cat > test_invalid.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_json 'not valid json' 2>&1
echo "exit_code=$?"
EOF
    
    output=$(bash test_invalid.sh "$LEAF_SH")
    
    assert_contains "$output" "Invalid JSON" "Should report invalid JSON"
    assert_contains "$output" "exit_code=1" "Should return error code"
    
    teardown
}

# Test: parse_json handles empty input
test_parse_json_empty() {
    setup
    
    cat > test_empty.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_json '' 2>&1 || echo "failed"
EOF
    
    output=$(bash test_empty.sh "$LEAF_SH")
    
    assert_contains "$output" "failed" "Should fail on empty input"
    
    teardown
}

# Test: validate_projects_json accepts valid array
test_validate_projects_json_valid() {
    setup
    
    cat > test_validate.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
json='[{"url":"https://example.com","label":"Example","desc":"Test"}]'
if validate_projects_json "$json" 2>&1; then
    echo "valid"
else
    echo "invalid"
fi
EOF
    
    output=$(bash test_validate.sh "$LEAF_SH")
    
    assert_contains "$output" "valid" "Should validate correct projects JSON"
    
    teardown
}

# Test: validate_projects_json rejects non-array
test_validate_projects_json_not_array() {
    setup
    
    cat > test_not_array.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
json='{"url":"https://example.com"}'
if validate_projects_json "$json" 2>&1; then
    echo "valid"
else
    echo "invalid"
fi
EOF
    
    output=$(bash test_not_array.sh "$LEAF_SH")
    
    assert_contains "$output" "must be an array" "Should reject non-array JSON"
    assert_contains "$output" "invalid" "Should return invalid"
    
    teardown
}

# Test: validate_projects_json handles empty array
test_validate_projects_json_empty() {
    setup
    
    cat > test_empty_array.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
output=$(validate_projects_json '[]' 2>&1)
echo "$output"
EOF
    
    output=$(bash test_empty_array.sh "$LEAF_SH")
    
    assert_contains "$output" "empty" "Should warn about empty array"
    
    teardown
}

# Test: validate_projects_json checks required fields
test_validate_projects_json_missing_fields() {
    setup
    
    cat > test_missing.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
json='[{"url":"https://example.com"}]'
output=$(validate_projects_json "$json" 2>&1)
echo "$output"
EOF
    
    output=$(bash test_missing.sh "$LEAF_SH")
    
    assert_contains "$output" "missing required fields" "Should warn about missing fields"
    
    teardown
}

# Test: validate_projects_json accepts complete projects
test_validate_projects_json_complete() {
    setup
    
    cat > test_complete.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
json='[
  {"url":"https://example.com","label":"Example","desc":"Description","class":"card"}
]'
validate_projects_json "$json" 2>&1
echo "result=$?"
EOF
    
    output=$(bash test_complete.sh "$LEAF_SH")
    
    assert_contains "$output" "result=0" "Should accept complete projects"
    
    teardown
}

# Test: read_json_file reads valid file
test_read_json_file_valid() {
    setup
    
    cat > test.json << 'EOF'
[
  {"url":"https://test.com","label":"Test"}
]
EOF
    
    cat > test_read.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
read_json_file "${2}" 2>&1
EOF
    
    output=$(bash test_read.sh "$LEAF_SH" test.json)
    
    assert_contains "$output" "test.com" "Should read JSON file"
    
    teardown
}

# Test: read_json_file handles missing file
test_read_json_file_missing() {
    setup
    
    cat > test_missing_file.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
read_json_file "nonexistent.json" 2>&1
echo "result=$?"
EOF
    
    output=$(bash test_missing_file.sh "$LEAF_SH")
    
    assert_contains "$output" "not found" "Should report file not found"
    assert_contains "$output" "result=1" "Should return error"
    
    teardown
}

# Test: read_json_file handles invalid JSON in file
test_read_json_file_invalid() {
    setup
    
    echo "not valid json" > test.json
    
    cat > test_invalid_file.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
read_json_file "${2}" 2>&1
echo "result=$?"
EOF
    
    output=$(bash test_invalid_file.sh "$LEAF_SH" test.json)
    
    assert_contains "$output" "Failed to parse" "Should report parse failure"
    assert_contains "$output" "result=1" "Should return error"
    
    teardown
}

# Test: parse_json handles nested objects
test_parse_json_nested() {
    setup
    
    cat > test_nested.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_json '{"outer":{"inner":"value"}}' '.outer.inner'
EOF
    
    output=$(bash test_nested.sh "$LEAF_SH")
    
    assert_equals "value" "$output" "Should handle nested objects"
    
    teardown
}

# Test: parse_json handles arrays
test_parse_json_arrays() {
    setup
    
    cat > test_arrays.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
parse_json '[{"name":"first"},{"name":"second"}]' '.[1].name'
EOF
    
    output=$(bash test_arrays.sh "$LEAF_SH")
    
    assert_equals "second" "$output" "Should handle array indexing"
    
    teardown
}

# Run all tests
run_tests() {
    test_parse_json_valid
    test_parse_json_with_query
    test_parse_json_invalid
    test_parse_json_empty
    test_validate_projects_json_valid
    test_validate_projects_json_not_array
    test_validate_projects_json_empty
    test_validate_projects_json_missing_fields
    test_validate_projects_json_complete
    test_read_json_file_valid
    test_read_json_file_missing
    test_read_json_file_invalid
    test_parse_json_nested
    test_parse_json_arrays
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
