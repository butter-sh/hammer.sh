#!/usr/bin/env bash

# hammer.sh - CLI facade and generalization of the myst.sh templating library
# Part of the butter.sh ecosystem
# License: MIT

set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTY_CONFIG="${ARTY_CONFIG:-arty.yml}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
DEFAULT_TEMPLATE_DIR="${SCRIPT_DIR}/templates"
DEFAULT_OUTPUT_DIR="."
FORCE_OVERWRITE=false
YES_TO_ALL=false
INTERACTIVE=true

# Function to print colored output
log_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

# Function to show usage
show_usage() {
    cat << EOF
hammer.sh v${VERSION} - CLI facade for myst.sh templating

USAGE:
    hammer [OPTIONS] <template> [output-dir]

ARGUMENTS:
    <template>      Name of the template to use
    [output-dir]    Output directory (default: current directory)

OPTIONS:
    -t, --template-dir DIR    Directory containing templates (default: ./templates or script dir/templates)
    -v, --var KEY=VALUE       Set a template variable (can be used multiple times)
    -j, --json FILE           Load variables from JSON file
    -y, --yaml FILE           Load variables from YAML file
    -o, --output DIR          Output directory (alternative to positional argument)
    -f, --force               Force overwrite existing files without asking
    -y, --yes                 Use default values without prompting for input
    -l, --list                List available templates
    -h, --help                Show this help message
    --version                 Show version information

EXAMPLES:
    # List available templates
    hammer --list

    # Generate from template with interactive prompts
    hammer example-template ./my-project

    # Generate with CLI variables
    hammer example-template -v project_name="MyApp" -v author="John Doe"

    # Generate with JSON data file
    hammer example-template -j data.json

    # Generate with YAML data file
    hammer example-template -y config.yaml

    # Force overwrite without prompts
    hammer example-template ./my-project --force

    # Use defaults without prompts
    hammer example-template ./my-project --yes

    # Combine options
    hammer example-template -v author="Jane" -j data.json -o ./output --force

EOF
}

# Function to check if myst.sh is available
check_myst() {
    if ! command -v myst &> /dev/null; then
        if [ -x ".arty/bin/myst" ]; then
            MYST_CMD=".arty/bin/myst"
        elif [ -x "${SCRIPT_DIR}/.arty/bin/myst" ]; then
            MYST_CMD="${SCRIPT_DIR}/.arty/bin/myst"
        else
            log_error "myst.sh not found. Please install it via: arty install https://github.com/butter-sh/myst.sh.git"
            exit 1
        fi
    else
        MYST_CMD="myst"
    fi
}

# Function to check if yq is available (for YAML support)
check_yq() {
    if ! command -v yq &> /dev/null; then
        log_warning "yq not found. YAML file support will be limited."
        log_info "Install yq from: https://github.com/mikefarah/yq"
        return 1
    fi
    return 0
}

# Function to find template directory
find_template_dir() {
    local custom_dir="$1"
    
    if [ -n "$custom_dir" ] && [ -d "$custom_dir" ]; then
        echo "$custom_dir"
        return 0
    fi
    
    # Check current directory
    if [ -d "./templates" ]; then
        echo "./templates"
        return 0
    fi
    
    # Check script directory
    if [ -d "${SCRIPT_DIR}/templates" ]; then
        echo "${SCRIPT_DIR}/templates"
        return 0
    fi
    
    # Check if we're in an arty.sh project with hammer templates
    if [ -f "$ARTY_CONFIG" ] && command -v yq &> /dev/null; then
        local hammer_templates=$(yq eval '.hammer.templates | keys | .[]' "$ARTY_CONFIG" 2>/dev/null | head -1)
        if [ -n "$hammer_templates" ]; then
            echo "./templates"
            return 0
        fi
    fi
    
    log_error "Template directory not found"
    return 1
}

