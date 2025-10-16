#!/usr/bin/env bash

# hammer.sh - A configurable bash project generator
# Version: 1.0.0

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Show usage
show_usage() {
    cat << EOF
hammer.sh - A configurable bash project generator

USAGE:
    hammer.sh <template> <project-name> [options]

TEMPLATES:
    arty        Generate an arty.sh library manager project
    starter     Generate a starter bash project skeleton

OPTIONS:
    -d, --dir <path>        Target directory (default: current directory)
    -v, --vars <key=value>  Set template variables (can be repeated)
    -l, --list              List available templates
    -h, --help              Show this help message

EXAMPLES:
    hammer.sh arty my-lib-manager
    hammer.sh starter my-project --dir ./projects
    hammer.sh starter my-app -v author="John Doe" -v license=MIT

EOF
}

# List available templates
list_templates() {
    log_info "Available templates:"
    echo
    
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        log_error "Templates directory not found: $TEMPLATES_DIR"
        return 1
    fi
    
    for template_dir in "$TEMPLATES_DIR"/*; do
        if [[ -d "$template_dir" ]]; then
            template_name=$(basename "$template_dir")
            description=""
            
            # Try to read description from .template file
            if [[ -f "$template_dir/.template" ]]; then
                description=$(grep "^description=" "$template_dir/.template" | cut -d'=' -f2- | tr -d '"')
            fi
            
            printf "  ${GREEN}%-15s${NC} %s\n" "$template_name" "$description"
        fi
    done
    echo
}

# Replace variables in content
replace_vars() {
    local content="$1"
    shift
    
    # Replace all variable placeholders
    while [[ $# -gt 0 ]]; do
        local key="${1%%=*}"
        local value="${1#*=}"
        content="${content//\{\{$key\}\}/$value}"
        shift
    done
    
    echo "$content"
}

# Generate project from template
generate_project() {
    local template="$1"
    local project_name="$2"
    local target_dir="$3"
    shift 3
    local vars=("$@")
    
    local template_path="$TEMPLATES_DIR/$template"
    
    # Validate template exists
    if [[ ! -d "$template_path" ]]; then
        log_error "Template '$template' not found"
        log_info "Run 'hammer.sh --list' to see available templates"
        return 1
    fi
    
    # Create target directory
    local project_path="$target_dir/$project_name"
    
    if [[ -d "$project_path" ]]; then
        log_error "Directory '$project_path' already exists"
        return 1
    fi
    
    mkdir -p "$project_path"
    log_info "Creating project: $project_name"
    
    # Add default variables
    vars+=("project_name=$project_name")
    vars+=("year=$(date +%Y)")
    vars+=("date=$(date +%Y-%m-%d)")
    
    # Copy and process template files
    while IFS= read -r -d '' file; do
        local rel_path="${file#$template_path/}"
        
        # Skip hidden template files
        if [[ "$rel_path" == .template ]]; then
            continue
        fi
        
        local target_file="$project_path/$rel_path"
        local target_file_dir=$(dirname "$target_file")
        
        # Create directory structure
        mkdir -p "$target_file_dir"
        
        # Process file content
        if [[ -f "$file" ]]; then
            local content
            content=$(cat "$file")
            content=$(replace_vars "$content" "${vars[@]}")
            echo "$content" > "$target_file"
            
            # Preserve execute permissions
            if [[ -x "$file" ]]; then
                chmod +x "$target_file"
            fi
            
            log_success "Created: $rel_path"
        fi
    done < <(find "$template_path" -type f -print0)
    
    echo
    log_success "Project '$project_name' generated successfully!"
    log_info "Location: $project_path"
}

# Main function
main() {
    # Check for no arguments
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    # Parse options
    local template=""
    local project_name=""
    local target_dir="."
    local vars=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--list)
                list_templates
                exit 0
                ;;
            -d|--dir)
                target_dir="$2"
                shift 2
                ;;
            -v|--vars)
                vars+=("$2")
                shift 2
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$template" ]]; then
                    template="$1"
                elif [[ -z "$project_name" ]]; then
                    project_name="$1"
                else
                    log_error "Too many arguments"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$template" ]]; then
        log_error "Template name is required"
        show_usage
        exit 1
    fi
    
    if [[ -z "$project_name" ]]; then
        log_error "Project name is required"
        show_usage
        exit 1
    fi
    
    # Generate project
    generate_project "$template" "$project_name" "$target_dir" "${vars[@]}"
}

# Run main function
main "$@"
