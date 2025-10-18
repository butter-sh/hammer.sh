#!/usr/bin/env bash
# Test suite for leaf.sh dependency checking

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

# Test: check_dependencies detects missing yq
test_check_dependencies_missing_yq() {
    setup
    
    # Create a test script that modifies PATH to hide yq
    cat > "$TEST_DIR/test_no_yq.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
source "${1}"
check_dependencies 2>&1 || true
EOF
    
    output=$(bash "$TEST_DIR/test_no_yq.sh" "$LEAF_SH")
    
    assert_contains "$output" "yq" "Should detect missing yq"
    assert_contains "$output" "Missing required dependencies" "Should report missing dependencies"
    
    teardown
}

# Test: check_dependencies detects missing jq
test_check_dependencies_missing_jq() {
    setup
    
    # Create a test script that hides jq but keeps yq
    cat > "$TEST_DIR/test_no_jq.sh" << 'EOF'
#!/usr/bin/env bash
# Create a fake yq that does nothing
mkdir -p fake_bin
echo '#!/usr/bin/env bash' > fake_bin/yq
chmod +x fake_bin/yq
PATH="$(pwd)/fake_bin:/nonexistent"
source "${1}"
check_dependencies 2>&1 || true
EOF
    
    output=$(bash "$TEST_DIR/test_no_jq.sh" "$LEAF_SH")
    
    assert_contains "$output" "jq" "Should detect missing jq"
    
    teardown
}

# Test: check_dependencies succeeds when both present
test_check_dependencies_success() {
    setup
    
    # Only run if both yq and jq are available
    if command -v yq &>/dev/null && command -v jq &>/dev/null; then
        cat > "$TEST_DIR/test_deps_ok.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
if check_dependencies 2>&1; then
    echo "success"
else
    echo "failure"
fi
EOF
        
        output=$(bash "$TEST_DIR/test_deps_ok.sh" "$LEAF_SH")
        
        assert_equals "success" "$output" "Should succeed when dependencies present"
    else
        log_skip "Skipping test - yq or jq not available"
    fi
    
    teardown
}

# Test: dependency check shows installation links
test_dependency_install_links() {
    setup
    
    cat > "$TEST_DIR/test_links.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
source "${1}"
check_dependencies 2>&1 || true
EOF
    
    output=$(bash "$TEST_DIR/test_links.sh" "$LEAF_SH")
    
    assert_contains "$output" "https://github.com/mikefarah/yq" "Should show yq install link"
    assert_contains "$output" "https://stedolan.github.io/jq" "Should show jq install link"
    
    teardown
}

# Test: dependency check returns proper exit code
test_dependency_exit_code() {
    setup
    
    cat > "$TEST_DIR/test_exit.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
source "${1}"
check_dependencies >/dev/null 2>&1
echo $?
EOF
    
    output=$(bash "$TEST_DIR/test_exit.sh" "$LEAF_SH")
    
    assert_equals "1" "$output" "Should return exit code 1 when dependencies missing"
    
    teardown
}

# Test: main function exits when dependencies missing
test_main_exits_on_missing_deps() {
    setup
    
    # Create a wrapper script that hides dependencies
    cat > "$TEST_DIR/test_main_exit.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
bash "${1}" --help 2>&1 || echo "exited with $?"
EOF
    
    output=$(bash "$TEST_DIR/test_main_exit.sh" "$LEAF_SH")
    
    assert_contains "$output" "Missing required dependencies" "Should report missing deps"
    
    teardown
}

# Test: dependency check is called early
test_dependency_check_early() {
    setup
    
    # Dependency check should happen before any real work
    cat > "$TEST_DIR/test_early.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
output=$(bash "${1}" test-project 2>&1 || true)
# Should fail on deps before trying to access project
echo "$output"
EOF
    
    output=$(bash "$TEST_DIR/test_early.sh" "$LEAF_SH")
    
    assert_contains "$output" "Missing required dependencies" "Should check dependencies first"
    
    teardown
}

# Run all tests
run_tests() {
    test_check_dependencies_missing_yq
    test_check_dependencies_missing_jq
    test_check_dependencies_success
    test_dependency_install_links
    test_dependency_exit_code
    test_main_exits_on_missing_deps
    test_dependency_check_early
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