# Function to list available templates
list_templates() {
    local template_dir="$1"
    
    log_info "Available templates in: $template_dir"
    echo ""
    
    if [ -f "$ARTY_CONFIG" ] && command -v yq &> /dev/null; then
        # List from arty.yml if available
        local templates=$(yq eval '.hammer.templates | keys | .[]' "$ARTY_CONFIG" 2>/dev/null)
        if [ -n "$templates" ]; then
            while IFS= read -r template; do
                local desc=$(yq eval ".hammer.templates.${template}.description" "$ARTY_CONFIG" 2>/dev/null)
                printf "  ${GREEN}%-20s${NC} %s\n" "$template" "$desc"
            done <<< "$templates"
            return 0
        fi
    fi
    
    # Fallback to directory listing
    for dir in "$template_dir"/*; do
        if [ -d "$dir" ]; then
            local template_name=$(basename "$dir")
            printf "  ${GREEN}%-20s${NC}\n" "$template_name"
        fi
    done
}

# Function to get default value from arty.yml
get_default_value() {
    local template="$1"
    local var_name="$2"
    
    if [ -f "$ARTY_CONFIG" ] && command -v yq &> /dev/null; then
        local default=$(yq eval ".hammer.templates.${template}.variables.${var_name}.default" "$ARTY_CONFIG" 2>/dev/null)
        if [ "$default" != "null" ] && [ -n "$default" ]; then
            echo "$default"
            return 0
        fi
    fi
    
    echo ""
}

# Function to get variable description from arty.yml
get_var_description() {
    local template="$1"
    local var_name="$2"
    
    if [ -f "$ARTY_CONFIG" ] && command -v yq &> /dev/null; then
        local desc=$(yq eval ".hammer.templates.${template}.variables.${var_name}.description" "$ARTY_CONFIG" 2>/dev/null)
        if [ "$desc" != "null" ] && [ -n "$desc" ]; then
            echo "$desc"
            return 0
        fi
    fi
    
    echo ""
}

# Function to get all template variables from arty.yml
get_template_variables() {
    local template="$1"
    
    if [ -f "$ARTY_CONFIG" ] && command -v yq &> /dev/null; then
        yq eval ".hammer.templates.${template}.variables | keys | .[]" "$ARTY_CONFIG" 2>/dev/null
    fi
}

# Function to prompt for variables
prompt_for_variables() {
    local template="$1"
    local -n var_array=$2
    
    if [ "$YES_TO_ALL" = true ]; then
        log_info "Using default values for all variables"
        local vars=$(get_template_variables "$template")
        while IFS= read -r var_name; do
            [ -z "$var_name" ] && continue
            local default=$(get_default_value "$template" "$var_name")
            if [ -n "$default" ]; then
                var_array["$var_name"]="$default"
            fi
        done <<< "$vars"
        return 0
    fi
    
    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi
    
    local vars=$(get_template_variables "$template")
    if [ -z "$vars" ]; then
        return 0
    fi
    
    log_info "Please provide values for template variables (press Enter for default):"
    echo ""
    
    while IFS= read -r var_name; do
        [ -z "$var_name" ] && continue
        
        # Skip if already set via CLI
        if [ -n "${var_array[$var_name]}" ]; then
            continue
        fi
        
        local default=$(get_default_value "$template" "$var_name")
        local desc=$(get_var_description "$template" "$var_name")
        
        if [ -n "$desc" ]; then
            echo -e "  ${YELLOW}${var_name}${NC}: $desc"
        else
            echo -e "  ${YELLOW}${var_name}${NC}:"
        fi
        
        if [ -n "$default" ]; then
            read -p "    Value [${default}]: " value
            var_array["$var_name"]="${value:-$default}"
        else
            read -p "    Value: " value
            var_array["$var_name"]="$value"
        fi
    done <<< "$vars"
    
    echo ""
}

# Function to check if file should be overwritten
should_overwrite() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        return 0
    fi
    
    if [ "$FORCE_OVERWRITE" = true ]; then
        return 0
    fi
    
    if [ "$INTERACTIVE" = false ]; then
        return 1
    fi
    
    log_warning "File already exists: $file"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to process template with myst.sh
process_template() {
    local template_file="$1"
    local output_file="$2"
    shift 2
    local myst_args=("$@")
    
    # Check if output file should be overwritten
    if ! should_overwrite "$output_file"; then
        log_info "Skipping: $output_file"
        return 0
    fi
    
    # Create output directory if needed
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    # Process template with myst.sh
    if "$MYST_CMD" "${myst_args[@]}" "$template_file" > "$output_file" 2>/dev/null; then
        log_success "Generated: $output_file"
        return 0
    else
        log_error "Failed to generate: $output_file"
        return 1
    fi
}

# Function to render templates
render_templates() {
    local template_name="$1"
    local template_dir="$2"
    local output_dir="$3"
    shift 3
    local myst_args=("$@")
    
    local template_path="${template_dir}/${template_name}"
    
    if [ ! -d "$template_path" ]; then
        log_error "Template not found: $template_name"
        return 1
    fi
    
    log_info "Processing template: $template_name"
    log_info "Template path: $template_path"
    log_info "Output directory: $output_dir"
    echo ""
    
    # Set partials directory for myst.sh
    local partials_dir="${template_path}/partials"
    if [ -d "$partials_dir" ]; then
        myst_args+=(-p "$partials_dir")
    fi
    
    # Process all .myst files in template directory
    local found_templates=false
    while IFS= read -r -d '' template_file; do
        found_templates=true
        local rel_path="${template_file#$template_path/}"
        
        # Skip partials directory
        if [[ "$rel_path" == partials/* ]]; then
            continue
        fi
        
        # Remove .myst extension from output file
        local output_file="${output_dir}/${rel_path%.myst}"
        
        process_template "$template_file" "$output_file" "${myst_args[@]}"
    done < <(find "$template_path" -type f -name "*.myst" -print0)
    
    if [ "$found_templates" = false ]; then
        log_warning "No .myst template files found in: $template_path"
        return 1
    fi
    
    echo ""
    log_success "Template processing complete!"
    
    return 0
}

# Main function
main() {
    local template_name=""
    local template_dir=""
    local output_dir=""
    local json_file=""
    local yaml_file=""
    declare -A variables
    local list_templates_flag=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            --version)
                echo "hammer.sh version $VERSION"
                exit 0
                ;;
            -l|--list)
                list_templates_flag=true
                shift
                ;;
            -t|--template-dir)
                template_dir="$2"
                shift 2
                ;;
            -v|--var)
                if [[ "$2" == *"="* ]]; then
                    local key="${2%%=*}"
                    local value="${2#*=}"
                    variables["$key"]="$value"
                else
                    log_error "Invalid variable format: $2 (expected KEY=VALUE)"
                    exit 1
                fi
                shift 2
                ;;
            -j|--json)
                json_file="$2"
                shift 2
                ;;
            -y|--yaml)
                yaml_file="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -f|--force)
                FORCE_OVERWRITE=true
                shift
                ;;
            --yes)
                YES_TO_ALL=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "$template_name" ]; then
                    template_name="$1"
                elif [ -z "$output_dir" ]; then
                    output_dir="$1"
                else
                    log_error "Too many arguments"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check dependencies
    check_myst
    
    # Find template directory
    template_dir=$(find_template_dir "$template_dir")
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # List templates if requested
    if [ "$list_templates_flag" = true ]; then
        list_templates "$template_dir"
        exit 0
    fi
    
    # Validate template name
    if [ -z "$template_name" ]; then
        log_error "Template name is required"
        echo ""
        show_usage
        exit 1
    fi
    
    # Set default output directory
    output_dir="${output_dir:-$DEFAULT_OUTPUT_DIR}"
    
    # Prompt for variables if needed
    prompt_for_variables "$template_name" variables
    
    # Build myst.sh arguments
    local myst_args=()
    
    # Add variables
    for key in "${!variables[@]}"; do
        myst_args+=(-v "${key}=${variables[$key]}")
    done
    
    # Add JSON file if provided
    if [ -n "$json_file" ]; then
        if [ ! -f "$json_file" ]; then
            log_error "JSON file not found: $json_file"
            exit 1
        fi
        myst_args+=(-j "$json_file")
    fi
    
    # Add YAML file if provided
    if [ -n "$yaml_file" ]; then
        if ! check_yq; then
            log_error "yq is required for YAML file support"
            exit 1
        fi
        if [ ! -f "$yaml_file" ]; then
            log_error "YAML file not found: $yaml_file"
            exit 1
        fi
        myst_args+=(-y "$yaml_file")
    fi
    
    # Render templates
    render_templates "$template_name" "$template_dir" "$output_dir" "${myst_args[@]}"
}

# Run main function
main "$@"
