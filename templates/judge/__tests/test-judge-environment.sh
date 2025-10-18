#!/usr/bin/env bash
# Test suite for judge.sh test environment utilities

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export TEMP_DIR="$TEST_DIR/temp"
    export SNAPSHOT_DIR="$TEST_DIR/snapshots"
    cd "$TEST_DIR"
    source "$TEST_HELPERS" 2>/dev/null
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: setup_test_env creates directories
test_setup_creates_dirs() {
    setup
    
    setup_test_env > /dev/null 2>&1
    
    if [[ -d "$SNAPSHOT_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        echo "✓ setup_test_env creates directories"
        teardown
        return 0
    else
        echo "✗ Directory creation failed"
        teardown
        return 1
    fi
}

# Test: setup_test_env is idempotent
test_setup_idempotent() {
    setup
    
    setup_test_env > /dev/null 2>&1
    setup_test_env > /dev/null 2>&1
    setup_test_env > /dev/null 2>&1
    
    if [[ -d "$SNAPSHOT_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        echo "✓ setup_test_env is idempotent"
        teardown
        return 0
    else
        echo "✗ Idempotency failed"
        teardown
        return 1
    fi
}

# Test: setup_test_env cleans temp directory
test_setup_cleans_temp() {
    setup
    
    mkdir -p "$TEMP_DIR"
    touch "$TEMP_DIR/oldfile.txt"
    
    setup_test_env > /dev/null 2>&1
    
    if [[ ! -f "$TEMP_DIR/oldfile.txt" ]] && [[ -d "$TEMP_DIR" ]]; then
        echo "✓ setup_test_env cleans temp directory"
        teardown
        return 0
    else
        echo "✗ Temp cleaning failed"
        teardown
        return 1
    fi
}

# Test: cleanup_test_env removes temp directory
test_cleanup_removes_temp() {
    setup
    
    mkdir -p "$TEMP_DIR"
    touch "$TEMP_DIR/testfile.txt"
    
    cleanup_test_env > /dev/null 2>&1
    
    if [[ ! -d "$TEMP_DIR" ]]; then
        echo "✓ cleanup_test_env removes temp directory"
        teardown
        return 0
    else
        echo "✗ Temp removal failed"
        teardown
        return 1
    fi
}

# Test: cleanup_test_env handles missing directory
test_cleanup_missing_dir() {
    setup
    
    set +e
    cleanup_test_env > /dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -eq 0 ]]; then
        echo "✓ cleanup handles missing directory"
        teardown
        return 0
    else
        echo "✗ Missing directory handling failed"
        teardown
        return 1
    fi
}

# Test: capture_output captures stdout
test_capture_stdout() {
    setup
    
    output=$(capture_output "echo 'test output'")
    
    if [[ "$output" == "test output" ]]; then
        echo "✓ capture_output captures stdout"
        teardown
        return 0
    else
        echo "✗ Stdout capture failed"
        teardown
        return 1
    fi
}

# Test: capture_output captures stderr
test_capture_stderr() {
    setup
    
    output=$(capture_output "echo 'error output' >&2")
    
    if [[ "$output" == "error output" ]]; then
        echo "✓ capture_output captures stderr"
        teardown
        return 0
    else
        echo "✗ Stderr capture failed"
        teardown
        return 1
    fi
}

# Test: capture_output sets exit code
test_capture_exit_code() {
    setup
    
    CAPTURED_EXIT_CODE=0
    capture_output "exit 42" || true
    
    if [[ $CAPTURED_EXIT_CODE -eq 42 ]]; then
        echo "✓ capture_output captures exit code"
        teardown
        return 0
    else
        echo "✗ Exit code capture failed (got $CAPTURED_EXIT_CODE)"
        teardown
        return 1
    fi
}

# Test: capture_output with successful command
test_capture_success() {
    setup
    
    CAPTURED_EXIT_CODE=99
    output=$(capture_output "echo success; exit 0")
    
    if [[ "$output" == "success" ]] && [[ $CAPTURED_EXIT_CODE -eq 0 ]]; then
        echo "✓ capture_output handles success"
        teardown
        return 0
    else
        echo "✗ Success handling failed"
        teardown
        return 1
    fi
}

# Test: capture_output with failed command
test_capture_failure() {
    setup
    
    CAPTURED_EXIT_CODE=0
    output=$(capture_output "echo failure; exit 1" || true)
    
    if [[ "$output" == "failure" ]] && [[ $CAPTURED_EXIT_CODE -eq 1 ]]; then
        echo "✓ capture_output handles failure"
        teardown
        return 0
    else
        echo "✗ Failure handling failed"
        teardown
        return 1
    fi
}

# Test: capture_output handles complex commands
test_capture_complex() {
    setup
    
    output=$(capture_output "echo line1; echo line2; echo line3")
    
    if [[ "$output" == *"line1"* ]] && \
       [[ "$output" == *"line2"* ]] && \
       [[ "$output" == *"line3"* ]]; then
        echo "✓ capture_output handles complex commands"
        teardown
        return 0
    else
        echo "✗ Complex command capture failed"
        teardown
        return 1
    fi
}

# Test: capture_output handles pipes
test_capture_pipes() {
    setup
    
    output=$(capture_output "echo 'test' | tr 'a-z' 'A-Z'")
    
    if [[ "$output" == "TEST" ]]; then
        echo "✓ capture_output handles pipes"
        teardown
        return 0
    else
        echo "✗ Pipe handling failed"
        teardown
        return 1
    fi
}

# Test: temp directory isolation
test_temp_dir_isolation() {
    setup
    
    setup_test_env > /dev/null 2>&1
    echo "test" > "$TEMP_DIR/test.txt"
    
    setup_test_env > /dev/null 2>&1
    
    if [[ ! -f "$TEMP_DIR/test.txt" ]]; then
        echo "✓ Temp directory isolation works"
        teardown
        return 0
    else
        echo "✗ Temp isolation failed"
        teardown
        return 1
    fi
}

# Test: snapshot directory persistence
test_snapshot_persistence() {
    setup
    
    setup_test_env > /dev/null 2>&1
    echo "snapshot" > "$SNAPSHOT_DIR/test.snapshot"
    
    setup_test_env > /dev/null 2>&1
    
    if [[ -f "$SNAPSHOT_DIR/test.snapshot" ]]; then
        echo "✓ Snapshot directory persists"
        teardown
        return 0
    else
        echo "✗ Snapshot persistence failed"
        teardown
        return 1
    fi
}

# Test: environment variables exported
test_exported_functions() {
    setup
    
    if type log_info > /dev/null 2>&1 && \
       type capture_output > /dev/null 2>&1; then
        echo "✓ Functions are exported"
        teardown
        return 0
    else
        echo "✗ Function export failed"
        teardown
        return 1
    fi
}

# Run all tests
run_tests() {
    local total=15
    local passed=0
    
    echo "Running environment management tests..."
    echo ""
    
    test_setup_creates_dirs && passed=$((passed + 1))
    test_setup_idempotent && passed=$((passed + 1))
    test_setup_cleans_temp && passed=$((passed + 1))
    test_cleanup_removes_temp && passed=$((passed + 1))
    test_cleanup_missing_dir && passed=$((passed + 1))
    test_capture_stdout && passed=$((passed + 1))
    test_capture_stderr && passed=$((passed + 1))
    test_capture_exit_code && passed=$((passed + 1))
    test_capture_success && passed=$((passed + 1))
    test_capture_failure && passed=$((passed + 1))
    test_capture_complex && passed=$((passed + 1))
    test_capture_pipes && passed=$((passed + 1))
    test_temp_dir_isolation && passed=$((passed + 1))
    test_snapshot_persistence && passed=$((passed + 1))
    test_exported_functions && passed=$((passed + 1))
    
    echo ""
    echo "═══════════════════════════════════════"
    echo "Environment Tests: $passed/$total passed"
    echo "═══════════════════════════════════════"
    
    if [[ $passed -eq $total ]]; then
        return 0
    else
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    exit $?
fi
