# hammer.sh

A configurable bash project generator CLI that creates projects from templates.

## Overview

hammer.sh is a powerful code generator that helps you quickly scaffold new bash projects from customizable templates. It comes with built-in templates for creating library managers, starter projects, and more.

## Features

- 🔨 Generate projects from templates
- 🎨 Variable substitution in templates
- 📦 Built-in templates (arty.sh, starter, leaf)
- 🔧 Fully configurable
- 🚀 Easy to extend with custom templates

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/hammer.sh.git
cd hammer.sh
chmod +x hammer.sh

# Optional: Add to PATH
sudo ln -s "$(pwd)/hammer.sh" /usr/local/bin/hammer
```

## Quick Start

```bash
# List available templates
hammer --list

# Generate a new arty.sh library manager
hammer arty my-lib-manager

# Generate a starter bash project
hammer starter my-project

# Generate a documentation site generator
hammer leaf my-docs-generator

# Generate with custom directory
hammer starter my-app --dir ./projects

# Generate with variables
hammer starter my-app -v author="John Doe" -v license=MIT
```

## Usage

```bash
hammer.sh <template> <project-name> [options]
```

### Options

- `-d, --dir <path>` - Target directory (default: current directory)
- `-v, --vars <key=value>` - Set template variables (can be repeated)
- `-l, --list` - List available templates
- `-h, --help` - Show help message

### Examples

```bash
# Basic usage
hammer arty my-library

# Custom target directory
hammer starter my-project --dir ~/projects

# With variables
hammer starter my-app \
  -v author="Jane Smith" \
  -v license=Apache-2.0 \
  -v description="My awesome app"
```

## Built-in Templates

### arty.sh Template

Generates a complete bash library repository management system.

**Features:**
- Git-based library installation
- Dependency management with `arty.yml`
- Setup hooks for library initialization
- Curl-installable
- Reference system for dependencies

**Generated files:**
- `arty.sh` - Main library manager script
- `arty.yml` - Project configuration file
- `README.md` - Documentation
- `.gitignore` - Git ignore file
- `setup.sh` - Setup hook
- `LICENSE` - MIT license

**Usage:**
```bash
hammer arty my-lib-manager
cd my-lib-manager
chmod +x arty.sh
./arty.sh --help
```

### Starter Template

Generates a basic bash project skeleton with arty.sh integration.

**Features:**
- Ready-to-use project structure
- arty.yml configuration
- Example index.sh with logging utilities
- Git-ready with .gitignore

**Generated files:**
- `arty.yml` - Project configuration
- `index.sh` - Main entry point
- `README.md` - Documentation
- `.gitignore` - Git ignore file

**Usage:**
```bash
hammer starter my-project
cd my-project
chmod +x index.sh
./index.sh
```

### leaf Template

Generates a beautiful static documentation site generator for arty.sh projects.

**Features:**
- Modern, responsive design with Tailwind CSS v4
- Automatic parsing of arty.yml, README.md, and project files
- Syntax highlighting with Highlight.js
- Dark/light theme toggle with localStorage persistence
- Source file and examples display
- Project icon integration
- Mobile-friendly layout
- Single-file HTML output

**Generated files:**
- `leaf.sh` - Main documentation generator script
- `arty.yml` - Project configuration
- `README.md` - Documentation for the generator
- `.gitignore` - Git ignore file
- `LICENSE` - MIT license

**Usage:**
```bash
hammer leaf my-docs-generator
cd my-docs-generator
chmod +x leaf.sh

# Generate docs for any arty.sh project
./leaf.sh /path/to/your/arty-project

# Or generate docs for current directory
./leaf.sh

# Open the generated documentation
open docs/index.html
```

**Example Output:**
The generator creates a beautiful single-page documentation site with:
- Hero section with project icon and metadata
- Overview section from README.md
- Source files with syntax-highlighted code
- Examples section with all example files
- Smooth scrolling navigation
- Interactive dark/light theme switcher

**Perfect for:**
- Creating project documentation websites
- Showcasing bash libraries
- Generating API documentation
- Building developer guides
- Sharing code examples

## Template Variables

Templates support variable substitution using `{{variable}}` syntax:

### Built-in Variables

- `{{project_name}}` - Name of the project
- `{{year}}` - Current year
- `{{date}}` - Current date (YYYY-MM-DD)

### Custom Variables

Pass custom variables using the `-v` flag:

```bash
hammer starter my-app \
  -v author="Your Name" \
  -v email="you@example.com" \
  -v license=MIT
