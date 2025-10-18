#!/usr/bin/env bash
# Test suite for arty helper functions and utilities

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTY_SH="${SCRIPT_DIR}/../arty.sh"

# Source test helpers
if ! declare -f assert_contains > /dev/null; then
    echo "Error: Test helpers not loaded. This test must be run via judge.sh"
    exit 1
fi


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

# Test: check_yq detects missing yq
test_check_yq_detects_missing() {
    setup
    
    # Create a test script that modifies PATH to hide yq
    cat > "$TEST_DIR/test_no_yq.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
source "${1}"
check_yq 2>&1 || true
EOF
    
    output=$(bash "$TEST_DIR/test_no_yq.sh" "$ARTY_SH")
    
    assert_contains "$output" "yq is not installed" "Should detect missing yq"
    
    teardown
}

# Test: is_installed checks directory existence
test_is_installed_check() {
    setup
    
    export ARTY_HOME="$TEST_DIR/.arty"
    mkdir -p "$ARTY_HOME/libs/test-lib"
    
    cat > "$TEST_DIR/test_installed.sh" << 'EOF'
#!/usr/bin/env bash
export ARTY_HOME="${1}"
source "${2}"
if is_installed "test-lib"; then
    echo "installed"
else
    echo "not installed"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_installed.sh" "$ARTY_HOME" "$ARTY_SH")
    
    assert_equals "installed" "$output" "Should detect installed library"
    
    teardown
}

# Test: is_installed returns false for non-existent library
test_is_installed_not_found() {
    setup
    
    export ARTY_HOME="$TEST_DIR/.arty"
    mkdir -p "$ARTY_HOME/libs"
    
    cat > "$TEST_DIR/test_not_installed.sh" << 'EOF'
#!/usr/bin/env bash
export ARTY_HOME="${1}"
source "${2}"
if is_installed "nonexistent"; then
    echo "installed"
else
    echo "not installed"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_not_installed.sh" "$ARTY_HOME" "$ARTY_SH")
    
    assert_equals "not installed" "$output" "Should detect non-existent library"
    
    teardown
}

# Test: mark_installing and is_installing
test_circular_dependency_detection() {
    setup
    
    cat > "$TEST_DIR/test_circular.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

# Test marking as installing
mark_installing "lib1"
if is_installing "lib1"; then
    echo "lib1 marked"
fi

# Test unmarking
unmark_installing "lib1"
if is_installing "lib1"; then
    echo "still marked"
else
    echo "unmarked"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_circular.sh" "$ARTY_SH")
    
    assert_contains "$output" "lib1 marked" "Should mark library as installing"
    assert_contains "$output" "unmarked" "Should unmark library after installing"
    
    teardown
}

# Test: get_lib_name extracts library name
test_get_lib_name() {
    setup
    
    cat > "$TEST_DIR/test_lib_name.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

get_lib_name "https://github.com/user/my-library.git"
get_lib_name "https://github.com/user/another-lib"
get_lib_name "git@github.com:user/ssh-lib.git"
EOF
    
    output=$(bash "$TEST_DIR/test_lib_name.sh" "$ARTY_SH")
    
    assert_contains "$output" "my-library" "Should extract name from .git URL"
    assert_contains "$output" "another-lib" "Should extract name from URL without .git"
    assert_contains "$output" "ssh-lib" "Should extract name from SSH URL"
    
    teardown
}

# Test: logging functions produce output
test_logging_functions() {
    setup
    
    cat > "$TEST_DIR/test_logging.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

log_info "Info message"
log_success "Success message"
log_warn "Warning message"
log_error "Error message"
EOF
    
    output=$(bash "$TEST_DIR/test_logging.sh" "$ARTY_SH" 2>&1)
    
    assert_contains "$output" "Info message" "Should output info messages"
    assert_contains "$output" "Success message" "Should output success messages"
    assert_contains "$output" "Warning message" "Should output warning messages"
    assert_contains "$output" "Error message" "Should output error messages"
    
    teardown
}

# Test: init_arty creates directories
test_init_arty_creates_dirs() {
    setup
    
    export ARTY_HOME="$TEST_DIR/.arty"
    
    cat > "$TEST_DIR/test_init.sh" << 'EOF'
#!/usr/bin/env bash
export ARTY_HOME="${1}"
source "${2}"
init_arty
EOF
    
    bash "$TEST_DIR/test_init.sh" "$ARTY_HOME" "$ARTY_SH" 2>/dev/null
    
    assert_dir_exists "$ARTY_HOME" "Should create ARTY_HOME directory"
    assert_dir_exists "$ARTY_HOME/libs" "Should create libs directory"
    assert_dir_exists "$ARTY_HOME/bin" "Should create bin directory"
    
    teardown
}

# Test: init_arty is idempotent
test_init_arty_idempotent() {
    setup
    
    export ARTY_HOME="$TEST_DIR/.arty"
    
    cat > "$TEST_DIR/test_idempotent.sh" << 'EOF'
#!/usr/bin/env bash
export ARTY_HOME="${1}"
source "${2}"
init_arty
init_arty
init_arty
echo "success"
EOF
    
    output=$(bash "$TEST_DIR/test_idempotent.sh" "$ARTY_HOME" "$ARTY_SH" 2>&1)
    
    assert_contains "$output" "success" "Should handle multiple init_arty calls"
    assert_dir_exists "$ARTY_HOME" "Directory should still exist"
    
    teardown
}

# Test: normalize_lib_id is case-insensitive
test_normalize_lib_id_case_insensitive() {
    setup
    
    cat > "$TEST_DIR/test_normalize_case.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

id1=$(normalize_lib_id "https://github.com/User/Repo.git")
id2=$(normalize_lib_id "https://github.com/USER/REPO.git")
id3=$(normalize_lib_id "https://github.com/user/repo")

echo "$id1"
echo "$id2"
echo "$id3"
EOF
    
    output=$(bash "$TEST_DIR/test_normalize_case.sh" "$ARTY_SH")
    
    # All three should be the same
    line1=$(echo "$output" | sed -n '1p')
    line2=$(echo "$output" | sed -n '2p')
    line3=$(echo "$output" | sed -n '3p')
    
    assert_equals "$line1" "$line2" "Case variations should normalize the same (1==2)"
    assert_equals "$line2" "$line3" "Case variations should normalize the same (2==3)"
    
    teardown
}

# Run all tests
run_tests() {
    log_section "Helper Functions Tests"
    
    test_check_yq_detects_missing
    test_is_installed_check
    test_is_installed_not_found
    test_circular_dependency_detection
    test_get_lib_name
    test_logging_functions
    test_init_arty_creates_dirs
    test_init_arty_idempotent
    test_normalize_lib_id_case_insensitive
    
    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
