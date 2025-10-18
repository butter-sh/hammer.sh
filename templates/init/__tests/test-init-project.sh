#!/usr/bin/env bash
# Test suite for init.sh project initialization functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INIT_SH="${SCRIPT_DIR}/../init.sh"

# Source test helpers
if ! declare -f assert_contains > /dev/null; then
    echo "Error: Test helpers not loaded. This test must be run via judge.sh"
    exit 1
fi

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export ARTY_HOME="$TEST_DIR/.arty"
    export CONFIG_FILE="$TEST_DIR/arty.yml"
    export DEMOS_DIR="$TEST_DIR/demos"
    cd "$TEST_DIR"
    
    # Create mock dependencies
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    cat > "$TEST_DIR/bin/yq" << 'EOF'
#!/bin/bash
echo "mock yq"
EOF
    chmod +x "$TEST_DIR/bin/yq"
    
    cat > "$TEST_DIR/bin/git" << 'EOF'
#!/bin/bash
case "$1" in
    config)
        case "$2" in
            user.name) echo "Test User" ;;
            user.email) echo "test@example.com" ;;
        esac
        ;;
    init) echo "Initialized git repository" ;;
esac
EOF
    chmod +x "$TEST_DIR/bin/git"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: create_structure creates basic directories
test_create_structure_basic() {
    setup
    
    cat > "$TEST_DIR/test_create.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}" "basic"
EOF
    
    bash "$TEST_DIR/test_create.sh" "$INIT_SH" "$TEST_DIR/project"
    
    assert_dir_exists "$TEST_DIR/project" "Project directory should exist"
    assert_dir_exists "$TEST_DIR/project/src" "src directory should exist"
    assert_dir_exists "$TEST_DIR/project/lib" "lib directory should exist"
    assert_dir_exists "$TEST_DIR/project/examples" "examples directory should exist"
    assert_dir_exists "$TEST_DIR/project/tests" "tests directory should exist"
    assert_dir_exists "$TEST_DIR/project/docs" "docs directory should exist"
    assert_dir_exists "$TEST_DIR/project/demos" "demos directory should exist"
    assert_dir_exists "$TEST_DIR/project/.arty" ".arty directory should exist"
    assert_dir_exists "$TEST_DIR/project/.arty/bin" ".arty/bin directory should exist"
    assert_dir_exists "$TEST_DIR/project/.arty/libs" ".arty/libs directory should exist"
    
    teardown
}

# Test: create_structure creates CLI-specific directories
test_create_structure_cli() {
    setup
    
    cat > "$TEST_DIR/test_create.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}" "cli"
EOF
    
    bash "$TEST_DIR/test_create.sh" "$INIT_SH" "$TEST_DIR/project"
    
    assert_dir_exists "$TEST_DIR/project/cmd" "cmd directory should exist for CLI"
    assert_dir_exists "$TEST_DIR/project/internal" "internal directory should exist for CLI"
    
    teardown
}

# Test: create_structure creates web-specific directories
test_create_structure_web() {
    setup
    
    cat > "$TEST_DIR/test_create.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}" "web"
EOF
    
    bash "$TEST_DIR/test_create.sh" "$INIT_SH" "$TEST_DIR/project"
    
    assert_dir_exists "$TEST_DIR/project/public" "public directory should exist for web"
    assert_dir_exists "$TEST_DIR/project/routes" "routes directory should exist for web"
    assert_dir_exists "$TEST_DIR/project/middleware" "middleware directory should exist for web"
    
    teardown
}

# Test: create_structure creates lib-specific directories
test_create_structure_lib() {
    setup
    
    cat > "$TEST_DIR/test_create.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
create_structure "${2}" "lib"
EOF
    
    bash "$TEST_DIR/test_create.sh" "$INIT_SH" "$TEST_DIR/project"
    
    assert_dir_exists "$TEST_DIR/project/modules" "modules directory should exist for lib"
    assert_dir_exists "$TEST_DIR/project/utils" "utils directory should exist for lib"
    
    teardown
}

