#!/usr/bin/env bash

# {{project_name}} - Main entry point
# Version: 0.1.0

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output - only use colors if output is to a terminal or if FORCE_COLOR is set
export FORCE_COLOR=${FORCE_COLOR:-}
if [[ -z "$FORCE_COLOR" ]]; then
		if [[ "$FORCE_COLOR" = "1" ]]; then
			export RED='\033[0;31m'
			export GREEN='\033[0;32m'
			export YELLOW='\033[1;33m'
			export BLUE='\033[0;34m'
			export CYAN='\033[0;36m'
			export MAGENTA='\033[0;35m'
			export BOLD='\033[1m'
			export NC='\033[0m'

		else
			export RED=''
			export GREEN=''
			export YELLOW=''
			export BLUE=''
			export CYAN=''
			export MAGENTA=''
			export BOLD=''
			export NC=''
		fi
elif [[ -t 1 ]] && [[ -t 2 ]]; then
		export RED='\033[0;31m'
		export GREEN='\033[0;32m'
		export YELLOW='\033[1;33m'
		export BLUE='\033[0;34m'
		export CYAN='\033[0;36m'
		export MAGENTA='\033[0;35m'
		export BOLD='\033[1m'
		export NC='\033[0m'
else
    export RED=''
    export GREEN=''
    export YELLOW=''
    export BLUE=''
    export CYAN=''
		export MAGENTA=''
		export BOLD=''
		export NC=''
fi

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Main function
main() {
    log_info "Welcome to {{project_name}}!"
    
    # Your code here
    echo "Hello from {{project_name}}!"
    
    log_success "Execution completed"
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
