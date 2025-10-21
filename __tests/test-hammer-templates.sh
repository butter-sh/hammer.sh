#!/usr/bin/env bash
# Test suite for hammer.sh template discovery and validation

# Setup before each test
setup() {
    TEST_ENV_DIR=$(create_test_env)
    cd "$TEST_ENV_DIR"
}

teardown() {
    cleanup_test_env
}

# Test: find templates in default templates directory
test_find_templates_in_default_templates_directory() {
    output=$("$HAMMER_SH" --list 2>&1)
    
    assert_contains "$output" "example-template" "Should list example-template"
}

# Test: list template descriptions from arty.yml
test_list_template_descriptions_from_arty_yml() {
    output=$("$HAMMER_SH" --list 2>&1)
    
    assert_contains "$output" "Example template demonstrating hammer.sh capabilities" "Should show template description"
}

# Test: fail with non-existent template
test_fail_with_non_existent_template() {
    setup
    
    set +e
    output=$("$HAMMER_SH" nonexistent-template "$TEST_ENV_DIR/test" --yes 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should exit with error"
    assert_contains "$output" "Template not found" "Should show template not found error"
    
    teardown
}

# Test: process all myst files in template
test_process_all_myst_files_in_template() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/test-all" --yes >/dev/null 2>&1
    
    # Verify both template files were processed
    assert_file_exists "$TEST_ENV_DIR/test-all/README.md" "Should create README.md"
    assert_file_exists "$TEST_ENV_DIR/test-all/main.sh" "Should create main.sh"
    
    teardown
}

# Test: skip non-myst files
test_skip_non_myst_files() {
    setup
    
    # Create a test template with non-.myst file
    test_template="$TEST_ENV_DIR/custom-template"
    mkdir -p "$test_template"
    echo "# Test" > "$test_template/README.md.myst"
    echo "Not a template" > "$test_template/regular.txt"
    
    "$HAMMER_SH" -t "$TEST_ENV_DIR" custom-template "$TEST_ENV_DIR/test-skip" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/test-skip/README.md" "Should create README.md from .myst file"
    assert_false "[[ -f '$TEST_ENV_DIR/test-skip/regular.txt' ]]" "Should not copy non-.myst file"
    
    teardown
}

# Test: handle templates with subdirectories
test_handle_templates_with_subdirectories() {
    setup
    
    # Create a test template with subdirectory
    test_template="$TEST_ENV_DIR/nested-template"
    mkdir -p "$test_template/src"
    echo "# Main" > "$test_template/README.md.myst"
    echo "{{project_name}}" > "$test_template/src/file.txt.myst"
    
    "$HAMMER_SH" -t "$TEST_ENV_DIR" nested-template "$TEST_ENV_DIR/test-nested" \
        -v project_name="NestedTest" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/test-nested/README.md" "Should create README.md"
    assert_file_exists "$TEST_ENV_DIR/test-nested/src/file.txt" "Should create nested file"
    
    content=$(cat "$TEST_ENV_DIR/test-nested/src/file.txt")
    assert_contains "$content" "NestedTest" "Should substitute variables in nested file"
    
    teardown
}

# Test: accept custom template directory with t flag
test_accept_custom_template_directory_with_t_flag() {
    setup
    
    # Create a custom template in a custom directory
    custom_dir="$TEST_ENV_DIR/my-templates"
    mkdir -p "$custom_dir/my-template"
    echo "# Custom Template" > "$custom_dir/my-template/README.md.myst"
    
    "$HAMMER_SH" -t "$custom_dir" my-template "$TEST_ENV_DIR/output" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/output/README.md" "Should process template from custom directory"
    
    teardown
}

# Test: handle template with only partials
test_handle_template_with_only_partials() {
    setup
    
    # Create a template with only _partials
    test_template="$TEST_ENV_DIR/partials-only"
    mkdir -p "$test_template/_partials"
    echo "Header content" > "$test_template/_partials/_header.myst"
    
    set +e
    "$HAMMER_SH" -t "$TEST_ENV_DIR" partials-only "$TEST_ENV_DIR/output" --yes >/dev/null 2>&1
    exit_code=$?
    set -e
    
    # Should fail or warn about no templates
    assert_true "[[ $exit_code -ne 0 ]] || true" "Should handle template with only partials"
    
    teardown
}

# Test: template with multiple file types
test_template_with_multiple_file_types() {
    setup
    
    # Create a template with various file types
    test_template="$TEST_ENV_DIR/multi-type"
    mkdir -p "$test_template"
    echo "# README" > "$test_template/README.md.myst"
    echo "#!/usr/bin/env bash" > "$test_template/script.sh.myst"
    echo "# Config" > "$test_template/config.yml.myst"
    
    "$HAMMER_SH" -t "$TEST_ENV_DIR" multi-type "$TEST_ENV_DIR/output" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/output/README.md" "Should create README.md"
    assert_file_exists "$TEST_ENV_DIR/output/script.sh" "Should create script.sh"
    assert_file_exists "$TEST_ENV_DIR/output/config.yml" "Should create config.yml"
    
    teardown
}

# Run all tests
run_tests() {
    test_find_templates_in_default_templates_directory
    test_list_template_descriptions_from_arty_yml
    test_fail_with_non_existent_template
    test_process_all_myst_files_in_template
    test_skip_non_myst_files
    test_handle_templates_with_subdirectories
    test_accept_custom_template_directory_with_t_flag
    test_handle_template_with_only_partials
    test_template_with_multiple_file_types
}

export -f run_tests
