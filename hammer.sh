#!/usr/bin/env bash

# hammer.sh - A configurable bash project generator
# Version: 1.0.0

set -euo pipefail

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
    -f, --force             Force overwrite existing files without prompting
    -l, --list              List available templates
    -h, --help              Show this help message

EXAMPLES:
    hammer.sh arty my-lib-manager
    hammer.sh starter my-project --dir ./projects
    hammer.sh starter my-app -v author="John Doe" -v license=MIT
    hammer.sh arty my-lib --force

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

# Prompt for overwrite decision
# Returns: 0 for yes, 1 for no, 2 for all, 3 for none
prompt_overwrite() {
    local file="$1"
    local response
    
    while true; do
        printf "${YELLOW}?${NC} File exists: %s\n" "$file"
        printf "  Overwrite? [y]es/[n]o/[a]ll/[N]one: "
        read -r response
        
        case "$response" in
            y|Y|yes|Yes|YES)
                return 0
                ;;
            n|N|no|No|NO)
                return 1
                ;;
            a|A|all|All|ALL)
                return 2
                ;;
            N|none|None|NONE)
                return 3
                ;;
            "")
                # Empty response - treat as no
                return 1
                ;;
            *)
                log_warn "Invalid response. Please enter y, n, a, or N."
                ;;
        esac
    done
}

# Generate project from template
generate_project() {
    local template="$1"
    local project_name="$2"
    local target_dir="$3"
    local force="$4"
    shift 4
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
    
    # Check if directory exists but don't fail immediately
    local dir_existed=false
    if [[ -d "$project_path" ]]; then
        dir_existed=true
        if [[ "$force" != "true" ]]; then
            log_warn "Directory '$project_path' already exists"
            log_info "Files will be created/overwritten as needed"
        fi
    else
        mkdir -p "$project_path"
    fi
    
    log_info "Creating project: $project_name"
    
    # Add default variables
    vars+=("project_name=$project_name")
    vars+=("year=$(date +%Y)")
    vars+=("date=$(date +%Y-%m-%d)")
    
    # Copy and process template files
    local overwrite_mode="ask"  # ask, all, none
    local files_created=0
    local files_skipped=0
    local files_overwritten=0
    
    if [[ "$force" == "true" ]]; then
        overwrite_mode="all"
    fi
    
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
            local should_write=true
            local file_existed=false
            
            # Check if file exists and handle accordingly
            if [[ -f "$target_file" ]]; then
                file_existed=true
                
                case "$overwrite_mode" in
                    all)
                        should_write=true
                        ;;
                    none)
                        should_write=false
                        ;;
                    ask)
                        local last_result=$(prompt_overwrite "$rel_path")
                        case $last_result in
                            0) # yes
                                should_write=true
                                ;;
                            1) # no
                                should_write=false
																;;
                            2) # all
                                should_write=true
                                overwrite_mode="all"
                                log_info "Overwriting all remaining files"
                                ;;
                            3) # none
                                should_write=false
                                overwrite_mode="none"
                                log_info "Skipping all remaining files"
                                ;;
                        esac
                        ;;
                esac
            fi
            
            if [[ "$should_write" == true ]]; then
                local content
                content=$(cat "$file")
                content=$(replace_vars "$content" "${vars[@]}")
                echo "$content" > "$target_file"
                
                # Preserve execute permissions
                if [[ -x "$file" ]]; then
                    chmod +x "$target_file"
                fi
                
                if [[ "$file_existed" == true ]]; then
                    log_success "Overwritten: $rel_path"
                    files_overwritten=$((files_overwritten+1))
                else
                    log_success "Created: $rel_path"
                    files_created=$((files_created+1))
                fi
            else
                log_warn "Skipped: $rel_path"
                files_skipped=$((files_skipped+1))
            fi
        fi
    done < <(find "$template_path" -type f -print0)
    
    echo
    log_success "Project '$project_name' generated successfully!"
    log_info "Location: $project_path"
    
    # Show summary
    if [[ $files_created -gt 0 || $files_overwritten -gt 0 || $files_skipped -gt 0 ]]; then
        echo
        log_info "Summary:"
        [[ $files_created -gt 0 ]] && echo "  Created: $files_created file(s)"
        [[ $files_overwritten -gt 0 ]] && echo "  Overwritten: $files_overwritten file(s)"
        [[ $files_skipped -gt 0 ]] && echo "  Skipped: $files_skipped file(s)"
    fi
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
    local force=false
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
            -f|--force)
                force=true
                shift
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
    generate_project "$template" "$project_name" "$target_dir" "$force" "${vars[@]}"
}

# Run main function
main "$@"