# Test: generate_arty_yml creates valid YAML
test_generate_arty_yml_basic() {
    setup
    
    cat > "$TEST_DIR/test_arty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_arty.sh" "$INIT_SH" "$TEST_DIR" "test-project" "$TEST_DIR/bin"
    
    assert_file_exists "$TEST_DIR/arty.yml" "arty.yml should be created"
    
    content=$(cat "$TEST_DIR/arty.yml")
    assert_contains "$content" "name: \"test-project\"" "Should have project name"
    assert_contains "$content" "version: \"0.1.0\"" "Should have version"
    assert_contains "$content" "description:" "Should have description"
    assert_contains "$content" "author:" "Should have author"
    assert_contains "$content" "license: \"MIT\"" "Should have MIT license"
    assert_contains "$content" "type: \"basic\"" "Should have project type"
    assert_contains "$content" "main:" "Should have main entry point"
    assert_contains "$content" "scripts:" "Should have scripts section"
    assert_contains "$content" "references:" "Should have references section"
    
    teardown
}

# Test: generate_arty_yml sets correct main script for CLI
test_generate_arty_yml_cli_main() {
    setup
    
    cat > "$TEST_DIR/test_arty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "cli"
EOF
    
    bash "$TEST_DIR/test_arty.sh" "$INIT_SH" "$TEST_DIR" "cli-tool" "$TEST_DIR/bin"
    
    content=$(cat "$TEST_DIR/arty.yml")
    assert_contains "$content" "main: \"cmd/main.sh\"" "CLI should have cmd/main.sh as main"
    assert_contains "$content" "type: \"cli\"" "Should be CLI type"
    
    teardown
}

# Test: generate_arty_yml sets correct main script for lib
test_generate_arty_yml_lib_main() {
    setup
    
    cat > "$TEST_DIR/test_arty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "lib"
EOF
    
    bash "$TEST_DIR/test_arty.sh" "$INIT_SH" "$TEST_DIR" "my-library" "$TEST_DIR/bin"
    
    content=$(cat "$TEST_DIR/arty.yml")
    assert_contains "$content" "main: \"lib/index.sh\"" "Library should have lib/index.sh as main"
    assert_contains "$content" "type: \"lib\"" "Should be lib type"
    
    teardown
}

# Test: generate_arty_yml sets correct main script for web
test_generate_arty_yml_web_main() {
    setup
    
    cat > "$TEST_DIR/test_arty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "web"
EOF
    
    bash "$TEST_DIR/test_arty.sh" "$INIT_SH" "$TEST_DIR" "web-service" "$TEST_DIR/bin"
    
    content=$(cat "$TEST_DIR/arty.yml")
    assert_contains "$content" "main: \"server.sh\"" "Web should have server.sh as main"
    assert_contains "$content" "type: \"web\"" "Should be web type"
    
    teardown
}

# Test: generate_arty_yml includes asciinema scripts
test_generate_arty_yml_asciinema_scripts() {
    setup
    
    cat > "$TEST_DIR/test_arty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_arty.sh" "$INIT_SH" "$TEST_DIR" "test-project" "$TEST_DIR/bin"
    
    content=$(cat "$TEST_DIR/arty.yml")
    assert_contains "$content" "demo-rec:" "Should have demo-rec script"
    assert_contains "$content" "demo-play:" "Should have demo-play script"
    assert_contains "$content" "demo-upload:" "Should have demo-upload script"
    assert_contains "$content" "demo-list:" "Should have demo-list script"
    
    teardown
}

# Test: generate_arty_yml includes standard scripts
test_generate_arty_yml_standard_scripts() {
    setup
    
    cat > "$TEST_DIR/test_arty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_arty.sh" "$INIT_SH" "$TEST_DIR" "test-project" "$TEST_DIR/bin"
    
    content=$(cat "$TEST_DIR/arty.yml")
    assert_contains "$content" "start:" "Should have start script"
    assert_contains "$content" "test:" "Should have test script"
    assert_contains "$content" "build:" "Should have build script"
    assert_contains "$content" "lint:" "Should have lint script"
    assert_contains "$content" "docs:" "Should have docs script"
    assert_contains "$content" "clean:" "Should have clean script"
    
    teardown
}

# Test: generate_arty_yml includes environment variables
test_generate_arty_yml_environment() {
    setup
    
    cat > "$TEST_DIR/test_arty.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${4}:${PATH}"
source "${1}"
generate_arty_yml "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_arty.sh" "$INIT_SH" "$TEST_DIR" "test-project" "$TEST_DIR/bin"
    
    content=$(cat "$TEST_DIR/arty.yml")
    assert_contains "$content" "env:" "Should have env section"
    assert_contains "$content" "DEBUG:" "Should have DEBUG var"
    assert_contains "$content" "LOG_LEVEL:" "Should have LOG_LEVEL var"
    
    teardown
}

