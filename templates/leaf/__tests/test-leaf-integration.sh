#!/usr/bin/env bash
# Integration tests for leaf.sh - complete workflows

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

# Test: complete docs generation workflow
test_complete_docs_workflow() {
    setup
    
    # Create a complete arty.sh project
    mkdir -p my-project/{examples,_assets/icon}
    
    cat > my-project/arty.yml << 'EOF'
name: "my-project"
version: "1.2.3"
description: "A complete test project"
author: "Test Author"
license: "MIT"
references:
  - https://github.com/user/dep1.git
  - https://github.com/user/dep2.git
EOF
    
    cat > my-project/README.md << 'EOF'
# My Project

This is a **complete** test project with all features.

## Installation

```bash
./install.sh
```

## Usage

Run the main script:

```bash
./main.sh
```
EOF
    
    cat > my-project/main.sh << 'EOF'
#!/usr/bin/env bash
echo "Hello from my-project"
EOF
    
    cat > my-project/helpers.sh << 'EOF'
#!/usr/bin/env bash
helper_function() {
    echo "Helper"
}
EOF
    
    cat > my-project/examples/basic.sh << 'EOF'
#!/usr/bin/env bash
# Basic usage example
./main.sh
EOF
    
    cat > my-project/_assets/icon/icon.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="40" fill="blue"/>
</svg>
EOF
    
    # Generate docs
    output=$(bash "$LEAF_SH" my-project -o docs 2>&1)
    
    # Verify output
    assert_file_exists "docs/index.html" "Should create docs"
    
    html=$(cat docs/index.html)
    assert_contains "$html" "my-project" "Should include project name"
    assert_contains "$html" "1.2.3" "Should include version"
    assert_contains "$html" "complete test project" "Should include description"
    assert_contains "$html" "Hello from my-project" "Should include main.sh content"
    assert_contains "$html" "helper_function" "Should include helpers.sh content"
    assert_contains "$html" "basic.sh" "Should include example"
    assert_contains "$html" "circle" "Should include icon"
    
    assert_contains "$output" "Found 2 source files" "Should report source files"
    assert_contains "$output" "1 examples" "Should report examples"
    
    teardown
}

# Test: complete landing page workflow
test_complete_landing_workflow() {
    setup
    
    # Create projects JSON file
    cat > projects.json << 'EOF'
[
  {
    "url": "https://tool1.sh",
    "label": "tool1.sh",
    "desc": "First tool in the ecosystem",
    "class": "card-project"
  },
  {
    "url": "https://tool2.sh",
    "label": "tool2.sh",
    "desc": "Second tool in the ecosystem",
    "class": "card-project"
  },
  {
    "url": "https://tool3.sh",
    "label": "tool3.sh",
    "desc": "Third tool in the ecosystem",
    "class": "card-project"
  }
]
EOF
    
    # Create custom logo
    cat > logo.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" fill="green"/>
</svg>
EOF
    
    # Generate landing page
    output=$(bash "$LEAF_SH" --landing \
        --projects-file projects.json \
        --logo logo.svg \
        --github https://github.com/my-org \
        --base-path /landing/ \
        -o website 2>&1)
    
    # Verify output
    assert_file_exists "website/index.html" "Should create landing page"
    
    html=$(cat website/index.html)
    assert_contains "$html" "tool1.sh" "Should include tool1"
    assert_contains "$html" "tool2.sh" "Should include tool2"
    assert_contains "$html" "tool3.sh" "Should include tool3"
    assert_contains "$html" "github.com/my-org" "Should include custom GitHub"
    assert_contains "$html" 'base href="/landing/"' "Should include base path"
    assert_contains "$html" "rect" "Should include custom logo"
    
    assert_contains "$output" "Projects JSON loaded" "Should report JSON loaded"
    assert_contains "$output" "Found 3 project" "Should report project count"
    
    teardown
}

# Test: regenerating docs overwrites existing
test_regenerate_docs() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # Generate first time
    bash "$LEAF_SH" test-project -o output 2>&1
    first_content=$(cat output/index.html)
    
    # Update project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "2.0.0"
description: "Updated description"
EOF
    
    # Regenerate
    bash "$LEAF_SH" test-project -o output 2>&1
    second_content=$(cat output/index.html)
    
    assert_not_equals "$first_content" "$second_content" "Should overwrite with new content"
    assert_contains "$second_content" "2.0.0" "Should have new version"
    assert_contains "$second_content" "Updated description" "Should have new description"
    
    teardown
}

