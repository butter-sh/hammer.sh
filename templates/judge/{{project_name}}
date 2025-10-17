#!/usr/bin/env bash

# {{project_name}} - Main entry point for test framework
# Delegates commands to specialized scripts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    cat << EOF
{{project_name}} - A bash testing framework with snapshot support

USAGE:
    {{project_name}} <command> [options]

COMMANDS:
    run      Run all tests (delegates to run-all-tests.sh)
    setup    Initialize snapshot baselines (delegates to setup-snapshots.sh)
    snap     Manage snapshots (delegates to snapshot-tool.sh)
    help     Show this help message

EXAMPLES:
    # Run all tests
    {{project_name}} run

    # Run tests with verbose output
    {{project_name}} run -v

    # Run specific test suite
    {{project_name}} run -t my-test

    # Update snapshots
    {{project_name}} run -u

    # Initialize snapshots (first time setup)
    {{project_name}} setup

    # List all snapshots
    {{project_name}} snap list

    # Compare snapshot with master
    {{project_name}} snap diff test-name

    # Show snapshot statistics
    {{project_name}} snap stats

For detailed command help:
    {{project_name}} run --help
    {{project_name}} snap --help

EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi

    local command="$1"
    shift

    case "$command" in
        run)
            # Delegate to run-all-tests.sh
            exec bash "${SCRIPT_DIR}/run-all-tests.sh" "$@"
            ;;
        setup)
            # Delegate to setup-snapshots.sh
            exec bash "${SCRIPT_DIR}/setup-snapshots.sh" "$@"
            ;;
        snap)
            # Delegate to snapshot-tool.sh
            exec bash "${SCRIPT_DIR}/snapshot-tool.sh" "$@"
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$command'${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
