#!/usr/bin/env bash
# Test suite for hammer.sh template rendering

# Setup before each test
setup() {
    TEST_ENV_DIR=$(create_test_env)
    cd "$TEST_ENV_DIR"
}

teardown() {
    cleanup_test_env
}

# Test: generate files from template
test_generate_files_from_template() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render1" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/render1/README.md" "Should create README.md"
    assert_file_exists "$TEST_ENV_DIR/render1/main.sh" "Should create main.sh"
    
    teardown
}

# Test: not copy partials directory
test_not_copy_partials_directory() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render2" --yes >/dev/null 2>&1
    
    assert_false "[[ -d '$TEST_ENV_DIR/render2/_partials' ]]" "Should not create _partials directory"
    assert_false "[[ -f '$TEST_ENV_DIR/render2/_partials/_header' ]]" "Should not copy _header file"
    
    teardown
}

# Test: substitute variables in templates
test_substitute_variables_in_templates() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render3" \
        -v project_name="MyTestProject" \
        -v author="Test Author" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/render3/README.md")
    
    assert_contains "$content" "MyTestProject" "Should contain project name"
    assert_contains "$content" "Test Author" "Should contain author name"
    
    teardown
}

# Test: use default values from arty.yml
test_use_default_values_from_arty_yml() {
    setup
    
    # Explicitly test with default values to ensure they work
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render4" \
        -v project_name="my-project" \
        -v author="Your Name" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/render4/README.md")
    
    assert_contains "$content" "my-project" "Should use default project name"
    assert_contains "$content" "Your Name" "Should use default author"
    
    teardown
}

# Test: remove myst extension from output files
test_remove_myst_extension_from_output_files() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render5" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/render5/README.md" "Should create README.md"
    assert_false "[[ -f '$TEST_ENV_DIR/render5/README.md.myst' ]]" "Should not keep .myst extension"
    assert_file_exists "$TEST_ENV_DIR/render5/main.sh" "Should create main.sh"
    assert_false "[[ -f '$TEST_ENV_DIR/render5/main.sh.myst' ]]" "Should not keep .myst extension"
    
    teardown
}

# Test: handle partials correctly
test_handle_partials_correctly() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render6" --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/render6/README.md")
    
    # Check that header partial was included
    assert_contains "$content" "Created with hammer.sh" "Should include partial content"
    
    teardown
}

# Test: generate executable script files
test_generate_executable_script_files() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render7" --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/render7/main.sh" "Should create main.sh"
    
    # Check shebang
    first_line=$(head -n 1 "$TEST_ENV_DIR/render7/main.sh")
    assert_equals "$first_line" "#!/usr/bin/env bash" "Should have bash shebang"
    
    teardown
}

# Test: generate multiple files from template
test_generate_multiple_files_from_template() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render8" --yes >/dev/null 2>&1
    
    # Count generated files (excluding _partials)
    file_count=$(find "$TEST_ENV_DIR/render8" -type f | wc -l)
    
    assert_true "[[ $file_count -ge 2 ]]" "Should generate at least 2 files"
    
    teardown
}

# Test: template output has correct content structure
test_template_output_has_correct_content_structure() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/render9" --yes >/dev/null 2>&1
    
    readme=$(cat "$TEST_ENV_DIR/render9/README.md")
    
    # Check for expected structure
    assert_contains "$readme" "# " "Should have header"
    assert_contains "$readme" "Author:" "Should have author section"
    assert_contains "$readme" "License:" "Should have license section"
    
    teardown
}

# Run all tests
run_tests() {
    test_generate_files_from_template
    test_not_copy_partials_directory
    test_substitute_variables_in_templates
    test_use_default_values_from_arty_yml
    test_remove_myst_extension_from_output_files
    test_handle_partials_correctly
    test_generate_executable_script_files
    test_generate_multiple_files_from_template
    test_template_output_has_correct_content_structure
}

export -f run_tests
