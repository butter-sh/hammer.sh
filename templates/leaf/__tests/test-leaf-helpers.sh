#!/usr/bin/env bash
# Test suite for leaf.sh helper functions

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

# Test: detect_language detects shell files
test_detect_language_shell() {
    setup
    
    cat > test_detect.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
detect_language "test.sh"
detect_language "test.bash"
EOF
    
    output=$(bash test_detect.sh "$LEAF_SH")
    
    assert_contains "$output" "bash" "Should detect shell language"
    
    teardown
}

# Test: detect_language detects various languages
test_detect_language_various() {
    setup
    
    cat > test_langs.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
echo "js: $(detect_language 'test.js')"
echo "py: $(detect_language 'test.py')"
echo "rb: $(detect_language 'test.rb')"
echo "go: $(detect_language 'test.go')"
echo "rs: $(detect_language 'test.rs')"
EOF
    
    output=$(bash test_langs.sh "$LEAF_SH")
    
    assert_contains "$output" "js: javascript" "Should detect JavaScript"
    assert_contains "$output" "py: python" "Should detect Python"
    assert_contains "$output" "rb: ruby" "Should detect Ruby"
    assert_contains "$output" "go: go" "Should detect Go"
    assert_contains "$output" "rs: rust" "Should detect Rust"
    
    teardown
}

# Test: detect_language handles unknown extensions
test_detect_language_unknown() {
    setup
    
    cat > test_unknown.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
detect_language "test.xyz"
EOF
    
    output=$(bash test_unknown.sh "$LEAF_SH")
    
    assert_equals "plaintext" "$output" "Should default to plaintext"
    
    teardown
}

# Test: read_file reads existing file
test_read_file_exists() {
    setup
    
    echo "test content" > test.txt
    
    cat > test_read.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
read_file "${2}"
EOF
    
    output=$(bash test_read.sh "$LEAF_SH" test.txt)
    
    assert_equals "test content" "$output" "Should read file content"
    
    teardown
}

