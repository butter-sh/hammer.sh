#!/usr/bin/env bash

# myst.sh - A state-of-the-art templating engine
# Version: 1.0.0
#
# Features:
# - Mustache-style template syntax (.myst files)
# - String interpolation: {{variable}}
# - Control structures: {{#if}}...{{/if}}
# - Loop control: {{#each}}...{{/each}}
# - Template inheritance with slots: {{#extend}}...{{/extend}}, {{#slot}}...{{/slot}}
# - Template partials/transclusion: {{> partial}}
# - Multiple input formats: JSON, YAML, ENV, stdin, CLI args
# - Can be embedded in other applications

set -euo pipefail

# Configuration
VERSION="1.0.0"
MYST_ENGINE_LIB="${BASH_SOURCE[0]}"

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

# Global state
declare -A MYST_VARS=()
declare -A MYST_PARTIALS=()
declare -A MYST_LAYOUTS=()
MYST_DEBUG=${MYST_DEBUG:-0}

#=============================================================================
# Core Utilities
#=============================================================================

log_debug() {
    [[ $MYST_DEBUG -eq 1 ]] && echo -e "${CYAN}[DEBUG]${NC} $*" >&2
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

die() {
    log_error "$@"
    exit 1
}

#=============================================================================
# Variable Management
#=============================================================================

# Set a template variable
myst_set_var() {
    local key="$1"
    local value="$2"
    MYST_VARS["$key"]="$value"
    log_debug "Set variable: $key = $value"
}

# Get a template variable
myst_get_var() {
    local key="$1"
    local default="${2:-}"
    echo "${MYST_VARS[$key]:-$default}"
}

# Load variables from JSON
myst_load_json() {
    local json_file="$1"
    
    if [[ ! -f "$json_file" ]]; then
        die "JSON file not found: $json_file"
    fi
    
    log_debug "Loading JSON from: $json_file"
    
    # Parse JSON and set variables
    while IFS= read -r line; do
        local key=$(echo "$line" | cut -d'=' -f1)
        local value=$(echo "$line" | cut -d'=' -f2-)
        myst_set_var "$key" "$value"
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$json_file")
}

# Load variables from YAML
myst_load_yaml() {
    local yaml_file="$1"
    
    if [[ ! -f "$yaml_file" ]]; then
        die "YAML file not found: $yaml_file"
    fi
    
    if ! command -v yq >/dev/null 2>&1; then
        die "yq is required for YAML parsing but not installed"
    fi
    
    log_debug "Loading YAML from: $yaml_file"
    
    # Parse YAML and set variables
    while IFS= read -r line; do
        local key=$(echo "$line" | cut -d'=' -f1)
        local value=$(echo "$line" | cut -d'=' -f2-)
        myst_set_var "$key" "$value"
    done < <(yq eval -o=json "$yaml_file" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
}

# Load variables from environment with prefix
myst_load_env() {
    local prefix="${1:-MYST_}"
    
    log_debug "Loading environment variables with prefix: $prefix"
    
    while IFS='=' read -r key value; do
        if [[ "$key" =~ ^${prefix}(.+)$ ]]; then
            local var_name="${BASH_REMATCH[1]}"
            myst_set_var "$var_name" "$value"
        fi
    done < <(env)
}

# Load variables from stdin (JSON)
myst_load_stdin() {
    log_debug "Loading variables from stdin"
    
    local json_content=$(cat)
    
    while IFS= read -r line; do
        local key=$(echo "$line" | cut -d'=' -f1)
        local value=$(echo "$line" | cut -d'=' -f2-)
        myst_set_var "$key" "$value"
    done < <(echo "$json_content" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
}

# Set variable from command line (key=value)
myst_set_cli_var() {
    local assignment="$1"
    
    if [[ "$assignment" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
        local key="${BASH_REMATCH[1]}"
        local value="${BASH_REMATCH[2]}"
        myst_set_var "$key" "$value"
    else
        log_warn "Invalid variable assignment: $assignment"
    fi
}

#=============================================================================
# Template Loading and Parsing
#=============================================================================

# Load a template file
myst_load_template() {
    local template_path="$1"
    
    if [[ ! -f "$template_path" ]]; then
        die "Template not found: $template_path"
    fi
    
    log_debug "Loading template: $template_path"
    cat "$template_path"
}

# Load a partial template
myst_load_partial() {
    local partial_name="$1"
    local partials_dir="${2:-.}"
    
    local partial_path="${partials_dir}/${partial_name}.myst"
    
    if [[ -f "$partial_path" ]]; then
        log_debug "Loading partial: $partial_name from $partial_path"
        MYST_PARTIALS["$partial_name"]=$(cat "$partial_path")
        return 0
    fi
    
    # Try without .myst extension
    partial_path="${partials_dir}/${partial_name}"
    if [[ -f "$partial_path" ]]; then
        log_debug "Loading partial: $partial_name from $partial_path"
        MYST_PARTIALS["$partial_name"]=$(cat "$partial_path")
        return 0
    fi
    
    log_warn "Partial not found: $partial_name"
    MYST_PARTIALS["$partial_name"]=""
    return 1
}

# Load all partials from a directory
myst_load_partials_dir() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        log_debug "Partials directory not found: $dir"
        return 1
    fi
    
    log_debug "Loading partials from: $dir"
    
    while IFS= read -r -d '' file; do
        local basename=$(basename "$file" .myst)
        MYST_PARTIALS["$basename"]=$(cat "$file")
        log_debug "Loaded partial: $basename"
    done < <(find "$dir" -name "*.myst" -type f -print0)
}

#=============================================================================
# Template Rendering Engine
#=============================================================================

# Escape special regex characters
escape_regex() {
    local str="$1"
    echo "$str" | sed 's/[]\/$*.^[]/\\&/g'
}

# Render simple variable interpolation {{variable}}
myst_render_vars() {
    local content="$1"
    
    log_debug "Rendering variables..."
    
    # Find all {{variable}} patterns
    for key in "${!MYST_VARS[@]}"; do
        local value="${MYST_VARS[$key]}"
        local escaped_key=$(escape_regex "$key")
        content=$(echo "$content" | sed "s/{{${escaped_key}}}/${value}/g")
    done
    
    echo "$content"
}

# Render conditional blocks {{#if condition}}...{{/if}}
myst_render_conditionals() {
    local content="$1"
    
    log_debug "Rendering conditionals..."
    
    # Process all {{#if var}}...{{/if}} blocks
    while [[ "$content" =~ \{\{#if[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\}(.*)\{\{/if\}\} ]]; do
        local var_name="${BASH_REMATCH[1]}"
        local block_content="${BASH_REMATCH[2]}"
        local full_match="${BASH_REMATCH[0]}"
        
        local var_value=$(myst_get_var "$var_name")
        
        local replacement=""
        if [[ -n "$var_value" && "$var_value" != "false" && "$var_value" != "0" ]]; then
            replacement="$block_content"
        fi
        
        content="${content//$full_match/$replacement}"
    done
    
    # Process {{#unless var}}...{{/unless}} blocks
    while [[ "$content" =~ \{\{#unless[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\}(.*)\{\{/unless\}\} ]]; do
        local var_name="${BASH_REMATCH[1]}"
        local block_content="${BASH_REMATCH[2]}"
        local full_match="${BASH_REMATCH[0]}"
        
        local var_value=$(myst_get_var "$var_name")
        
        local replacement=""
        if [[ -z "$var_value" || "$var_value" == "false" || "$var_value" == "0" ]]; then
            replacement="$block_content"
        fi
        
        content="${content//$full_match/$replacement}"
    done
    
    echo "$content"
}

# Render loop blocks {{#each array}}...{{/each}}
myst_render_loops() {
    local content="$1"
    
    log_debug "Rendering loops..."
    
    # Process {{#each var}}...{{/each}} blocks
    # Note: This is a simplified implementation. For full array support,
    # you'd need to parse JSON arrays properly
    while [[ "$content" =~ \{\{#each[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\}(.*)\{\{/each\}\} ]]; do
        local var_name="${BASH_REMATCH[1]}"
        local block_content="${BASH_REMATCH[2]}"
        local full_match="${BASH_REMATCH[0]}"
        
        local array_content=$(myst_get_var "$var_name")
        
        local replacement=""
        if [[ -n "$array_content" ]]; then
            # Split array content by commas and render block for each
            IFS=',' read -ra items <<< "$array_content"
            for item in "${items[@]}"; do
                local item_trimmed=$(echo "$item" | xargs)
                local rendered_block="$block_content"
                # Replace {{this}} or {{.}} with current item
                rendered_block="${rendered_block//\{\{this\}\}/$item_trimmed}"
                rendered_block="${rendered_block//\{\{.\}\}/$item_trimmed}"
                replacement+="$rendered_block"
            done
        fi
        
        content="${content//$full_match/$replacement}"
    done
    
    echo "$content"
}

# Render partials {{> partial_name}}
myst_render_partials() {
    local content="$1"
    
    log_debug "Rendering partials..."
    
    while [[ "$content" =~ \{\{&gt;[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)\}\} ]]; do
        local partial_name="${BASH_REMATCH[1]}"
        local full_match="${BASH_REMATCH[0]}"
        
        local partial_content="${MYST_PARTIALS[$partial_name]:-}"
        
        if [[ -z "$partial_content" ]]; then
            log_warn "Partial '$partial_name' not loaded"
        fi
        
        content="${content//$full_match/$partial_content}"
    done
    
    # Also support {{> partial_name}} format
    while [[ "$content" =~ \{\{&gt;[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\} ]]; do
        local partial_name="${BASH_REMATCH[1]}"
        local full_match="${BASH_REMATCH[0]}"
        
        local partial_content="${MYST_PARTIALS[$partial_name]:-}"
        content="${content//$full_match/$partial_content}"
    done
    
    echo "$content"
}

# Render template with inheritance/slots
myst_render_inheritance() {
    local content="$1"
    
    log_debug "Processing template inheritance..."
    
    # Extract layout reference {{#extend layout_name}}
    if [[ "$content" =~ \{\{#extend[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\} ]]; then
        local layout_name="${BASH_REMATCH[1]}"
        log_debug "Template extends: $layout_name"
        
        # Load layout if not already loaded
        if [[ -z "${MYST_LAYOUTS[$layout_name]:-}" ]]; then
            log_warn "Layout '$layout_name' not loaded"
            return
        fi
        
        local layout_content="${MYST_LAYOUTS[$layout_name]}"
        
        # Extract all slots from child template
        declare -A slots
        while [[ "$content" =~ \{\{#slot[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\}\}(.*)\{\{/slot\}\} ]]; do
            local slot_name="${BASH_REMATCH[1]}"
            local slot_content="${BASH_REMATCH[2]}"
            slots["$slot_name"]="$slot_content"
            
            # Remove processed slot from content
            content="${content//\{\{#slot $slot_name\}\}$slot_content\{\{\/slot\}\}/}"
        done
        
        # Replace slots in layout
        for slot_name in "${!slots[@]}"; do
            local slot_content="${slots[$slot_name]}"
            layout_content="${layout_content//\{\{slot:$slot_name\}\}/$slot_content}"
        done
        
        content="$layout_content"
    fi
    
    echo "$content"
}

# Main rendering function
myst_render() {
    local content="$1"
    
    log_debug "Starting render pipeline..."
    
    # Render in specific order
    content=$(myst_render_inheritance "$content")
    content=$(myst_render_partials "$content")
    content=$(myst_render_loops "$content")
    content=$(myst_render_conditionals "$content")
    content=$(myst_render_vars "$content")
    
    echo "$content"
}

#=============================================================================
# CLI Interface
#=============================================================================

show_help() {
    cat << EOF
myst.sh - A state-of-the-art templating engine

USAGE:
    myst.sh render [OPTIONS] <template>

TEMPLATE INPUT:
    <template>              Path to .myst template file
    -d, --dir <path>        Template directory (default: current directory)
    -t, --template <file>   Template file to render
    --stdin                 Read template from stdin

VARIABLE INPUT:
    -v, --var <key=value>   Set template variable (can be repeated)
    -j, --json <file>       Load variables from JSON file
    -y, --yaml <file>       Load variables from YAML file
    -e, --env [prefix]      Load environment variables (default prefix: MYST_)
    --stdin-vars            Read variables as JSON from stdin

PARTIALS &amp; LAYOUTS:
    -p, --partials <dir>    Directory containing partial templates
    -l, --layout <file>     Load layout template

OUTPUT:
    -o, --output <file>     Write output to file (default: stdout)

OPTIONS:
    -h, --help              Show this help message
    -V, --version           Show version
    --debug                 Enable debug output

TEMPLATE SYNTAX:
    String interpolation:   {{variable}}
    Conditionals:           {{#if var}}...{{/if}}
                            {{#unless var}}...{{/unless}}
    Loops:                  {{#each items}}{{this}}{{/each}}
    Partials:               {{> partial_name}}
    Inheritance:            {{#extend layout}}
                              {{#slot name}}content{{/slot}}
                            {{/extend}}
    Layout slots:           {{slot:name}}

EXAMPLES:
    # Basic rendering with variables
    myst.sh render template.myst -v name=John -v age=30

    # Load variables from JSON
    myst.sh render template.myst -j vars.json

    # Use partials
    myst.sh render template.myst -p ./partials -v title=Hello

    # Template from stdin
    echo '{{greeting}} {{name}}!' | myst.sh render --stdin -v greeting=Hello -v name=World

    # Environment variables
    export MYST_USER=admin
    myst.sh render template.myst -e

    # With layout inheritance
    myst.sh render page.myst -l layout.myst -p ./partials

EMBEDDING MYST:
    You can source myst.sh in your own scripts:
    
    source myst.sh
    myst_set_var "name" "value"
    myst_load_json "vars.json"
    result=\$(myst_render "\$(cat template.myst)")

EOF
}

show_version() {
    echo "myst.sh version $VERSION"
}

# Main command handler
cmd_render() {
    local template_file=""
    local template_dir="."
    local output_file=""
    local use_stdin=false
    local use_stdin_vars=false
    local partials_dir=""
    local layout_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -V|--version)
                show_version
                exit 0
                ;;
            --debug)
                MYST_DEBUG=1
                shift
                ;;
            -d|--dir)
                template_dir="$2"
                shift 2
                ;;
            -t|--template)
                template_file="$2"
                shift 2
                ;;
            --stdin)
                use_stdin=true
                shift
                ;;
            -v|--var)
                myst_set_cli_var "$2"
                shift 2
                ;;
            -j|--json)
                myst_load_json "$2"
                shift 2
                ;;
            -y|--yaml)
                myst_load_yaml "$2"
                shift 2
                ;;
            -e|--env)
                local prefix="${2:-MYST_}"
                myst_load_env "$prefix"
                if [[ -n "${2:-}" ]]; then
                    shift 2
                else
                    shift
                fi
                ;;
            --stdin-vars)
                use_stdin_vars=true
                shift
                ;;
            -p|--partials)
                partials_dir="$2"
                shift 2
                ;;
            -l|--layout)
                layout_file="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -*)
                die "Unknown option: $1"
                ;;
            *)
                if [[ -z "$template_file" ]]; then
                    template_file="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Load partials if specified
    if [[ -n "$partials_dir" ]]; then
        myst_load_partials_dir "$partials_dir"
    fi
    
    # Load layout if specified
    if [[ -n "$layout_file" ]]; then
        local layout_name=$(basename "$layout_file" .myst)
        MYST_LAYOUTS["$layout_name"]=$(cat "$layout_file")
        log_debug "Loaded layout: $layout_name"
    fi
    
    # Load variables from stdin if requested
    if [[ "$use_stdin_vars" == true ]]; then
        myst_load_stdin
    fi
    
    # Load template
    local template_content=""
    if [[ "$use_stdin" == true ]]; then
        template_content=$(cat)
    elif [[ -n "$template_file" ]]; then
        if [[ "$template_file" = /* ]]; then
            # Absolute path
            template_content=$(myst_load_template "$template_file")
        else
            # Relative to template_dir
            template_content=$(myst_load_template "${template_dir}/${template_file}")
        fi
    else
        die "No template specified. Use -t, positional argument, or --stdin"
    fi
    
    # Render template
    local result=$(myst_render "$template_content")
    
    # Output result
    if [[ -n "$output_file" ]]; then
        echo "$result" > "$output_file"
        log_success "Rendered to: $output_file"
    else
        echo "$result"
    fi
}

# Main entry point
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    local command="${1:-}"
    shift || true
    
    case "$command" in
        render)
            cmd_render "$@"
            ;;
        -h|--help|help)
            show_help
            exit 0
            ;;
        -V|--version|version)
            show_version
            exit 0
            ;;
        *)
            # Treat as template file for convenience
            cmd_render -t "$command" "$@"
            ;;
    esac
}

# Only run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
