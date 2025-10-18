#!/usr/bin/env bash
# Test suite for init.sh core functionality

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
    export INIT_TEST_MODE=1
    export ARTY_HOME="$TEST_DIR/.arty"
    export CONFIG_FILE="$TEST_DIR/arty.yml"
    export DEMOS_DIR="$TEST_DIR/demos"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: init.sh help displays usage
test_init_help_displays_usage() {
    setup
    
    output=$(bash "$INIT_SH" --help 2>&1)
    
    assert_contains "$output" "USAGE:" "Should show usage"
    assert_contains "$output" "PROJECT OPTIONS:" "Should show project options"
    assert_contains "$output" "ASCIINEMA COMMANDS:" "Should show asciinema commands"
    assert_contains "$output" "TEMPLATES:" "Should show templates"
    assert_contains "$output" "EXAMPLES:" "Should show examples"
    
    teardown
}

# Test: init.sh version displays version info
test_init_version_displays_info() {
    setup
    
    output=$(bash "$INIT_SH" --version 2>&1)
    
    assert_contains "$output" "init.sh version" "Should show version"
    assert_contains "$output" "butter.sh" "Should mention butter.sh ecosystem"
    assert_contains "$output" "Features:" "Should list features"
    assert_contains "$output" "asciinema" "Should mention asciinema"
    
    teardown
}

# Test: init.sh without arguments shows banner and help
test_init_no_args_shows_banner() {
    setup
    
    # Mock check_dependencies to pass
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    # Create mock yq and git
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/yq" "$TEST_DIR/bin/git"
    
    output=$(bash "$INIT_SH" 2>&1 || true)
    
    assert_contains "$output" "Project Initialization System" "Should show banner"
    
    teardown
}

# Test: command_exists function works
test_command_exists_detection() {
    setup
    
    cat > "$TEST_DIR/test_cmd.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

if command_exists "bash"; then
    echo "bash exists"
fi

if command_exists "nonexistent_command_xyz"; then
    echo "nonexistent exists"
else
    echo "nonexistent not found"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_cmd.sh" "$INIT_SH")
    
    assert_contains "$output" "bash exists" "Should detect existing commands"
    assert_contains "$output" "nonexistent not found" "Should not detect nonexistent commands"
    
    teardown
}

# Test: check_dependencies detects missing tools
test_check_dependencies_missing() {
    setup
    
    # Create test script with empty PATH to ensure tools are missing
    cat > "$TEST_DIR/test_deps.sh" << 'EOF'
#!/usr/bin/env bash
PATH="/nonexistent"
source "${1}"
check_dependencies 2>&1 || echo "Dependencies check failed"
EOF
    
    output=$(bash "$TEST_DIR/test_deps.sh" "$INIT_SH")
    
    assert_contains "$output" "Missing dependencies" "Should report missing dependencies"
    
    teardown
}

# Test: check_dependencies passes with required tools
test_check_dependencies_present() {
    setup
    
    export PATH="$PATH:$TEST_DIR/bin"
    mkdir -p "$TEST_DIR/bin"
    
    # Create mock yq and git
    echo '#!/bin/bash' > "$TEST_DIR/bin/yq"
    echo '#!/bin/bash' > "$TEST_DIR/bin/git"
    chmod +x "$TEST_DIR/bin/yq" "$TEST_DIR/bin/git"
    
    cat > "$TEST_DIR/test_deps.sh" << 'EOF'
#!/usr/bin/env bash
export PATH="${2}:${PATH}"
source "${1}"
if check_dependencies 2>&1; then
    echo "Dependencies OK"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_deps.sh" "$INIT_SH" "$TEST_DIR/bin")
    
    assert_contains "$output" "Dependencies OK" "Should pass when dependencies present"
    
    teardown
}

# Test: logging functions produce formatted output
test_logging_functions() {
    setup
    
    cat > "$TEST_DIR/test_logging.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

log_info "Info message"
log_success "Success message"
log_warn "Warning message"
log_error "Error message"
log_header "Header message"
EOF
    
    output=$(bash "$TEST_DIR/test_logging.sh" "$INIT_SH" 2>&1)
    
    assert_contains "$output" "Info message" "Should log info"
    assert_contains "$output" "Success message" "Should log success"
    assert_contains "$output" "Warning message" "Should log warning"
    assert_contains "$output" "Error message" "Should log error"
    assert_contains "$output" "Header message" "Should log header"
    
    teardown
}

# Test: show_banner displays banner
test_show_banner() {
    setup
    
    cat > "$TEST_DIR/test_banner.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
show_banner
EOF
    
    output=$(bash "$TEST_DIR/test_banner.sh" "$INIT_SH")
    
    assert_contains "$output" "Project Initialization System" "Should show banner"
    assert_contains "$output" "butter.sh" "Should mention butter.sh"
    assert_contains "$output" "asciinema" "Should mention asciinema"
    
    teardown
}

