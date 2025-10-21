# hammer.sh Templates

This directory contains templates for hammer.sh. Each subdirectory represents a template that can be used to generate projects or files.

## Template Structure

Each template should have the following structure:

```
template-name/
├── file1.ext.myst           # Template file (will become file1.ext)
├── file2.ext.myst           # Another template file
└── partials/                # Optional: Partial templates
    ├── _header.myst
    ├── _footer.myst
    └── _common.myst
```

## Template Syntax

Templates use myst.sh syntax:

- **Variables**: `{{variable_name}}`
- **Partials**: `{{> _partial_name}}`
- **Conditionals**: `{{#if condition}}...{{/if}}`
- **Loops**: `{{#each items}}...{{/each}}`
- **Comments**: `{{! This is a comment }}`

## Defining Template Variables

Add variable definitions to `arty.yml` in the project root:

```yaml
hammer:
  templates:
    template-name:
      description: "Description of your template"
      variables:
        variable_name:
          description: "What this variable is for"
          default: "default-value"
```

## Creating a New Template

1. Create a new directory: `mkdir -p templates/my-template/partials`
2. Add .myst template files
3. Define variables in arty.yml
4. Test with: `./hammer.sh my-template -o ./test-output --yes`

## Available Templates

### example-template

A basic example demonstrating hammer.sh features.

**Files generated:**
- README.md
- main.sh

**Variables:**
- `project_name`: Name of the project
- `author`: Author name
- `license`: Project license
- `year`: Current year

**Usage:**
```bash
./hammer.sh example-template ./my-project
```

## Best Practices

1. **Use .myst extension** for all template files
2. **Organize partials** in a dedicated `partials/` subdirectory
3. **Name partials with underscore** prefix (e.g., `_header.myst`)
4. **Document variables** in arty.yml with descriptions and defaults
5. **Keep templates simple** and focused on specific use cases
6. **Test templates** before committing

## Template Variable Priority

When using hammer.sh, variables are resolved in this order (highest to lowest):

1. CLI variables (`-v, --var`)
2. JSON file (`-j, --json`)
3. YAML file (`-y, --yaml`)
4. Interactive user input
5. Defaults from arty.yml

## Examples

See the `examples/` directory for usage examples.