# Test: read_file handles missing file
test_read_file_missing() {
    setup
    
    cat > test_missing.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
result=$(read_file "nonexistent.txt")
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

# Test: get_icon finds icon in standard location
test_get_icon_standard() {
    setup
    
    mkdir -p _assets/icon
    echo '<svg>icon</svg>' > _assets/icon/icon.svg
    
    cat > test_icon.sh << 'EOF'
#!/usr/bin/env bash
export PROJECT_DIR="${2}"
source "${1}"
get_icon
EOF
    
    output=$(bash test_icon.sh "$LEAF_SH" "$TEST_DIR")
    
    assert_contains "$output" "_assets/icon/icon.svg" "Should find standard icon"
    
    teardown
}

# Test: get_icon prioritizes icon files
test_get_icon_priority() {
    setup
    
    mkdir -p _assets/icon
    echo '<svg>v2</svg>' > _assets/icon/icon-v2.svg
    echo '<svg>simple</svg>' > _assets/icon/icon-simple.svg
    echo '<svg>standard</svg>' > _assets/icon/icon.svg
    
    cat > test_priority.sh << 'EOF'
#!/usr/bin/env bash
export PROJECT_DIR="${2}"
source "${1}"
get_icon
EOF
    
    output=$(bash test_priority.sh "$LEAF_SH" "$TEST_DIR")
    
    # Should find icon.svg first (highest priority)
    assert_contains "$output" "icon.svg" "Should find highest priority icon"
    
    teardown
}

# Test: get_icon uses custom logo
test_get_icon_custom() {
    setup
    
    echo '<svg>custom</svg>' > custom.svg
    
    cat > test_custom.sh << 'EOF'
#!/usr/bin/env bash
export LOGO_PATH="${2}"
source "${1}"
get_icon
EOF
    
    output=$(bash test_custom.sh "$LEAF_SH" "$TEST_DIR/custom.svg")
    
    assert_contains "$output" "custom.svg" "Should use custom logo"
    
    teardown
}

# Test: get_icon returns empty when no icon found
test_get_icon_none() {
    setup
    
    cat > test_none.sh << 'EOF'
#!/usr/bin/env bash
export PROJECT_DIR="${2}"
source "${1}"
result=$(get_icon)
if [[ -z "$result" ]]; then
    echo "empty"
else
    echo "found"
fi
EOF
    
    output=$(bash test_none.sh "$LEAF_SH" "$TEST_DIR")
    
    assert_equals "empty" "$output" "Should return empty when no icon"
    
    teardown
}

# Test: logging functions produce output
test_logging_functions() {
    setup
    
    cat > test_logging.sh << 'EOF'
#!/usr/bin/env bash
source "${1}"
log_info "Info message"
log_success "Success message"
log_warn "Warning message"
log_error "Error message"
EOF
    
    output=$(bash test_logging.sh "$LEAF_SH" 2>&1)
    
    assert_contains "$output" "Info message" "Should output info"
    assert_contains "$output" "Success message" "Should output success"
    assert_contains "$output" "Warning message" "Should output warning"
    assert_contains "$output" "Error message" "Should output error"
    
    teardown
}

# Test: log_debug only shows when DEBUG enabled
test_log_debug() {
    setup
    
    cat > test_debug.sh << 'EOF'
#!/usr/bin/env bash
export DEBUG=1
source "${1}"
log_debug "Debug message"
EOF
    
    output=$(bash test_debug.sh "$LEAF_SH" 2>&1)
    
    assert_contains "$output" "Debug message" "Should show debug when enabled"
    
    teardown
}

# Test: log_debug hidden by default
test_log_debug_hidden() {
    setup
    
    cat > test_no_debug.sh << 'EOF'
#!/usr/bin/env bash
unset DEBUG
source "${1}"
log_debug "Debug message"
echo "done"
EOF
    
    output=$(bash test_no_debug.sh "$LEAF_SH" 2>&1)
    
    assert_not_contains "$output" "Debug message" "Should hide debug by default"
    assert_contains "$output" "done" "Should continue execution"
    
    teardown
}

# Test: scan_source_files finds shell files
test_scan_source_files() {
    setup
    
    mkdir -p src
    touch main.sh
    touch src/helper.sh
    touch src/utils.bash
    
    cat > test_scan.sh << 'EOF'
#!/usr/bin/env bash
export PROJECT_DIR="${2}"
source "${1}"
scan_source_files
EOF
    
    output=$(bash test_scan.sh "$LEAF_SH" "$TEST_DIR")
    
    assert_contains "$output" "main.sh" "Should find main.sh"
    assert_contains "$output" "helper.sh" "Should find helper.sh"
    
    teardown
}

# Test: scan_examples finds example files
test_scan_examples() {
    setup
    
    mkdir -p examples
    touch examples/basic.sh
    touch examples/advanced.sh
    
    cat > test_examples.sh << 'EOF'
#!/usr/bin/env bash
export PROJECT_DIR="${2}"
source "${1}"
scan_examples
EOF
    
    output=$(bash test_examples.sh "$LEAF_SH" "$TEST_DIR")
    
    assert_contains "$output" "basic.sh" "Should find basic example"
    assert_contains "$output" "advanced.sh" "Should find advanced example"
    
    teardown
}

# Test: scan_examples returns nothing when directory missing
test_scan_examples_no_directory() {
    setup
    
    cat > test_no_examples.sh << 'EOF'
#!/usr/bin/env bash
export PROJECT_DIR="${2}"
source "${1}"
result=$(scan_examples)
if [[ -z "$result" ]]; then
    echo "empty"
else
    echo "found"
fi
EOF
    
    output=$(bash test_no_examples.sh "$LEAF_SH" "$TEST_DIR")
    
    assert_equals "empty" "$output" "Should return empty when no examples directory"
    
    teardown
}

# Run all tests
run_tests() {
    test_detect_language_shell
    test_detect_language_various
    test_detect_language_unknown
    test_read_file_exists
    test_read_file_missing
    test_get_icon_standard
    test_get_icon_priority
    test_get_icon_custom
    test_get_icon_none
    test_logging_functions
    test_log_debug
    test_log_debug_hidden
    test_scan_source_files
    test_scan_examples
    test_scan_examples_no_directory
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
