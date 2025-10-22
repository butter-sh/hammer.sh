<div align="center">

<img src="./icon.svg" width="100" height="100" alt="hammer.sh">

# hammer.sh

**Project Scaffolding Tool**

[![Organization](https://img.shields.io/badge/org-butter--sh-4ade80?style=for-the-badge&logo=github&logoColor=white)](https://github.com/butter-sh)
[![License](https://img.shields.io/badge/license-MIT-86efac?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-22c55e?style=for-the-badge)](https://github.com/butter-sh/hammer.sh/releases)
[![butter.sh](https://img.shields.io/badge/butter.sh-hammer-4ade80?style=for-the-badge)](https://butter-sh.github.io)

*Intelligent project scaffolding with template-based generation and interactive configuration*

[Documentation](https://butter-sh.github.io/hammer.sh) • [GitHub](https://github.com/butter-sh/hammer.sh) • [butter.sh](https://github.com/butter-sh)

</div>

---

## Overview

hammer.sh is a powerful project scaffolding tool that generates complete projects from templates. Built on top of myst.sh templating engine, it provides both interactive and batch modes for creating well-structured projects with consistent layouts.

### Key Features

- **Template-Based Generation** — Create projects from reusable templates
- **Interactive Prompts** — Guided setup with user-friendly prompts
- **Batch Mode** — Non-interactive generation with `--yes` flag
- **Variable Substitution** — Dynamic content via myst.sh templating
- **Smart Overwrite Detection** — Prevents accidental file overwrites
- **Integration with myst.sh** — Leverages powerful templating features

---

## Installation

### Using arty.sh

```bash
arty install https://github.com/butter-sh/hammer.sh.git
arty exec hammer --help
```

### Manual Installation

```bash
git clone https://github.com/butter-sh/hammer.sh.git
cd hammer.sh
sudo cp hammer.sh /usr/local/bin/hammer
sudo chmod +x /usr/local/bin/hammer
```

---

## Usage

### Initialize a Project

```bash
# Interactive mode
hammer init my-project

# Batch mode (use defaults)
hammer init my-project --yes
```

### Generate from Template

```bash
# Use built-in template
hammer new bash-script my-script

# Use custom template directory
hammer new my-template output-dir --template-dir ~/templates

# List available templates
hammer list
```

### Options

```bash
-y, --yes              Non-interactive mode (use defaults)
-t, --template-dir DIR Custom template directory
-v, --var KEY=VALUE    Set template variable
-h, --help             Show help message
```

---

## Templates

### Template Structure

Templates are directories containing `.myst` files:

```
templates/
└── my-template/
    ├── template.yml       # Template configuration
    ├── {{name}}.sh.myst   # Template files
    ├── README.md.myst
    └── config/
        └── settings.yml.myst
```

### Template Configuration

**template.yml:**
```yaml
name: "my-template"
description: "A project template"
variables:
  - name: project_name
    prompt: "Enter project name:"
    default: "my-project"
  - name: author
    prompt: "Author name:"
    default: "Your Name"
  - name: license
    prompt: "License:"
    default: "MIT"
```

### Template Files

Files ending in `.myst` are processed through myst.sh:

**{{name}}.sh.myst:**
```bash
#!/usr/bin/env bash

# {{project_name}}
# Author: {{author}}
# License: {{license}}

echo "Hello from {{project_name}}!"
```

---

## Examples

### Example 1: Bash Script Template

```bash
# Create bash script project
hammer new bash-script awesome-tool

# Output:
# awesome-tool/
# ├── awesome-tool.sh
# ├── README.md
# └── LICENSE
```

### Example 2: Custom Template

**my-templates/webapp/template.yml:**
```yaml
name: "webapp"
description: "Web application template"
variables:
  - name: app_name
    prompt: "Application name:"
  - name: port
    prompt: "Port number:"
    default: "3000"
```

**my-templates/webapp/server.js.myst:**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello from {{app_name}}!');
});

app.listen({{port}}, () => {
  console.log('{{app_name}} running on port {{port}}');
});
```

**Usage:**
```bash
hammer new webapp my-app \
  --template-dir my-templates \
  --var app_name="My App" \
  --var port=8080
```

### Example 3: arty.yml Project

```bash
# Generate arty.sh-compatible project
hammer new arty my-library

# Creates:
# my-library/
# ├── arty.yml
# ├── my-library.sh
# ├── __tests/
# │   └── test-my-library.sh
# ├── README.md
# └── LICENSE
```

---

## Integration with arty.sh

Add hammer.sh to your project:

```yaml
name: "my-project"
version: "1.0.0"

references:
  - https://github.com/butter-sh/hammer.sh.git
  - https://github.com/butter-sh/myst.sh.git

hammer:
  templates:
    - name: "component"
      path: "templates/component"
    - name: "service"
      path: "templates/service"

scripts:
  new-component: "arty exec hammer new component"
  new-service: "arty exec hammer new service"
```

Then run:

```bash
arty deps            # Install hammer.sh and myst.sh
arty new-component   # Generate component
arty new-service     # Generate service
```

---

## Creating Custom Templates

### Step 1: Create Template Directory

```bash
mkdir -p my-templates/my-template
cd my-templates/my-template
```

### Step 2: Create Configuration

**template.yml:**
```yaml
name: "my-template"
description: "My custom template"
variables:
  - name: project_name
    prompt: "Project name:"
  - name: author
    prompt: "Your name:"
    default: "$USER"
```

### Step 3: Create Template Files

**README.md.myst:**
```markdown
# {{project_name}}

Created by {{author}}

## Installation

\`\`\`bash
git clone {{project_name}}.git
\`\`\`
```

### Step 4: Use Template

```bash
hammer new my-template output-dir \
  --template-dir my-templates
```

---

## Related Projects

Part of the [butter.sh](https://github.com/butter-sh) ecosystem:

- **[arty.sh](https://github.com/butter-sh/arty.sh)** — Dependency manager
- **[judge.sh](https://github.com/butter-sh/judge.sh)** — Testing framework
- **[myst.sh](https://github.com/butter-sh/myst.sh)** — Templating engine (powers hammer.sh)
- **[leaf.sh](https://github.com/butter-sh/leaf.sh)** — Documentation generator
- **[whip.sh](https://github.com/butter-sh/whip.sh)** — Release management
- **[clean.sh](https://github.com/butter-sh/clean.sh)** — Linter and formatter

---

## License

MIT License — see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<div align="center">

**Part of the [butter.sh](https://github.com/butter-sh) ecosystem**

*Unlimited. Independent. Fresh.*

Crafted by [Valknar](https://github.com/valknarogg)

</div>
