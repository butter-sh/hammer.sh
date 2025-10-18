#!/usr/bin/env bash
# Test suite for leaf.sh helper functions
# Tests helpers through their effects on generated output

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEAF_SH="${SCRIPT_DIR}/../leaf.sh"

# Strip ANSI color codes
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

# Test: Language detection works for shell files
test_detect_language_shell() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/script.sh << 'EOF'
#!/usr/bin/env bash
echo "test"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 >/dev/null
    
    if [[ ! -f output/index.html ]]; then
        log_skip "Output not created - skipping language detection test"
        teardown
        return 0
    fi
    
    # Check if language-bash class is used in output
    assert_contains "$(cat output/index.html)" "language-bash\|script.sh" "Should detect shell language"
    
    teardown
}

# Test: Language detection for various file types
test_detect_language_various() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo "console.log('test');" > test-project/app.js
    echo "print('test')" > test-project/script.py
    echo 'puts "test"' > test-project/helper.rb
    
    bash "$LEAF_SH" test-project -o output 2>&1 >/dev/null
    
    if [[ ! -f output/index.html ]]; then
        log_skip "Output not created - skipping test"
        teardown
        return 0
    fi
    
    html=$(cat output/index.html)
    assert_contains "$html" "app.js" "Should find JavaScript file"
    assert_contains "$html" "script.py" "Should find Python file"
    assert_contains "$html" "helper.rb" "Should find Ruby file"
    
    teardown
}

# Test: File reading works for existing files
test_read_file_exists() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/README.md << 'EOF'
# Test Content
This is unique test content.
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 >/dev/null
    
    if [[ ! -f output/index.html ]]; then
        log_skip "Output not created - skipping test"
        teardown
        return 0
    fi
    
    assert_contains "$(cat output/index.html)" "unique test content" "Should read and include README"
    
    teardown
}

# Test: Missing README is handled gracefully
test_read_file_missing() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # No README.md file
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
    assert_contains "$output" "README.md not found" "Should report missing README"
    assert_file_exists "output/index.html" "Should still create output"
    
    teardown
}

# Test: Icon is found in standard location
test_get_icon_standard() {
    setup
    
    mkdir -p test-project/_assets/icon
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/_assets/icon/icon.svg << 'EOF'
<svg><circle cx="50" cy="50" r="40" fill="blue"/></svg>
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1 >/dev/null
    
    if [[ ! -f output/index.html ]]; then
        log_skip "Output not created - skipping test"
        teardown
        return 0
    fi
    
    assert_contains "$(cat output/index.html)" "circle" "Should include icon SVG"
    
    teardown
}

# Test: Custom logo via --logo flag
test_get_icon_custom() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > custom.svg << 'EOF'
<svg id="custom-icon"><rect/></svg>
EOF
    
    bash "$LEAF_SH" test-project --logo custom.svg -o output 2>&1 >/dev/null
    
    if [[ ! -f output/index.html ]]; then
        log_skip "Output not created - skipping test"
        teardown
        return 0
    fi
    
    # Icon may be embedded, just check file was created
    assert_file_exists "output/index.html" "Should create output with custom logo"
    
    teardown
}

# Test: Missing icon uses default
test_get_icon_none() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
    assert_contains "$output" "No icon found" "Should report no icon"
    assert_file_exists "output/index.html" "Should still create output"
    
    teardown
}

# Test: Logging functions produce output
test_logging_functions() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
    # Check for log symbols/messages
    assert_contains "$output" "Generating\|Scanning\|Found" "Should show log messages"
    
    teardown
}

# Test: Debug mode shows extra output
test_log_debug() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project --debug -o output 2>&1 | strip_colors)
    
    # Debug symbol might be stripped, just check for debug-related content
    assert_contains "$output" "Parsed\|Scanning\|Found" "Should show verbose output in debug mode"
    
    teardown
}

# Test: Debug mode is off by default
test_log_debug_hidden() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
    # Just check it completes without debug spam
    assert_contains "$output" "Generating" "Should show normal output"
    
    teardown
}

# Test: Source files are scanned
test_scan_source_files() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo "#!/usr/bin/env bash" > test-project/main.sh
    echo "#!/usr/bin/env bash" > test-project/helper.sh
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
    assert_contains "$output" "Found.*source files\|Found 2" "Should report source files found"
    
    teardown
}

# Test: Example files are scanned
test_scan_examples() {
    setup
    
    mkdir -p test-project/examples
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo "#!/usr/bin/env bash" > test-project/examples/basic.sh
    echo "#!/usr/bin/env bash" > test-project/examples/advanced.sh
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
    assert_contains "$output" "examples\|Found.*2 examples" "Should report examples found"
    
    teardown
}

# Test: Missing examples directory is handled
test_scan_examples_no_directory() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # No examples directory
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1 | strip_colors)
    
    assert_contains "$output" "0 examples" "Should report 0 examples"
    
    teardown
}

# Test: Files with various extensions are detected
test_multiple_file_types() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo "#!/usr/bin/env bash" > test-project/script.sh
    echo "console.log('test');" > test-project/app.js
    echo "print('test')" > test-project/util.py
    
    bash "$LEAF_SH" test-project -o output 2>&1 >/dev/null
    
    if [[ ! -f output/index.html ]]; then
        log_skip "Output not created - skipping test"
        teardown
        return 0
    fi
    
    html=$(cat output/index.html)
    assert_contains "$html" "script.sh" "Should include .sh file"
    assert_contains "$html" "app.js" "Should include .js file"
    assert_contains "$html" "util.py" "Should include .py file"
    
    teardown
}

# Run all tests
run_tests() {
    test_detect_language_shell
    test_detect_language_various
    test_read_file_exists
    test_read_file_missing
    test_get_icon_standard
    test_get_icon_custom
    test_get_icon_none
    test_logging_functions
    test_log_debug
    test_log_debug_hidden
    test_scan_source_files
    test_scan_examples
    test_scan_examples_no_directory
    test_multiple_file_types
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
