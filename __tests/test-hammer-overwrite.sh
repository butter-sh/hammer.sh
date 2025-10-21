#!/usr/bin/env bash
# Test suite for hammer.sh file overwriting behavior

# Setup before each test
setup() {
    TEST_ENV_DIR=$(create_test_env)
    cd "$TEST_ENV_DIR"
}

teardown() {
    cleanup_test_env
}

# Test: create new files when directory is empty
test_create_new_files_when_directory_is_empty() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/overwrite1" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/overwrite1/README.md" "Should create README.md"
    assert_file_exists "$TEST_ENV_DIR/overwrite1/main.sh" "Should create main.sh"
    
    teardown
}

# Test: overwrite files with force flag
test_overwrite_files_with_force_flag() {
    setup
    
    # First generation
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/overwrite3" \
        -v project_name="Original" \
        --yes >/dev/null 2>&1
    
    # Verify original content
    content=$(cat "$TEST_ENV_DIR/overwrite3/README.md")
    assert_contains "$content" "Original" "Should contain original project name"
    
    # Second generation with --force and different variable
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/overwrite3" \
        -v project_name="Updated" \
        --yes --force >/dev/null 2>&1
    
    # Verify updated content
    content=$(cat "$TEST_ENV_DIR/overwrite3/README.md")
    assert_contains "$content" "Updated" "Should contain updated project name"
    assert_not_contains "$content" "Original" "Should not contain original project name"
    
    teardown
}

# Test: create output directory if it doesn't exist
test_create_output_directory_if_it_doesnt_exist() {
    setup
    
    nested_dir="$TEST_ENV_DIR/deep/nested/directory"
    "$HAMMER_SH" example-template "$nested_dir" --yes >/dev/null 2>&1
    
    assert_file_exists "$nested_dir/README.md" "Should create README.md in nested directory"
    assert_file_exists "$nested_dir/main.sh" "Should create main.sh in nested directory"
    
    teardown
}

# Test: handle relative output paths
test_handle_relative_output_paths() {
    setup
    
    current_dir=$(pwd)
    cd "$TEST_ENV_DIR"
    "$HAMMER_SH" example-template ./relative-path --yes >/dev/null 2>&1
    cd "$current_dir"
    
    assert_file_exists "$TEST_ENV_DIR/relative-path/README.md" "Should create files in relative path"
    
    teardown
}

# Test: handle absolute output paths
test_handle_absolute_output_paths() {
    setup
    
    absolute_path="$TEST_ENV_DIR/absolute-path"
    "$HAMMER_SH" example-template "$absolute_path" --yes >/dev/null 2>&1
    
    assert_file_exists "$absolute_path/README.md" "Should create files in absolute path"
    
    teardown
}

# Run all tests
run_tests() {
    test_create_new_files_when_directory_is_empty
    test_overwrite_files_with_force_flag
    test_create_output_directory_if_it_doesnt_exist
    test_handle_relative_output_paths
    test_handle_absolute_output_paths
}

export -f run_tests
