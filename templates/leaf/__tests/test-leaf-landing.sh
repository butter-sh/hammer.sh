#!/usr/bin/env bash
# Test suite for leaf.sh landing page generation

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

# Test: landing mode creates output file
test_landing_creates_output() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    assert_file_exists "output/index.html" "Should create landing page"
    
    teardown
}

# Test: landing page contains butter.sh branding
test_landing_contains_branding() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "butter.sh" "Should contain butter.sh branding"
    
    teardown
}

# Test: landing page uses default projects
test_landing_default_projects() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "hammer.sh" "Should include hammer.sh"
    assert_contains "$html_content" "arty.sh" "Should include arty.sh"
    assert_contains "$html_content" "leaf.sh" "Should include leaf.sh"
    
    teardown
}

# Test: landing page accepts custom projects JSON
test_landing_custom_projects_json() {
    setup
    
    projects='[{"url":"https://test.com","label":"Test Project","desc":"Test description","class":"card-project"}]'
    
    bash "$LEAF_SH" --landing --projects "$projects" -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "Test Project" "Should include custom project"
    assert_contains "$html_content" "test.com" "Should include custom URL"
    
    teardown
}

# Test: landing page reads projects from file
test_landing_projects_from_file() {
    setup
    
    cat > projects.json << 'EOF'
[
  {
    "url": "https://custom.com",
    "label": "Custom Project",
    "desc": "Custom description",
    "class": "card-project"
  }
]
EOF
    
    bash "$LEAF_SH" --landing --projects-file projects.json -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "Custom Project" "Should load from file"
    assert_contains "$html_content" "custom.com" "Should include file URL"
    
    teardown
}

# Test: landing page validates projects JSON
test_landing_validates_json() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects "not valid json" -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on invalid JSON"
    # Just check it fails - error message may vary
    assert_true "[[ $exit_code -ne 0 ]]" "Should have non-zero exit code"
    
    teardown
}

# Test: landing page rejects non-array JSON
test_landing_rejects_non_array() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects '{"url":"test"}' -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on non-array"
    assert_contains "$output" "must be an array" "Should report must be array"
    
    teardown
}

# Test: landing page warns on empty projects
test_landing_warns_empty_projects() {
    setup
    
    output=$(bash "$LEAF_SH" --landing --projects '[]' -o output 2>&1)
    
    assert_contains "$output" "empty" "Should warn about empty projects"
    
    teardown
}

# Test: landing page warns on missing required fields
test_landing_warns_missing_fields() {
    setup
    
    projects='[{"url":"https://test.com"}]'
    output=$(bash "$LEAF_SH" --landing --projects "$projects" -o output 2>&1)
    
    assert_contains "$output" "missing required fields" "Should warn about missing fields"
    
    teardown
}

# Test: landing page uses custom GitHub URL
test_landing_custom_github() {
    setup
    
    bash "$LEAF_SH" --landing --github https://github.com/my-org -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "github.com/my-org" "Should use custom GitHub URL"
    
    teardown
}

# Test: landing page uses custom base path
test_landing_custom_base_path() {
    setup
    
    bash "$LEAF_SH" --landing --base-path /landing/ -o output 2>&1
    
    assert_contains "$(cat output/index.html)" 'base href="/landing/"' "Should set custom base path"
    
    teardown
}

# Test: landing page has proper HTML structure
test_landing_html_structure() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "<!DOCTYPE html>" "Should have DOCTYPE"
    assert_contains "$html_content" "<html" "Should have html tag"
    assert_contains "$html_content" "<head>" "Should have head section"
    assert_contains "$html_content" "<body" "Should have body tag"
    
    teardown
}

# Test: landing page includes Tailwind CSS
test_landing_includes_tailwind() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "tailwindcss.com" "Should include Tailwind CSS"
    
    teardown
}

# Test: landing page includes theme toggle
test_landing_includes_theme_toggle() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "themeToggle" "Should include theme toggle"
    assert_contains "$html_content" "localStorage" "Should use localStorage for theme"
    
    teardown
}

# Test: landing page includes mobile menu
test_landing_includes_mobile_menu() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "mobileMenu" "Should include mobile menu"
    assert_contains "$html_content" "mobileMenuBtn" "Should include mobile menu button"
    
    teardown
}

# Test: landing page includes hero section
test_landing_includes_hero() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "Modern bash development" "Should include hero text"
    
    teardown
}

# Test: landing page includes projects section
test_landing_includes_projects_section() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "Our Projects" "Should include projects section header"
    assert_contains "$html_content" "projectsGrid" "Should include projects grid"
    
    teardown
}

# Test: landing page includes footer
test_landing_includes_footer() {
    setup
    
    bash "$LEAF_SH" --landing -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "<footer" "Should include footer"
    assert_contains "$html_content" "Building the future" "Should include footer text"
    
    teardown
}

# Test: landing page generation reports progress
test_landing_generation_progress() {
    setup
    
    output=$(bash "$LEAF_SH" --landing -o output 2>&1)
    
    assert_contains "$output" "Generating butter.sh landing page" "Should report generation"
    assert_contains "$output" "Landing page generated" "Should report completion"
    
    teardown
}

# Test: landing page prioritizes projects-file over projects
test_landing_projects_file_priority() {
    setup
    
    cat > projects.json << 'EOF'
[{"url":"https://from-file.com","label":"From File","desc":"File project","class":"card-project"}]
EOF
    
    projects='[{"url":"https://from-arg.com","label":"From Arg","desc":"Arg project","class":"card-project"}]'
    
    bash "$LEAF_SH" --landing --projects-file projects.json --projects "$projects" -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "From File" "Should use file over argument"
    assert_not_contains "$html_content" "From Arg" "Should not use argument when file provided"
    
    teardown
}

# Test: landing page handles missing projects file
test_landing_missing_projects_file() {
    setup
    
    set +e
    output=$(bash "$LEAF_SH" --landing --projects-file nonexistent.json -o output 2>&1)
    exit_code=$?
    set -e
    
    assert_exit_code 1 "$exit_code" "Should fail on missing file"
    assert_contains "$output" "not found" "Should report file not found"
    
    teardown
}

# Run all tests
run_tests() {
    test_landing_creates_output
    test_landing_contains_branding
    test_landing_default_projects
    test_landing_custom_projects_json
    test_landing_projects_from_file
    test_landing_validates_json
    test_landing_rejects_non_array
    test_landing_warns_empty_projects
    test_landing_warns_missing_fields
    test_landing_custom_github
    test_landing_custom_base_path
    test_landing_html_structure
    test_landing_includes_tailwind
    test_landing_includes_theme_toggle
    test_landing_includes_mobile_menu
    test_landing_includes_hero
    test_landing_includes_projects_section
    test_landing_includes_footer
    test_landing_generation_progress
    test_landing_projects_file_priority
    test_landing_missing_projects_file
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
