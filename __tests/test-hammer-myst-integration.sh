#!/usr/bin/env bash
# Test suite for hammer.sh integration with myst.sh

# Setup before each test
setup() {
    TEST_ENV_DIR=$(create_test_env)
    cd "$TEST_ENV_DIR"
}

teardown() {
    cleanup_test_env
}

# Test: find myst.sh in .arty/bin
test_find_myst_sh_in_arty_bin() {
    setup
    
    # hammer.sh should find myst via check_myst function
    set +e
    output=$("$HAMMER_SH" example-template "$TEST_ENV_DIR/myst1" --yes 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 0 "$exit_code" "Should successfully find and use myst.sh"
    # Should not show "myst.sh not found" error
    assert_not_contains "$output" "myst.sh not found" "Should not show myst.sh not found error"
    
    teardown
}

# Test: pass variables to myst.sh
test_pass_variables_to_myst_sh() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/myst2" \
        -v project_name="MystTest" \
        -v author="Myst Author" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/myst2/README.md")
    
    assert_contains "$content" "MystTest" "Should pass project_name to myst.sh"
    assert_contains "$content" "Myst Author" "Should pass author to myst.sh"
    
    teardown
}

# Test: handle myst.sh partials correctly
test_handle_myst_sh_partials_correctly() {
    setup
    
    "$HAMMER_SH" example-template "$TEST_ENV_DIR/myst3" --yes >/dev/null 2>&1
    
    readme=$(cat "$TEST_ENV_DIR/myst3/README.md")
    
    # Check that partial content is included
    assert_contains "$readme" "Created with hammer.sh" "Should include partial content"
    # Check that partial markers are not in output
    assert_not_contains "$readme" "{{>" "Should not contain partial syntax markers"
    
    teardown
}

# Test: process myst.sh conditionals
test_process_myst_sh_conditionals() {
    setup
    
    # Create a test template with conditionals
    test_template="$TEST_ENV_DIR/conditional-template"
    mkdir -p "$test_template"
    cat > "$test_template/test.md.myst" <<'EOF'
# {{project_name}}
{{#if author}}
Author: {{author}}
{{/if}}
{{#unless author}}
No author specified
{{/unless}}
EOF
    
    # Test with author
    "$HAMMER_SH" -t "$TEST_ENV_DIR" conditional-template "$TEST_ENV_DIR/myst4a" \
        -v project_name="Test" \
        -v author="TestAuthor" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/myst4a/test.md")
    assert_contains "$content" "Author: TestAuthor" "Should show author when provided"
    assert_not_contains "$content" "No author specified" "Should not show 'no author' message"
    
    # Test without author
    "$HAMMER_SH" -t "$TEST_ENV_DIR" conditional-template "$TEST_ENV_DIR/myst4b" \
        -v project_name="Test" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/myst4b/test.md")
    assert_contains "$content" "No author specified" "Should show 'no author' message"
    
    teardown
}

# Test: process myst.sh each loops
test_process_myst_sh_each_loops() {
    setup
    
    # Create a test template with loops
    test_template="$TEST_ENV_DIR/loop-template"
    mkdir -p "$test_template"
    cat > "$test_template/test.md.myst" <<'EOF'
# Features
{{#each features}}
- {{this}}
{{/each}}
EOF
    
    # myst.sh handles comma-separated values for loops
    "$HAMMER_SH" -t "$TEST_ENV_DIR" loop-template "$TEST_ENV_DIR/myst5" \
        -v features="feature1,feature2,feature3" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/myst5/test.md")
    
    assert_contains "$content" "feature1" "Should process first item in loop"
    assert_contains "$content" "feature2" "Should process second item in loop"
    assert_contains "$content" "feature3" "Should process third item in loop"
    
    teardown
}

# Test: handle myst.sh syntax gracefully
test_handle_myst_sh_syntax_gracefully() {
    setup
    
    # Create a template with potentially problematic myst syntax
    test_template="$TEST_ENV_DIR/syntax-template"
    mkdir -p "$test_template"
    cat > "$test_template/test.md.myst" <<'EOF'
# {{project_name}}
{{description}}
EOF
    
    # Even if description is not provided, should still process
    "$HAMMER_SH" -t "$TEST_ENV_DIR" syntax-template "$TEST_ENV_DIR/myst6" \
        -v project_name="Test" \
        --yes >/dev/null 2>&1
    
    assert_file_exists "$TEST_ENV_DIR/myst6/test.md" "Should create file despite missing variables"
    
    content=$(cat "$TEST_ENV_DIR/myst6/test.md")
    assert_contains "$content" "Test" "Should still process provided variables"
    
    teardown
}

# Test: nested variable substitution
test_nested_variable_substitution() {
    setup
    
    # Create a template with nested structure
    test_template="$TEST_ENV_DIR/nested-vars"
    mkdir -p "$test_template/config"
    cat > "$test_template/config/settings.conf.myst" <<'EOF'
[project]
name={{project_name}}
author={{author}}
year={{year}}
EOF
    
    "$HAMMER_SH" -t "$TEST_ENV_DIR" nested-vars "$TEST_ENV_DIR/myst7" \
        -v project_name="MyProject" \
        -v author="John Doe" \
        -v year="2025" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/myst7/config/settings.conf")
    
    assert_contains "$content" "name=MyProject" "Should substitute project_name"
    assert_contains "$content" "author=John Doe" "Should substitute author"
    assert_contains "$content" "year=2025" "Should substitute year"
    
    teardown
}

# Test: special characters in variables
test_special_characters_in_variables() {
    setup
    
    # Create a simple template
    test_template="$TEST_ENV_DIR/special-chars"
    mkdir -p "$test_template"
    echo "Project: {{project_name}}" > "$test_template/test.txt.myst"
    
    "$HAMMER_SH" -t "$TEST_ENV_DIR" special-chars "$TEST_ENV_DIR/myst8" \
        -v project_name="My-Project_2025" \
        --yes >/dev/null 2>&1
    
    content=$(cat "$TEST_ENV_DIR/myst8/test.txt")
    
    assert_contains "$content" "My-Project_2025" "Should handle special characters in variables"
    
    teardown
}

# Run all tests
run_tests() {
    test_find_myst_sh_in_arty_bin
    test_pass_variables_to_myst_sh
    test_handle_myst_sh_partials_correctly
    test_process_myst_sh_conditionals
    test_process_myst_sh_each_loops
    test_handle_myst_sh_syntax_gracefully
    test_nested_variable_substitution
    test_special_characters_in_variables
}

export -f run_tests