# Test: generate_readme creates README
test_generate_readme_basic() {
    setup
    
    cat > "$TEST_DIR/test_readme.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
generate_readme "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_readme.sh" "$INIT_SH" "$TEST_DIR" "test-project"
    
    assert_file_exists "$TEST_DIR/README.md" "README.md should be created"
    
    content=$(cat "$TEST_DIR/README.md")
    assert_contains "$content" "# test-project" "Should have project name as title"
    assert_contains "$content" "arty.sh" "Should mention arty.sh"
    assert_contains "$content" "Quick Start" "Should have quick start section"
    assert_contains "$content" "Demo" "Should have demo section"
    assert_contains "$content" "Installation" "Should have installation section"
    assert_contains "$content" "Development" "Should have development section"
    assert_contains "$content" "Documentation" "Should have documentation section"
    assert_contains "$content" "Project Structure" "Should have structure section"
    
    teardown
}

# Test: generate_readme includes asciinema section
test_generate_readme_asciinema() {
    setup
    
    cat > "$TEST_DIR/test_readme.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
generate_readme "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_readme.sh" "$INIT_SH" "$TEST_DIR" "test-project"
    
    content=$(cat "$TEST_DIR/README.md")
    assert_contains "$content" "🎬 Demo" "Should have demo section with emoji"
    assert_contains "$content" "asciinema" "Should mention asciinema"
    assert_contains "$content" "init.sh rec" "Should show recording command"
    assert_contains "$content" "init.sh play" "Should show play command"
    assert_contains "$content" "init.sh upload" "Should show upload command"
    assert_contains "$content" "init.sh list" "Should show list command"
    assert_contains "$content" "Recording Demos" "Should have recording demos subsection"
    
    teardown
}

# Test: generate_readme shows project structure
test_generate_readme_structure() {
    setup
    
    cat > "$TEST_DIR/test_readme.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
generate_readme "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_readme.sh" "$INIT_SH" "$TEST_DIR" "test-project"
    
    content=$(cat "$TEST_DIR/README.md")
    assert_contains "$content" "arty.yml" "Should show arty.yml in structure"
    assert_contains "$content" "src/" "Should show src directory"
    assert_contains "$content" "lib/" "Should show lib directory"
    assert_contains "$content" "tests/" "Should show tests directory"
    assert_contains "$content" "demos/" "Should show demos directory"
    assert_contains "$content" ".arty/" "Should show .arty directory"
    
    teardown
}

# Test: generate_readme includes ecosystem links
test_generate_readme_ecosystem_links() {
    setup
    
    cat > "$TEST_DIR/test_readme.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
generate_readme "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_readme.sh" "$INIT_SH" "$TEST_DIR" "test-project"
    
    content=$(cat "$TEST_DIR/README.md")
    assert_contains "$content" "butter.sh" "Should mention butter.sh ecosystem"
    assert_contains "$content" "arty.sh" "Should link to arty.sh"
    assert_contains "$content" "leaf.sh" "Should link to leaf.sh"
    assert_contains "$content" "hammer.sh" "Should link to hammer.sh"
    assert_contains "$content" "asciinema.org" "Should link to asciinema"
    
    teardown
}

# Test: generate_readme includes features list
test_generate_readme_features() {
    setup
    
    cat > "$TEST_DIR/test_readme.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
generate_readme "${2}" "${3}" "basic"
EOF
    
    bash "$TEST_DIR/test_readme.sh" "$INIT_SH" "$TEST_DIR" "test-project"
    
    content=$(cat "$TEST_DIR/README.md")
    assert_contains "$content" "Features" "Should have features section"
    assert_contains "$content" "Modern bash development" "Should list modern bash"
    assert_contains "$content" "Dependency management" "Should list dependency management"
    assert_contains "$content" "testing framework" "Should list testing"
    assert_contains "$content" "Auto-generated documentation" "Should list docs"
    assert_contains "$content" "Demo recording" "Should list demo recording"
    
    teardown
}

# Run all tests
run_tests() {
    log_section "Init Project Generation Tests"
    
    test_create_structure_basic
    test_create_structure_cli
    test_create_structure_web
    test_create_structure_lib
    test_generate_arty_yml_basic
    test_generate_arty_yml_cli_main
    test_generate_arty_yml_lib_main
    test_generate_arty_yml_web_main
    test_generate_arty_yml_asciinema_scripts
    test_generate_arty_yml_standard_scripts
    test_generate_arty_yml_environment
    test_generate_readme_basic
    test_generate_readme_asciinema
    test_generate_readme_structure
    test_generate_readme_ecosystem_links
    test_generate_readme_features
    
    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