```

In your template files, use:
```
Author: {{author}}
Email: {{email}}
License: {{license}}
```

## Creating Custom Templates

### Template Structure

```
templates/
└── mytemplate/
    ├── .template          # Template metadata
    ├── README.md          # Files to be generated
    ├── main.sh
    └── config.yml
```

### Template Metadata

Create a `.template` file:

```bash
description="My custom template"
version="1.0.0"
```

### Using Variables in Templates

Use `{{variable}}` syntax in any file:

```bash
#!/usr/bin/env bash
# {{project_name}} - Version {{version}}
# Author: {{author}}

echo "Hello from {{project_name}}!"
```

### Example Custom Template

```bash
# Create template directory
mkdir -p templates/webapp

# Create template metadata
cat > templates/webapp/.template << EOF
description="A web application template"
version="1.0.0"
EOF

# Create template files
cat > templates/webapp/server.sh << 'EOF'
#!/usr/bin/env bash
# {{project_name}} Server

echo "Starting {{project_name}}..."
python3 -m http.server 8080
EOF

# Use your template
hammer webapp my-webapp
```

## Integration with arty.sh

hammer.sh templates can generate arty.sh-compatible projects:

```yaml
# arty.yml in generated project
name: "{{project_name}}"
version: "0.1.0"
description: "Generated by hammer.sh"

references:
  - https://github.com/user/some-library.git

main: "index.sh"
```

Install dependencies after generation:

```bash
hammer starter my-project
cd my-project
arty deps  # Install references from arty.yml
```

## Project Examples

### judge.sh - Testing Framework

A complete bash testing framework created with arty.sh:

```bash
cd judge.sh
./judge.sh test examples/basic_test.sh
```

Features:
- Rich assertion library
- Colorful output
- Test discovery
- Verbose mode
- CI/CD integration

See `judge.sh/` directory for full implementation.

## Directory Structure

```
hammer.sh/
├── hammer.sh                 # Main CLI tool
├── templates/                # Template directory
│   ├── arty/                 # arty.sh template
│   │   ├── .template
│   │   ├── arty.sh
│   │   ├── arty.yml
│   │   ├── README.md
│   │   ├── .gitignore
│   │   ├── setup.sh
│   │   └── LICENSE
│   ├── starter/              # Starter template
│   │   ├── .template
│   │   ├── arty.yml
│   │   ├── index.sh
│   │   ├── README.md
│   │   └── .gitignore
│   └── leaf/           # Documentation generator
│       ├── .template
│       ├── leaf.sh
│       ├── arty.yml
│       ├── README.md
│       ├── .gitignore
│       └── LICENSE
└── README.md

judge.sh/                     # Example project
├── judge.sh                  # Testing framework
├── arty.yml                  # Configuration
├── examples/
│   └── basic_test.sh
├── README.md
├── .gitignore
└── LICENSE
```

## Advanced Usage

### Batch Generation

Generate multiple projects:

```bash
for name in lib1 lib2 lib3; do
  hammer starter "$name" --dir ./projects
done
```

### Template Development

1. Create template directory in `templates/`
2. Add `.template` metadata file
3. Create template files with `{{variables}}`
4. Test with `hammer <template> test-project`

### Variable Validation

Templates can include validation logic in setup scripts:

```bash
#!/usr/bin/env bash
# setup.sh

if [[ -z "{{author}}" ]]; then
  echo "Error: author variable required"
  exit 1
fi

echo "Setting up {{project_name}} by {{author}}"
```

## Tips and Best Practices

1. **Use descriptive template names** - Make it clear what each template generates
2. **Include good defaults** - Templates should work with minimal configuration
3. **Document variables** - List required and optional variables in README
4. **Test templates** - Generate and test projects before committing templates
5. **Version templates** - Use .template version field to track changes
6. **Keep it simple** - Templates should be easy to understand and modify

## Troubleshooting

### Template not found
```bash
# List available templates
hammer --list

# Check templates directory
ls -la templates/
```

### Variables not replaced
- Ensure you're using `{{variable}}` syntax (not `${variable}`)
- Check that variable names match exactly
- Use `-v` flag to pass custom variables

### Permission issues
```bash
# Make generated scripts executable
chmod +x generated-project/*.sh

# Or in template, mark files as executable
chmod +x templates/mytemplate/script.sh
```

## Contributing

Contributions are welcome! Please feel free to submit:
- New templates
- Bug fixes
- Feature improvements
- Documentation updates

## License

MIT License - see LICENSE file for details

## Related Projects

- **arty.sh** - Bash library repository manager (template included)
- **judge.sh** - Bash testing framework (example project)

## Credits

Created to make bash project scaffolding fast and easy!

---

Happy hammering! 🔨