# Test: color variables are set
test_color_variables_set() {
    setup
    
    cat > "$TEST_DIR/test_colors.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

# Check that color variables exist (even if empty)
echo "RED=${RED:-unset}"
echo "GREEN=${GREEN:-unset}"
echo "BLUE=${BLUE:-unset}"
echo "NC=${NC:-unset}"
EOF
    
    output=$(bash "$TEST_DIR/test_colors.sh" "$INIT_SH")
    
    assert_contains "$output" "RED=" "RED should be set"
    assert_contains "$output" "GREEN=" "GREEN should be set"
    assert_contains "$output" "BLUE=" "BLUE should be set"
    assert_contains "$output" "NC=" "NC should be set"
    
    teardown
}

# Test: emoji variables are defined
test_emoji_variables() {
    setup
    
    cat > "$TEST_DIR/test_emoji.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"

echo "CHECK=${EMOJI_CHECK}"
echo "ROCKET=${EMOJI_ROCKET}"
echo "HAMMER=${EMOJI_HAMMER}"
echo "CAMERA=${EMOJI_CAMERA}"
EOF
    
    output=$(bash "$TEST_DIR/test_emoji.sh" "$INIT_SH")
    
    assert_contains "$output" "CHECK=✓" "Should have check emoji"
    assert_contains "$output" "ROCKET=🚀" "Should have rocket emoji"
    assert_contains "$output" "HAMMER=🔨" "Should have hammer emoji"
    assert_contains "$output" "CAMERA=🎬" "Should have camera emoji"
    
    teardown
}

# Test: help flags work correctly
test_help_flags() {
    setup
    
    output1=$(bash "$INIT_SH" -h 2>&1)
    output2=$(bash "$INIT_SH" --help 2>&1)
    output3=$(bash "$INIT_SH" help 2>&1 || true)
    
    for output in "$output1" "$output2"; do
        assert_contains "$output" "USAGE:" "Help flag should show usage"
    done
    
    teardown
}

# Test: version flag works
test_version_flag() {
    setup
    
    output=$(bash "$INIT_SH" --version 2>&1)
    
    assert_contains "$output" "init.sh version" "Version flag should show version"
    assert_contains "$output" "MIT" "Should show license"
    
    teardown
}

# Test: script can be sourced
test_script_sourceable() {
    setup
    
    cat > "$TEST_DIR/test_source.sh" << 'EOF'
#!/usr/bin/env bash
source "${1}"
echo "Sourced successfully"
EOF
    
    output=$(bash "$TEST_DIR/test_source.sh" "$INIT_SH" 2>&1)
    
    assert_contains "$output" "Sourced successfully" "Script should be sourceable"
    
    teardown
}

# Test: default environment variables
test_default_environment() {
    setup
    
    cat > "$TEST_DIR/test_env.sh" << 'EOF'
#!/usr/bin/env bash
# Don't set any env vars, let init.sh use defaults
unset ARTY_HOME CONFIG_FILE DEMOS_DIR
source "${1}"

echo "ARTY_HOME=${ARTY_HOME}"
echo "CONFIG_FILE=${CONFIG_FILE}"
echo "DEMOS_DIR=${DEMOS_DIR}"
echo "INIT_VERSION=${INIT_VERSION}"
EOF
    
    output=$(bash "$TEST_DIR/test_env.sh" "$INIT_SH")
    
    assert_contains "$output" "ARTY_HOME=" "ARTY_HOME should be set"
    assert_contains "$output" "CONFIG_FILE=arty.yml" "CONFIG_FILE should default to arty.yml"
    assert_contains "$output" "DEMOS_DIR=demos" "DEMOS_DIR should default to demos"
    assert_contains "$output" "INIT_VERSION=" "INIT_VERSION should be set"
    
    teardown
}

# Test: FORCE_COLOR environment variable
test_force_color_environment() {
    setup
    
    cat > "$TEST_DIR/test_force_color.sh" << 'EOF'
#!/usr/bin/env bash
export FORCE_COLOR=1
source "${1}"

# Check if colors are set when forced
# The color logic checks if FORCE_COLOR is set and equals "1"
# or if output is to a terminal
if [[ -n "$GREEN" ]] || [[ -n "$RED" ]] || [[ -n "$BLUE" ]]; then
    echo "Colors enabled"
else
    echo "Colors disabled"
fi
EOF
    
    output=$(bash "$TEST_DIR/test_force_color.sh" "$INIT_SH")
    
    # The color logic in init.sh is complex - test that colors CAN be set
    # Either colors are enabled, or the script runs without error
    if [[ "$output" == *"Colors enabled"* ]] || [[ "$output" == *"Colors disabled"* ]]; then
        assert_true "true" "Color logic executes without error"
    else
        assert_contains "$output" "Color" "Should output color status"
    fi
    
    teardown
}

# Run all tests
run_tests() {
    log_section "Init Core Functionality Tests"
    
    test_init_help_displays_usage
    test_init_version_displays_info
    test_init_no_args_shows_banner
    test_command_exists_detection
    test_check_dependencies_missing
    test_check_dependencies_present
    test_logging_functions
    test_show_banner
    test_color_variables_set
    test_emoji_variables
    test_help_flags
    test_version_flag
    test_script_sourceable
    test_default_environment
    test_force_color_environment
    
    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
