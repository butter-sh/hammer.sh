<div align="center">

# hammer.sh

**CLI Facade and Generalization for myst.sh Templating**

[![Organization](https://img.shields.io/badge/org-butter--sh-4ade80?style=for-the-badge&logo=github&logoColor=white)](https://github.com/butter-sh)
[![License](https://img.shields.io/badge/license-MIT-86efac?style=for-the-badge)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/butter-sh/hammer.sh/test.yml?branch=main&style=flat-square&logo=github&color=22c55e)](https://github.com/butter-sh/hammer.sh/actions)
[![Version](https://img.shields.io/github/v/tag/butter-sh/hammer.sh?style=flat-square&label=version&color=4ade80)](https://github.com/butter-sh/hammer.sh/releases)
[![butter.sh](https://img.shields.io/badge/butter.sh-hammer-22c55e?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNMjEgMTZWOGEyIDIgMCAwIDAtMS0xLjczbC03LTRhMiAyIDAgMCAwLTIgMGwtNyA0QTIgMiAwIDAgMCAzIDh2OGEyIDIgMCAwIDAgMSAxLjczbDcgNGEyIDIgMCAwIDAgMiAwbDctNEEyIDIgMCAwIDAgMjEgMTZ6IiBzdHJva2U9IiM0YWRlODAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+PHBvbHlsaW5lIHBvaW50cz0iMy4yNyA2Ljk2IDEyIDEyLjAxIDIwLjczIDYuOTYiIHN0cm9rZT0iIzRhZGU4MCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48bGluZSB4MT0iMTIiIHkxPSIyMi4wOCIgeDI9IjEyIiB5Mj0iMTIiIHN0cm9rZT0iIzRhZGU4MCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4=)](https://butter-sh.github.io/hammer.sh)

*Simplified, user-friendly interface for the powerful myst.sh templating engine*

[Documentation](https://butter-sh.github.io/hammer.sh) • [GitHub](https://github.com/butter-sh/hammer.sh) • [butter.sh](https://github.com/butter-sh)

</div>

---

## Features

- **CLI Facade** - Simplified interface for myst.sh templating
- **Variable Management** - Read variables from CLI, JSON, YAML, or interactive prompts
- **Smart Defaults** - Define default values in arty.yml for each template
- **Template Organization** - Operate in current directory or dedicated template directories
- **Interactive Mode** - Ask users for input with descriptions and defaults
- **Batch Mode** - Use `--yes` flag to accept all defaults
- **Smart Overwriting** - Interactive prompts for existing files with `--force` override
- **Partial Support** - Automatically handles template partials via myst.sh
- **arty.sh Integration** - Full integration with butter.sh ecosystem

## Installation

### Using arty.sh

```bash
# Add to your arty.yml
references:
  - https://github.com/butter-sh/hammer.sh.git

# Install dependencies
arty deps

# Use via arty
arty exec hammer --help
```

### Manual Install

```bash
git clone https://github.com/butter-sh/hammer.sh.git
cd hammer.sh
chmod +x hammer.sh
sudo cp hammer.sh /usr/local/bin/hammer
```

## Quick Start

### List Available Templates

```bash
hammer --list
```

### Generate from Template (Interactive)

```bash
# Interactive mode - prompts for each variable
hammer example-template ./my-project
```

### Generate with CLI Variables

```bash
hammer example-template -v project_name="MyApp" -v author="John Doe"
```

### Generate with Data Files

```bash
# From JSON
hammer example-template -j data.json -o ./output

# From YAML
hammer example-template -y config.yaml -o ./output
```

### Use Defaults Without Prompts

```bash
# Accept all default values
hammer example-template --yes
```

### Force Overwrite Files

```bash
# Skip overwrite prompts
hammer example-template ./my-project --force
```

## Template Structure

Templates are organized in a dedicated `templates/` directory with the following structure:

```
templates/
└── my-template/
    ├── README.md.myst          # Main template file
    ├── main.sh.myst            # Another template file
    └── partials/               # Partial templates (optional)
        ├── _header.myst
        └── _footer.myst
```

### Template Files

- Template files use the `.myst` extension
- Use myst.sh syntax for variables: `{{variable_name}}`
- Partials are included with: `{{> _partial_name}}`
- Output files have `.myst` extension removed

## Configuration with arty.yml

Define template variables and defaults in your `arty.yml`:

```yaml
name: "@myorg/my-project"
version: "1.0.0"

hammer:
  templates:
    my-template:
      description: "My custom template"
      variables:
        project_name:
          description: "Name of the project"
          default: "my-project"
        author:
          description: "Author name"
          default: "Your Name"
        license:
          description: "Project license"
          default: "MIT"
```

When using interactive mode, hammer.sh will:
1. Show the variable description
2. Display the default value
3. Prompt user for input (Enter accepts default)

## Usage Examples

### Example 1: Interactive Generation

```bash
$ hammer example-template ./my-new-project

[ℹ] Please provide values for template variables (press Enter for default):

  project_name: Name of the project
    Value [my-project]: MyAwesomeProject
  author: Author of the project
    Value [Your Name]: John Developer
  license: Project license
    Value [MIT]: ↵

[ℹ] Processing template: example-template
[✓] Generated: ./my-new-project/README.md
[✓] Generated: ./my-new-project/main.sh
[✓] Template processing complete!
```

### Example 2: Non-Interactive with Data File

Create `project-data.json`:
```json
{
  "project_name": "MyApp",
  "author": "Jane Developer",
  "license": "Apache-2.0",
  "year": "2025"
}
```

```bash
hammer example-template -j project-data.json -o ./my-app --yes
```

### Example 3: Combining Options

```bash
# Use JSON for most variables, override one via CLI
hammer example-template \
  -j base-config.json \
  -v author="Custom Author" \
  -o ./output \
  --force
```

### Example 4: Using in CI/CD

```bash
# Non-interactive mode with defaults
hammer example-template --yes --force -o ./dist
```

## CLI Options

### Arguments

- `<template>` - Name of the template to use (required)
- `[output-dir]` - Output directory (default: current directory)

### Options

- `-t, --template-dir DIR` - Custom template directory location
- `-v, --var KEY=VALUE` - Set template variables (repeatable)
- `-j, --json FILE` - Load variables from JSON file
- `-y, --yaml FILE` - Load variables from YAML file (requires `yq`)
- `-o, --output DIR` - Output directory
- `-f, --force` - Force overwrite without prompting
- `--yes` - Use default values without prompting
- `-l, --list` - List available templates
- `-h, --help` - Show help message
- `--version` - Show version

## Creating Custom Templates

### Step 1: Create Template Directory

```bash
mkdir -p templates/my-template/partials
```

### Step 2: Create Template Files

Create `templates/my-template/README.md.myst`:
```mustache
# {{project_name}}

Created by {{author}}

## Description

{{description}}
```

Create `templates/my-template/partials/_header.myst`:
```mustache
<!-- Header for {{project_name}} -->
```

### Step 3: Define Variables in arty.yml

```yaml
hammer:
  templates:
    my-template:
      description: "My custom template"
      variables:
        project_name:
          description: "Project name"
          default: "new-project"
        author:
          description: "Author name"
          default: "Your Name"
        description:
          description: "Project description"
          default: "A new project"
```

### Step 4: Use Your Template

```bash
hammer my-template ./output
```

## Variable Sources (Priority Order)

hammer.sh merges variables from multiple sources in this priority order (highest to lowest):

1. **CLI variables** (`-v, --var`)
2. **JSON file** (`-j, --json`)
3. **YAML file** (`-y, --yaml`)
4. **Interactive prompts** (if not using `--yes`)
5. **Default values** from `arty.yml`

## Interactive Mode Behavior

### Default Mode (Interactive)
- Prompts for each undefined variable
- Shows variable description from arty.yml
- Displays default value
- User can press Enter to accept default

### With `--yes` Flag
- Skips all prompts
- Uses default values from arty.yml
- Fails if no default is defined

### With `--force` Flag
- Skips overwrite confirmations
- Automatically overwrites existing files
- Can be combined with `--yes`

## Integration with myst.sh

hammer.sh is a wrapper around [myst.sh](https://github.com/butter-sh/myst.sh) and supports all myst.sh template features:

- **Variables**: `{{variable_name}}`
- **Conditionals**: `{{#if condition}}...{{/if}}`
- **Loops**: `{{#each items}}...{{/each}}`
- **Partials**: `{{> partial_name}}`
- **Comments**: `{{! comment }}`

## Dependencies

### Required
- `bash` 4.0+
- `myst.sh` - Install via arty.sh or manually

### Optional
- `yq` - For YAML file support
- `arty.sh` - For dependency management

## Examples Directory Structure

A complete example project structure:

```
my-project/
├── arty.yml                    # Project configuration
├── hammer.sh                   # Hammer script (if local)
└── templates/
    ├── web-app/
    │   ├── index.html.myst
    │   ├── package.json.myst
    │   └── partials/
    │       ├── _head.myst
    │       └── _footer.myst
    └── cli-tool/
        ├── README.md.myst
        ├── main.sh.myst
        └── setup.sh.myst
```

## Use Cases

- **Project Scaffolding** - Generate new project structures
- **Documentation** - Create standardized documentation
- **Configuration Files** - Generate config files from templates
- **Code Generation** - Generate boilerplate code
- **CI/CD Templates** - Create pipeline configurations
- **Multi-Environment Configs** - Generate environment-specific files

## Workflow Examples

### Development Workflow

```bash
# Developer creates new microservice
hammer microservice-template \
  -v service_name="user-service" \
  -v author="DevTeam" \
  -o ./services/user-service

cd ./services/user-service
arty deps
npm install
npm start
```

### CI/CD Workflow

```bash
# Automated deployment config generation
hammer k8s-deployment \
  -j environments/production.json \
  --yes \
  --force \
  -o ./k8s/production

kubectl apply -f ./k8s/production/
```

## Troubleshooting

### Template Not Found

```bash
# Check available templates
hammer --list

# Specify custom template directory
hammer --template-dir ./my-templates example-template
```

### Variable Not Defined

Add default value to `arty.yml`:
```yaml
hammer:
  templates:
    my-template:
      variables:
        missing_var:
          default: "default-value"
```

### myst.sh Not Found

```bash
# Install via arty.sh
arty install https://github.com/butter-sh/myst.sh.git

# Or install manually
git clone https://github.com/butter-sh/myst.sh.git
cd myst.sh
./setup.sh
```

## Related Projects

Part of the butter.sh ecosystem:

- **[arty.sh](https://github.com/butter-sh/arty.sh)** - Bash library dependency manager
- **[myst.sh](https://github.com/butter-sh/myst.sh)** - Templating engine (required)
- **[judge.sh](https://github.com/butter-sh/judge.sh)** - Testing framework
- **[leaf.sh](https://github.com/butter-sh/leaf.sh)** - Documentation generator
- **[whip.sh](https://github.com/butter-sh/whip.sh)** - Release management

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created by [valknar](https://github.com/valknarogg)

---

<div align="center">

Part of the [butter.sh](https://github.com/butter-sh) ecosystem

**Unlimited. Independent. Fresh.**

</div>
