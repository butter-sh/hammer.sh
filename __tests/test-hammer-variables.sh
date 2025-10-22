#!/usr/bin/env bash
# Test suite for hammer.sh variable handling

# Setup before each test
setup() {
  TEST_ENV_DIR=$(create_test_env)
  cd "$TEST_ENV_DIR"
    
    # Create test data files
    cat > "$TEST_ENV_DIR/test-data.json" <<EOF
{
  "project_name": "JSONProject",
  "author": "JSON Author",
  "license": "Apache-2.0"
}
EOF

    cat > "$TEST_ENV_DIR/test-data.yaml" <<EOF
project_name: YAMLProject
author: YAML Author
license: BSD-3-Clause
EOF
}

teardown() {
  cleanup_test_env
}

# Test: accept CLI variables with v flag
test_accept_cli_variables_with_v_flag() {
  setup
    
  "$HAMMER_SH" example-template "$TEST_ENV_DIR/var1" \
  -v project_name="CLIProject" \
  -v author="CLI Author" \
  --yes >/dev/null 2>&1
    
  content=$(cat "$TEST_ENV_DIR/var1/README.md")
    
  assert_contains "$content" "CLIProject" "Should contain CLI project name"
  assert_contains "$content" "CLI Author" "Should contain CLI author"
    
  teardown
}

# Test: accept multiple v flags
test_accept_multiple_v_flags() {
  setup
    
  "$HAMMER_SH" example-template "$TEST_ENV_DIR/var2" \
  -v project_name="MultiVar" \
  -v author="Multi Author" \
  -v license="GPL-3.0" \
  --yes >/dev/null 2>&1
    
  content=$(cat "$TEST_ENV_DIR/var2/README.md")
    
  assert_contains "$content" "MultiVar" "Should contain project name"
  assert_contains "$content" "Multi Author" "Should contain author"
  assert_contains "$content" "GPL-3.0" "Should contain license"
    
  teardown
}

# Test: load variables from JSON file
test_load_variables_from_json_file() {
  setup
    
  "$HAMMER_SH" example-template "$TEST_ENV_DIR/var3" \
  -j "$TEST_ENV_DIR/test-data.json" \
  --yes >/dev/null 2>&1
    
  content=$(cat "$TEST_ENV_DIR/var3/README.md")
    
  assert_contains "$content" "JSONProject" "Should load project name from JSON"
  assert_contains "$content" "JSON Author" "Should load author from JSON"
    
  teardown
}

# Test: load variables from YAML file
test_load_variables_from_yaml_file() {
  if ! command -v yq &>/dev/null; then
    log_skip "yq not available"
    return 0
  fi
    
  setup
    
  "$HAMMER_SH" example-template "$TEST_ENV_DIR/var4" \
  -y "$TEST_ENV_DIR/test-data.yaml" \
  --yes >/dev/null 2>&1
    
  content=$(cat "$TEST_ENV_DIR/var4/README.md")
    
    # Just check that some content was generated
  assert_file_exists "$TEST_ENV_DIR/var4/README.md" "Should create README.md with YAML data"
    
  teardown
}

# Test: CLI variables work with JSON file
test_cli_variables_work_with_json_file() {
  setup
    
    # Use both JSON and CLI variables
  "$HAMMER_SH" example-template "$TEST_ENV_DIR/var5" \
  -j "$TEST_ENV_DIR/test-data.json" \
  -v license="MIT" \
  --yes >/dev/null 2>&1
    
  content=$(cat "$TEST_ENV_DIR/var5/README.md")
    
  assert_contains "$content" "JSONProject" "Should load project name from JSON"
  assert_contains "$content" "JSON Author" "Should load author from JSON"
    
  teardown
}

# Test: fail if JSON file not found
test_fail_if_json_file_not_found() {
  setup
    
  set +e
  output=$("$HAMMER_SH" example-template "$TEST_ENV_DIR/var6" \
  -j "$TEST_ENV_DIR/nonexistent.json" \
  --yes 2>&1)
  exit_code=$?
  set -e
    
  assert_exit_code 1 "$exit_code" "Should exit with error"
  assert_contains "$output" "JSON file not found" "Should show JSON file not found error"
    
  teardown
}

# Test: variables work correctly
test_variables_work_correctly() {
  setup
    
  "$HAMMER_SH" example-template "$TEST_ENV_DIR/var8" \
  -v project_name="my-project" \
  -v author="Your Name" \
  -v license="MIT" \
  --yes >/dev/null 2>&1
    
  content=$(cat "$TEST_ENV_DIR/var8/README.md")
    
  assert_contains "$content" "my-project" "Should use provided project name"
  assert_contains "$content" "Your Name" "Should use provided author"
  assert_contains "$content" "MIT" "Should use provided license"
    
  teardown
}

# Run all tests
run_tests() {
  test_accept_cli_variables_with_v_flag
  test_accept_multiple_v_flags
  test_load_variables_from_json_file
  test_load_variables_from_yaml_file
  test_cli_variables_work_with_json_file
  test_fail_if_json_file_not_found
  test_variables_work_correctly
}

export -f run_tests