# Test: docs and landing in same directory
test_docs_and_landing_separate() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    # Generate docs
    bash "$LEAF_SH" test-project -o output/docs 2>&1
    
    # Generate landing
    bash "$LEAF_SH" --landing -o output/landing 2>&1
    
    assert_file_exists "output/docs/index.html" "Should create docs"
    assert_file_exists "output/landing/index.html" "Should create landing"
    
    docs_html=$(cat output/docs/index.html)
    landing_html=$(cat output/landing/index.html)
    
    assert_contains "$docs_html" "test-project" "Docs should have project name"
    assert_contains "$landing_html" "butter.sh" "Landing should have butter.sh"
    assert_not_contains "$docs_html" "butter.sh" "Docs should not have butter.sh"
    
    teardown
}

# Test: multiple file types in source
test_multiple_file_types() {
    setup
    
    mkdir -p test-project/src
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    echo "#!/usr/bin/env bash" > test-project/script.sh
    echo "console.log('test');" > test-project/src/app.js
    echo "print('hello')" > test-project/src/util.py
    echo 'puts "ruby"' > test-project/src/helper.rb
    
    bash "$LEAF_SH" test-project -o output 2>&1
    
    html=$(cat output/index.html)
    assert_contains "$html" "script.sh" "Should include shell file"
    assert_contains "$html" "app.js" "Should include JavaScript file"
    assert_contains "$html" "util.py" "Should include Python file"
    assert_contains "$html" "helper.rb" "Should include Ruby file"
    
    teardown
}

# Test: debug mode provides verbose output
test_debug_mode() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    output=$(bash "$LEAF_SH" test-project --debug -o output 2>&1)
    
    assert_contains "$output" "🔍" "Should show debug symbols"
    assert_contains "$output" "Parsing" "Should show parsing info"
    
    teardown
}

# Test: project with special directory names
test_special_directory_names() {
    setup
    
    mkdir -p "test project with spaces"
    cat > "test project with spaces/arty.yml" << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    bash "$LEAF_SH" "test project with spaces" -o output 2>&1
    
    assert_file_exists "output/index.html" "Should handle spaces in directory name"
    
    teardown
}

# Test: large project with many files
test_large_project() {
    setup
    
    mkdir -p test-project/{src,lib,examples}
    cat > test-project/arty.yml << 'EOF'
name: "large-project"
version: "1.0.0"
EOF
    
    # Create 20 source files
    for i in {1..20}; do
        echo "#!/usr/bin/env bash" > "test-project/src/file${i}.sh"
        echo "echo 'file $i'" >> "test-project/src/file${i}.sh"
    done
    
    # Create 10 examples
    for i in {1..10}; do
        echo "#!/usr/bin/env bash" > "test-project/examples/example${i}.sh"
    done
    
    output=$(bash "$LEAF_SH" test-project -o output 2>&1)
    
    assert_file_exists "output/index.html" "Should handle large project"
    assert_contains "$output" "20 source files" "Should report all source files"
    assert_contains "$output" "10 examples" "Should report all examples"
    
    teardown
}

# Test: end-to-end with all options
test_all_options_combined() {
    setup
    
    mkdir -p test-project
    cat > test-project/arty.yml << 'EOF'
name: "test-project"
version: "1.0.0"
EOF
    
    cat > test-project/main.sh << 'EOF'
#!/usr/bin/env bash
echo "main"
EOF
    
    cat > logo.svg << 'EOF'
<svg><circle/></svg>
EOF
    
    output=$(bash "$LEAF_SH" test-project \
        --logo logo.svg \
        --base-path /docs/ \
        --github https://github.com/custom \
        --debug \
        -o final-output 2>&1)
    
    assert_file_exists "final-output/index.html" "Should create output"
    
    html=$(cat final-output/index.html)
    assert_contains "$html" 'base href="/docs/"' "Should have base path"
    assert_contains "$html" "circle" "Should have custom logo"
    assert_contains "$html" "github.com/custom" "Should have custom GitHub"
    
    teardown
}

# Run all tests
run_tests() {
    test_complete_docs_workflow
    test_complete_landing_workflow
    test_regenerate_docs
    test_docs_and_landing_separate
    test_multiple_file_types
    test_debug_mode
    test_special_directory_names
    test_large_project
    test_all_options_combined
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
