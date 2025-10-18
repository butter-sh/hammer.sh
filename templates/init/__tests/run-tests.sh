#!/usr/bin/env bash
# Run all tests for init.sh
# This is a convenience wrapper around judge.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  Init.sh Test Suite${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════${NC}\n"

# Check if judge.sh is available
if ! command -v judge.sh &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: judge.sh not found in PATH${NC}"
    echo -e "${YELLOW}   Looking for judge.sh in common locations...${NC}\n"
    
    # Try to find judge.sh
    JUDGE_CANDIDATES=(
        "../../../judge.sh"
        "../../judge/judge.sh"
        "../../../templates/judge/judge.sh"
    )
    
    JUDGE_SH=""
    for candidate in "${JUDGE_CANDIDATES[@]}"; do
        if [[ -f "$SCRIPT_DIR/$candidate" ]]; then
            JUDGE_SH="$SCRIPT_DIR/$candidate"
            echo -e "${GREEN}✓ Found judge.sh at: $candidate${NC}\n"
            break
        fi
    done
    
    if [[ -z "$JUDGE_SH" ]]; then
        echo -e "${RED}✗ Could not find judge.sh${NC}"
        echo -e "${YELLOW}  Please ensure judge.sh is installed or in your PATH${NC}"
        echo -e "${YELLOW}  Or specify the path: JUDGE_SH=/path/to/judge.sh $0${NC}\n"
        exit 1
    fi
else
    JUDGE_SH="judge.sh"
fi

# Parse arguments
RUN_FILE=""
VERBOSE=""
UPDATE_SNAPSHOTS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE="1"
            shift
            ;;
        -u|--update-snapshots)
            UPDATE_SNAPSHOTS="1"
            shift
            ;;
        -h|--help)
            cat << EOF
${BOLD}Usage:${NC} $0 [options] [test-file]

${BOLD}Options:${NC}
  -v, --verbose           Verbose output
  -u, --update-snapshots  Update test snapshots
  -h, --help             Show this help

${BOLD}Examples:${NC}
  $0                           # Run all tests
  $0 test-init-core.sh        # Run specific test file
  $0 -v                       # Run with verbose output
  $0 -u test-init-core.sh     # Update snapshots for specific test

${BOLD}Available Test Files:${NC}
EOF
            for test_file in "$SCRIPT_DIR"/test-init-*.sh; do
                if [[ -f "$test_file" ]]; then
                    basename "$test_file"
                fi
            done
            echo ""
            exit 0
            ;;
        *)
            RUN_FILE="$1"
            shift
            ;;
    esac
done

# Set environment variables
export VERBOSE="${VERBOSE}"
export UPDATE_SNAPSHOTS="${UPDATE_SNAPSHOTS}"

# Run tests
if [[ -n "$RUN_FILE" ]]; then
    echo -e "${BLUE}Running specific test: ${BOLD}$RUN_FILE${NC}\n"
    
    if [[ -f "$SCRIPT_DIR/$RUN_FILE" ]]; then
        bash "$JUDGE_SH" "$SCRIPT_DIR/$RUN_FILE"
    elif [[ -f "$RUN_FILE" ]]; then
        bash "$JUDGE_SH" "$RUN_FILE"
    else
        echo -e "${RED}✗ Test file not found: $RUN_FILE${NC}\n"
        exit 1
    fi
else
    echo -e "${BLUE}Running all tests...${NC}\n"
    bash "$JUDGE_SH" "$SCRIPT_DIR"
fi

# Show summary
echo ""
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BOLD}${BLUE}  Test Run Complete${NC}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════${NC}"
