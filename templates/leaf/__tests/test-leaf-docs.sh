#!/usr/bin/env bash
# Test suite for leaf.sh documentation generation

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

# Test: generate_docs_page creates output file
test_generate_docs_creates_output() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
description: "Test project"
EOF
    
    cat > test-project/README.md << 'EOF'
# Test Project
This is a test.
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    assert_file_exists "output/index.html" "Should create index.html"
    
    teardown
}

# Test: generated docs contains project name
test_docs_contains_project_name() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "my-awesome-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "my-awesome-project" "Should contain project name"
    
    teardown
}

# Test: generated docs contains version
test_docs_contains_version() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "2.5.1"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "2.5.1" "Should contain version"
    
    teardown
}

# Test: generated docs contains description
test_docs_contains_description() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
description: "A unique test description"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "unique test description" "Should contain description"
    
    teardown
}

# Test: generated docs includes README content
test_docs_includes_readme() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/README.md << 'EOF'
# Test Project

This is **unique** content from the README file.

## Features
- Feature 1
- Feature 2
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "unique" "Should include README content"
    assert_contains "$html_content" "Features" "Should include README sections"
    
    teardown
}

# Test: generated docs handles missing README
test_docs_handles_missing_readme() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    assert_file_exists "output/index.html" "Should create output even without README"
    assert_contains "$(cat output/index.html)" "No README" "Should show placeholder for missing README"
    
    teardown
}

# Test: generated docs includes source files
test_docs_includes_source_files() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/main.sh << 'EOF'
#!/usr/bin/env bash
echo "Hello World"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "main.sh" "Should include source filename"
    assert_contains "$html_content" "Hello World" "Should include source content"
    
    teardown
}

# Test: generated docs escapes HTML in source code
test_docs_escapes_html() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/test.sh << 'EOF'
#!/usr/bin/env bash
echo "<script>alert('test')</script>"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "&lt;script&gt;" "Should escape < characters"
    assert_contains "$html_content" "&lt;/script&gt;" "Should escape closing tags"
    
    teardown
}

# Test: generated docs includes examples
test_docs_includes_examples() {
    setup
    
    mkdir -p test-project/examples
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/examples/basic.sh << 'EOF'
#!/usr/bin/env bash
# Basic usage example
echo "Example"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "basic.sh" "Should include example filename"
    assert_contains "$html_content" "Example" "Should include example content"
    
    teardown
}

# Test: generated docs has proper HTML structure
test_docs_html_structure() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "<!DOCTYPE html>" "Should have DOCTYPE"
    assert_contains "$html_content" "<html" "Should have html tag"
    assert_contains "$html_content" "<head>" "Should have head section"
    assert_contains "$html_content" "<body" "Should have body tag"
    
    teardown
}

# Test: generated docs includes Tailwind CSS
test_docs_includes_tailwind() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "tailwindcss.com" "Should include Tailwind CSS"
    
    teardown
}

# Test: generated docs includes Highlight.js
test_docs_includes_highlightjs() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "highlight.js" "Should include Highlight.js"
    assert_contains "$html_content" "hljs" "Should include hljs reference"
    
    teardown
}

# Test: generated docs includes theme toggle
test_docs_includes_theme_toggle() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html_content=$(cat output/index.html)
    assert_contains "$html_content" "themeToggle" "Should include theme toggle"
    assert_contains "$html_content" "localStorage" "Should use localStorage for theme"
    
    teardown
}

# Test: docs uses custom base path
test_docs_custom_base_path() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" test-project --base-path /custom/ -o output 2>&1
    
    assert_contains "$(cat output/index.html)" 'base href="/custom/"' "Should set custom base path"
    
    teardown
}

# Test: docs uses custom icon
test_docs_custom_icon() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo '<svg id="custom-icon"></svg>' > custom.svg
    
    bash "$LEAF_SH" test-project --logo custom.svg -o output 2>&1
    
    assert_contains "$(cat output/index.html)" "custom-icon" "Should use custom icon"
    
    teardown
}

# Test: docs generation reports progress
test_docs_generation_progress() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_contains "$output" "Generating documentation" "Should report generation"
    assert_contains "$output" "generated at" "Should report completion"
    
    teardown
}

# Run all tests
run_tests() {
    test_generate_docs_creates_output
    test_docs_contains_project_name
    test_docs_contains_version
    test_docs_contains_description
    test_docs_includes_readme
    test_docs_handles_missing_readme
    test_docs_includes_source_files
    test_docs_escapes_html
    test_docs_includes_examples
    test_docs_html_structure
    test_docs_includes_tailwind
    test_docs_includes_highlightjs
    test_docs_includes_theme_toggle
    test_docs_custom_base_path
    test_docs_custom_icon
    test_docs_generation_progress
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
