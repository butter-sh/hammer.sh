# API Reference

## myst.sh Function Reference

This document provides a complete reference for all functions available when embedding `myst.sh` as a library.

## Utility Functions

### log_debug()

```bash
log_debug "message"
```

**Description**: Log debug message (only shown when `MYST_DEBUG=1`)

**Parameters**:
- `$1` - Debug message to log

**Example**:
```bash
MYST_DEBUG=1
log_debug "Processing template..."
```

### log_info()

```bash
log_info "message"
```

**Description**: Log informational message to stderr

**Parameters**:
- `$1` - Info message to log

### log_success()

```bash
log_success "message"
```

**Description**: Log success message with green checkmark

**Parameters**:
- `$1` - Success message

### log_warn()

```bash
log_warn "message"
```

**Description**: Log warning message with yellow icon

**Parameters**:
- `$1` - Warning message

### log_error()

```bash
log_error "message"
```

**Description**: Log error message with red icon

**Parameters**:
- `$1` - Error message

### die()

```bash
die "error message"
```

**Description**: Log error and exit with status 1

**Parameters**:
- `$@` - Error message

## Variable Management

### myst_set_var()

```bash
myst_set_var "key" "value"
```

**Description**: Set a template variable

**Parameters**:
- `$1` - Variable name (must match `[a-zA-Z_][a-zA-Z0-9_]*`)
- `$2` - Variable value

**Example**:
```bash
myst_set_var "user_name" "Alice"
myst_set_var "user_age" "30"
myst_set_var "is_admin" "true"
```

**Global State**: Updates `MYST_VARS` associative array

### myst_get_var()

```bash
myst_get_var "key" ["default"]
```

**Description**: Get a template variable value

**Parameters**:
- `$1` - Variable name
- `$2` - (Optional) Default value if variable not set

**Returns**: Variable value or default via stdout

**Example**:
```bash
user=$(myst_get_var "user_name")
status=$(myst_get_var "status" "inactive")
```

### myst_load_json()

```bash
myst_load_json "file.json"
```

**Description**: Load all key-value pairs from a JSON file into template variables

**Parameters**:
- `$1` - Path to JSON file

**Requirements**: `jq` must be installed

**Example**:
```bash
# data.json: {"name": "Alice", "age": 30}
myst_load_json "data.json"
# Now {{name}} and {{age}} are available
```

**Errors**: Dies if file not found or `jq` not installed

### myst_load_yaml()

```bash
myst_load_yaml "file.yml"
```

**Description**: Load all key-value pairs from a YAML file

**Parameters**:
- `$1` - Path to YAML file

**Requirements**: `yq` must be installed

**Example**:
```bash
# config.yml:
# name: Alice
# age: 30
myst_load_yaml "config.yml"
```

**Errors**: Dies if file not found or `yq` not installed

### myst_load_env()

```bash
myst_load_env ["prefix"]
```

**Description**: Load environment variables with specified prefix

**Parameters**:
- `$1` - (Optional) Environment variable prefix (default: `MYST_`)

**Example**:
```bash
export MYST_USER=alice
export MYST_ROLE=admin
myst_load_env "MYST_"
# Variables: USER=alice, ROLE=admin

export APP_NAME="MyApp"
myst_load_env "APP_"
# Variable: NAME="MyApp"
```

### myst_load_stdin()

```bash
myst_load_stdin
```

**Description**: Load variables from JSON on stdin

**Requirements**: `jq` must be installed

**Example**:
```bash
echo '{"name":"Bob","age":25}' | myst_load_stdin
```

### myst_set_cli_var()

```bash
myst_set_cli_var "key=value"
```

**Description**: Parse and set variable from `key=value` format

**Parameters**:
- `$1` - Assignment in format `key=value`

**Example**:
```bash
myst_set_cli_var "user_name=Alice"
myst_set_cli_var "count=42"
```

## Template Loading

### myst_load_template()

```bash
myst_load_template "path/to/template.myst"
```

**Description**: Load template file contents

**Parameters**:
- `$1` - Path to template file

**Returns**: Template content via stdout

**Example**:
```bash
template=$(myst_load_template "templates/page.myst")
```

**Errors**: Dies if file not found

### myst_load_partial()

```bash
myst_load_partial "partial_name" ["directory"]
```

**Description**: Load a partial template by name

**Parameters**:
- `$1` - Partial name (without `.myst` extension)
- `$2` - (Optional) Directory to search (default: current directory)

**Example**:
```bash
myst_load_partial "header" "./partials"
myst_load_partial "footer"
```

**Global State**: Updates `MYST_PARTIALS` associative array

**File Resolution**:
1. Tries `{dir}/{name}.myst`
2. Tries `{dir}/{name}`

### myst_load_partials_dir()

```bash
myst_load_partials_dir "directory"
```

**Description**: Load all `.myst` files from a directory as partials

**Parameters**:
- `$1` - Directory path

**Example**:
```bash
myst_load_partials_dir "./partials"
# Loads all *.myst files as partials
```

**Global State**: Updates `MYST_PARTIALS` associative array

## Rendering Functions

### myst_render()

```bash
result=$(myst_render "$template_content")
```

**Description**: Main rendering function - processes template with all features

**Parameters**:
- `$1` - Template content as string

**Returns**: Rendered output via stdout

**Example**:
```bash
template='Hello, {{name}}!'
myst_set_var "name" "World"
output=$(myst_render "$template")
echo "$output"  # Hello, World!
```

**Processing Order**:
1. Template inheritance
2. Partials
3. Loops
4. Conditionals
5. Variables

### myst_render_vars()

```bash
result=$(myst_render_vars "$content")
```

**Description**: Render only variable interpolations `{{variable}}`

