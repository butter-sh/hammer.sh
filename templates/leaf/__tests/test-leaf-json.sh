#!/usr/bin/env bash
# Test suite for leaf.sh JSON parsing and validation
# Tests JSON through landing page generation

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

# Test: Valid JSON is accepted
test_parse_json_valid() {
    setup
    
    projects='[{"url":"https://test.com","label":"Test","desc":"Description","class":"card"}]'
    
    bash "$LEAF_SH" --landing --projects "$projects" -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should create output with valid JSON"
    assert_contains "$(cat output/index.html)" "test.com" "Should include project URL"
    
    teardown
}

# Test: Invalid JSON is rejected
test_parse_json_invalid() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects 'not valid json' -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on invalid JSON"
    
    teardown
}

# Test: Empty array is handled
test_parse_json_empty() {
    setup
    
    output=$(bash "$LEAF_SH" --landing --projects '[]' -o output 2>&1)
    
    assert_contains "$output" "empty" "Should warn about empty array"
    
    teardown
}

# Test: Non-array JSON is rejected
test_validate_projects_json_not_array() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects '{"url":"test"}' -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on non-array"
    assert_contains "$output" "must be an array" "Should report must be array"
    
    teardown
}

# Test: Missing required fields generates warning
test_validate_projects_json_missing_fields() {
    setup
    
    projects='[{"url":"https://test.com"}]'
    output=$(bash "$LEAF_SH" --landing --projects "$projects" -o output 2>&1)
    
    assert_contains "$output" "missing required fields" "Should warn about missing fields"
    
    teardown
}

# Test: Complete project JSON works
test_validate_projects_json_complete() {
    setup
    
    projects='[{"url":"https://test.com","label":"Test","desc":"Desc","class":"card"}]'
    
    bash "$LEAF_SH" --landing --projects "$projects" -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should accept complete projects"
    html=$(cat output/index.html)
    assert_contains "$html" "test.com" "Should include URL"
    assert_contains "$html" "Test" "Should include label"
    
    teardown
}

# Test: Read JSON from valid file
test_read_json_file_valid() {
    setup
    
    cat > projects.json << 'EOF'
[
  {"url":"https://file-test.com","label":"FileTest","desc":"From file","class":"card"}
]
EOF
    
    bash "$LEAF_SH" --landing --projects-file projects.json -o output 2>&1 > /dev/null
    
    assert_file_exists "output/index.html" "Should create output from file"
    assert_contains "$(cat output/index.html)" "file-test.com" "Should include project from file"
    
    teardown
}

# Test: Missing JSON file is reported
test_read_json_file_missing() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects-file nonexistent.json -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on missing file"
    assert_contains "$output" "not found" "Should report file not found"
    
    teardown
}

# Test: Invalid JSON in file is reported
test_read_json_file_invalid() {
    setup
    
    echo "not valid json" > projects.json
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects-file projects.json -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on invalid JSON in file"
    assert_contains "$output" "Failed to parse\|must be an array" "Should report parse error"
    
    teardown
}

# Test: Multiple projects in array
test_parse_json_arrays() {
    setup
    
    projects='[
      {"url":"https://first.com","label":"First","desc":"First project","class":"card"},
      {"url":"https://second.com","label":"Second","desc":"Second project","class":"card"}
    ]'
    
    bash "$LEAF_SH" --landing --projects "$projects" -o output 2>&1 > /dev/null
    
    html=$(cat output/index.html)
    assert_contains "$html" "first.com" "Should include first project"
    assert_contains "$html" "second.com" "Should include second project"
    
    teardown
}

# Test: Projects file takes priority over projects argument
test_projects_file_priority() {
    setup
    
    cat > projects.json << 'EOF'
[{"url":"https://from-file.com","label":"FromFile","desc":"File","class":"card"}]
EOF
    
    projects='[{"url":"https://from-arg.com","label":"FromArg","desc":"Arg","class":"card"}]'
    
    bash "$LEAF_SH" --landing --projects "$projects" --projects-file projects.json -o output 2>&1 > /dev/null
    
    html=$(cat output/index.html)
    assert_contains "$html" "from-file.com" "Should use file"
    assert_not_contains "$html" "from-arg.com" "Should not use argument"
    
    teardown
}

# Test: Default projects used when none provided
test_default_projects() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1 > /dev/null
    
    html=$(cat output/index.html)
    assert_contains "$html" "hammer.sh" "Should include hammer.sh"
    assert_contains "$html" "arty.sh" "Should include arty.sh"
    assert_contains "$html" "leaf.sh" "Should include leaf.sh"
    
    teardown
}

# Test: JSON validation catches malformed structure
test_json_validation() {
    setup
    
    # Array with object missing url
    projects='[{"label":"NoURL","desc":"Missing URL","class":"card"}]'
    
    output=$(bash "$LEAF_SH" --landing --projects "$projects" -o output 2>&1)
    
    assert_contains "$output" "missing required fields" "Should detect missing URL"
    
    teardown
}

# Run all tests
run_tests() {
    test_parse_json_valid
    test_parse_json_invalid
    test_parse_json_empty
    test_validate_projects_json_not_array
    test_validate_projects_json_missing_fields
    test_validate_projects_json_complete
    test_read_json_file_valid
    test_read_json_file_missing
    test_read_json_file_invalid
    test_parse_json_arrays
    test_projects_file_priority
    test_default_projects
    test_json_validation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
