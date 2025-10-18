#!/usr/bin/env bash
# Test suite for judge.sh snapshot functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export SNAPSHOT_DIR="$TEST_DIR/snapshots"
    mkdir -p "$SNAPSHOT_DIR"
    cd "$TEST_DIR"
    source "$TEST_HELPERS"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: create_snapshot creates snapshot file
test_create_snapshot() {
    setup
    
    create_snapshot "test-snap" "test content"
    
    assert_file_exists "${SNAPSHOT_DIR}/test-snap.snapshot" "Snapshot file should be created"
    
    teardown
}

# Test: create_snapshot normalizes content
test_create_snapshot_normalizes() {
    setup
    
    create_snapshot "test-snap" "content with trailing spaces   "
    
    content=$(cat "${SNAPSHOT_DIR}/test-snap.snapshot")
    assert_true "[[ ! \"$content\" =~ [[:space:]]+$ ]]" "Should remove trailing spaces"
    
    teardown
}

# Test: update_snapshot updates existing snapshot
test_update_snapshot() {
    setup
    
    create_snapshot "test-snap" "original content"
    update_snapshot "test-snap" "updated content"
    
    content=$(cat "${SNAPSHOT_DIR}/test-snap.snapshot")
    assert_equals "updated content" "$content" "Snapshot should be updated"
    
    teardown
}

# Test: compare_snapshot matches identical content
test_compare_snapshot_match() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "test-snap" "test content"
    compare_snapshot "test-snap" "test content" "Snapshot comparison"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should pass on match"
    
    teardown
}

# Test: compare_snapshot fails on mismatch
test_compare_snapshot_mismatch() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    create_snapshot "test-snap" "original content"
    
    set +e
    compare_snapshot "test-snap" "different content" "Snapshot comparison"
    result=$?
    set -e
    
    assert_true "[[ $result -ne 0 ]]" "Should fail on mismatch"
    
    teardown
}

# Test: compare_snapshot creates missing snapshot
test_compare_snapshot_creates_missing() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    compare_snapshot "new-snap" "new content" "New snapshot"
    
    assert_file_exists "${SNAPSHOT_DIR}/new-snap.snapshot" "Should create missing snapshot"
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should pass when creating"
    
    teardown
}

# Test: normalize_output removes ANSI codes
test_normalize_output_ansi() {
    setup
    
    input=$'\033[0;31mRed text\033[0m'
    output=$(normalize_output "$input")
    
    assert_true "[[ ! \"$output\" =~ $'\033' ]]" "Should remove ANSI codes"
    assert_contains "$output" "Red text" "Should preserve text"
    
    teardown
}

# Test: normalize_output removes trailing whitespace
test_normalize_output_whitespace() {
    setup
    
    input="content with spaces   "
    output=$(normalize_output "$input")
    
    assert_true "[[ ! \"$output\" =~ [[:space:]]+$ ]]" "Should remove trailing whitespace"
    
    teardown
}

# Test: snapshot comparison ignores whitespace differences
test_snapshot_whitespace_insensitive() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "test-snap" "content"
    compare_snapshot "test-snap" "content   " "Whitespace test"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should ignore trailing whitespace"
    
    teardown
}

# Test: snapshot comparison ignores ANSI codes
test_snapshot_ansi_insensitive() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "test-snap" "plain text"
    compare_snapshot "test-snap" $'\033[0;32mplain text\033[0m' "ANSI test"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should ignore ANSI codes"
    
    teardown
}

# Test: multiple snapshots can coexist
test_multiple_snapshots() {
    setup
    
    create_snapshot "snap1" "content 1"
    create_snapshot "snap2" "content 2"
    create_snapshot "snap3" "content 3"
    
    assert_file_exists "${SNAPSHOT_DIR}/snap1.snapshot" "Snapshot 1 should exist"
    assert_file_exists "${SNAPSHOT_DIR}/snap2.snapshot" "Snapshot 2 should exist"
    assert_file_exists "${SNAPSHOT_DIR}/snap3.snapshot" "Snapshot 3 should exist"
    
    content1=$(cat "${SNAPSHOT_DIR}/snap1.snapshot")
    content2=$(cat "${SNAPSHOT_DIR}/snap2.snapshot")
    
    assert_true "[[ \"$content1\" != \"$content2\" ]]" "Snapshots should be independent"
    
    teardown
}

# Test: snapshot names can include hyphens
test_snapshot_names_with_hyphens() {
    setup
    
    create_snapshot "test-snap-name-123" "content"
    
    assert_file_exists "${SNAPSHOT_DIR}/test-snap-name-123.snapshot" "Snapshot with hyphens should work"
    
    teardown
}

# Test: snapshot handles multiline content
test_snapshot_multiline() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    multiline="line 1
line 2
line 3"
    
    create_snapshot "multiline" "$multiline"
    compare_snapshot "multiline" "$multiline" "Multiline test"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should handle multiline content"
    
    teardown
}

# Test: snapshot handles empty content
test_snapshot_empty() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "empty" ""
    compare_snapshot "empty" "" "Empty test"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should handle empty content"
    
    teardown
}

# Run all tests
run_tests() {
    test_create_snapshot
    test_create_snapshot_normalizes
    test_update_snapshot
    test_compare_snapshot_match
    test_compare_snapshot_mismatch
    test_compare_snapshot_creates_missing
    test_normalize_output_ansi
    test_normalize_output_whitespace
    test_snapshot_whitespace_insensitive
    test_snapshot_ansi_insensitive
    test_multiple_snapshots
    test_snapshot_names_with_hyphens
    test_snapshot_multiline
    test_snapshot_empty
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