**Parameters**:
- `$1` - Content with variable placeholders

**Returns**: Content with variables replaced

**Example**:
```bash
myst_set_var "name" "Alice"
result=$(myst_render_vars "Hello, {{name}}!")
```

### myst_render_conditionals()

```bash
result=$(myst_render_conditionals "$content")
```

**Description**: Render only conditional blocks

**Parameters**:
- `$1` - Content with conditionals

**Returns**: Content with conditionals processed

**Supported**:
- `{{#if var}}...{{/if}}`
- `{{#unless var}}...{{/unless}}`

**Example**:
```bash
myst_set_var "admin" "true"
template='{{#if admin}}Admin Panel{{/if}}'
result=$(myst_render_conditionals "$template")
```

### myst_render_loops()

```bash
result=$(myst_render_loops "$content")
```

**Description**: Render only loop structures

**Parameters**:
- `$1` - Content with loops

**Returns**: Content with loops expanded

**Supported**:
- `{{#each array}}...{{/each}}`
- `{{this}}` or `{{.}}` for current item

**Example**:
```bash
myst_set_var "items" "a,b,c"
template='{{#each items}}- {{this}}\n{{/each}}'
result=$(myst_render_loops "$template")
```

### myst_render_partials()

```bash
result=$(myst_render_partials "$content")
```

**Description**: Render only partial inclusions

**Parameters**:
- `$1` - Content with partial references

**Returns**: Content with partials included

**Supported**:
- `{{> partial_name}}`

**Example**:
```bash
MYST_PARTIALS["header"]="<h1>Title</h1>"
template='{{> header}}<p>Content</p>'
result=$(myst_render_partials "$template")
```

### myst_render_inheritance()

```bash
result=$(myst_render_inheritance "$content")
```

**Description**: Process template inheritance and slots

**Parameters**:
- `$1` - Content with inheritance directives

**Returns**: Content with inheritance applied

**Supported**:
- `{{#extend layout}}...{{/extend}}`
- `{{#slot name}}...{{/slot}}`
- `{{slot:name}}` in layouts

**Example**:
```bash
MYST_LAYOUTS["base"]='<html>{{slot:body}}</html>'
template='{{#extend base}}{{#slot body}}<p>Hi</p>{{/slot}}{{/extend}}'
result=$(myst_render_inheritance "$template")
```

## Global State

### MYST_VARS

```bash
declare -A MYST_VARS
```

**Description**: Associative array storing all template variables

**Access**:
```bash
# Direct access
echo "${MYST_VARS[user_name]}"

# Via function (preferred)
user=$(myst_get_var "user_name")
```

### MYST_PARTIALS

```bash
declare -A MYST_PARTIALS
```

**Description**: Associative array storing loaded partials

**Access**:
```bash
# Direct access
echo "${MYST_PARTIALS[header]}"

# Automatically used by myst_render_partials()
```

### MYST_LAYOUTS

```bash
declare -A MYST_LAYOUTS
```

**Description**: Associative array storing layout templates

**Access**:
```bash
# Direct set
MYST_LAYOUTS["main"]=$(cat layout.myst)

# Used by myst_render_inheritance()
```

### MYST_DEBUG

```bash
MYST_DEBUG=0  # or 1
```

**Description**: Enable debug output

**Values**:
- `0` - Debug disabled (default)
- `1` - Debug enabled

**Example**:
```bash
MYST_DEBUG=1 ./myst.sh render template.myst
```

## Complete Example

```bash
#!/usr/bin/env bash

# Source myst.sh as a library
source ./myst.sh

# Enable debug
MYST_DEBUG=1

# Set variables
myst_set_var "site_name" "My Website"
myst_set_var "year" "2025"

# Load from JSON
myst_load_json "config.json"

# Load from environment
export MYST_THEME=dark
myst_load_env "MYST_"

# Load partials
myst_load_partials_dir "./partials"

# Load layout
MYST_LAYOUTS["main"]=$(cat "layouts/main.myst")

# Load and render template
template=$(myst_load_template "pages/index.myst")
output=$(myst_render "$template")

# Save output
echo "$output" > "dist/index.html"

log_success "Generated dist/index.html"
```

## CLI Integration

All functions can be used programmatically, but the CLI provides convenience:

```bash
# CLI
./myst.sh render template.myst -j data.json -o output.html

# Equivalent programmatic
source ./myst.sh
myst_load_json "data.json"
template=$(myst_load_template "template.myst")
output=$(myst_render "$template")
echo "$output" > output.html
```

## Error Handling

Functions that may fail:

- `myst_load_json()` - File not found, invalid JSON, jq missing
- `myst_load_yaml()` - File not found, invalid YAML, yq missing
- `myst_load_template()` - File not found
- `die()` - Exits process

Defensive coding:

```bash
# Check before loading
if [[ -f "data.json" ]]; then
    myst_load_json "data.json"
else
    log_warn "data.json not found, using defaults"
fi

# Check dependencies
if command -v jq >/dev/null 2>&1; then
    myst_load_json "data.json"
fi
```

## Performance Tips

1. **Cache partials**: Load partials once, render multiple templates
2. **Pre-process data**: Use `jq` for complex transformations before rendering
3. **Avoid deep nesting**: Deeply nested conditionals slow rendering
4. **Batch operations**: Process multiple templates in same shell session

```bash
# Good: Load once, render many
source ./myst.sh
myst_load_json "data.json"
myst_load_partials_dir "./partials"

for page in pages/*.myst; do
    output=$(myst_render "$(cat "$page")")
    echo "$output" > "dist/$(basename "$page" .myst).html"
done
```

---

For more examples, see [README.md](README.md) and [DSL_DOCUMENTATION.md](DSL_DOCUMENTATION.md)
