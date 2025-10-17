# hammer.sh

> 🔨 A configurable bash project generator CLI that creates projects from templates

A powerful code generator that helps you quickly scaffold new bash projects from customizable templates. Part of the butter.sh ecosystem.

## 🌟 Features

- 🔨 Generate projects from templates
- 🎨 Variable substitution in templates
- 📦 Built-in templates (arty, starter, leaf, init, judge, icony, whip)
- 🔧 Fully configurable
- 🚀 Easy to extend with custom templates
- ⚡ Fast and lightweight
- 🎯 Smart overwrite handling

## 📦 Installation

```bash
git clone https://github.com/butter-sh/hammer.sh.git
cd hammer.sh
chmod +x hammer.sh

# Optional: Add to PATH
sudo ln -s "$(pwd)/hammer.sh" /usr/local/bin/hammer
```

### One-liner Install

```bash
curl -sSL https://raw.githubusercontent.com/butter-sh/hammer.sh/main/hammer.sh | sudo tee /usr/local/bin/hammer > /dev/null && sudo chmod +x /usr/local/bin/hammer
```

## 🚀 Quick Start

```bash
# List available templates
hammer --list

# Generate projects
hammer arty my-lib-manager        # Library manager
hammer starter my-project         # Basic project
hammer leaf my-docs-gen          # Documentation generator
hammer init project-initializer   # Project scaffolder
hammer icony my-icon-tool        # SVG icon manager
hammer judge test-framework      # Testing framework
hammer whip release-manager      # Release management (NEW!)

# With options
hammer starter my-app --dir ./projects
hammer arty my-lib -v author="John Doe" -v license=MIT --force
```

## 📖 Usage

```bash
hammer.sh <template> <project-name> [options]
```

### Options

| Option | Description |
|--------|-------------|
| `-d, --dir <path>` | Target directory (default: current) |
| `-v, --vars <key=value>` | Set template variables (repeatable) |
| `-f, --force` | Force overwrite without prompting |
| `-l, --list` | List available templates |
| `-h, --help` | Show help message |

### Examples

```bash
# Basic usage
hammer arty my-library

# Custom target directory
hammer starter my-project --dir ~/projects

# With variables
hammer starter my-app \
  -v author="Jane Smith" \
  -v email="jane@example.com" \
  -v license=Apache-2.0

# Force overwrite
hammer arty my-lib --force
```

## 📚 Built-in Templates

### 🎨 arty - Library Manager

Complete bash library repository management system with dependency management.

**Features:**
- Git-based library installation
- YAML-based configuration
- Dependency resolution
- Setup hooks
- Binary linking

```bash
hammer arty my-lib-manager
cd my-lib-manager
./arty.sh --help
```

### 🌱 starter - Project Skeleton

Basic bash project skeleton with arty.sh integration.

**Features:**
- Project structure
- Logging utilities
- Configuration support
- Git-ready

```bash
hammer starter my-project
cd my-project
./index.sh
```

### 🍃 leaf - Documentation Generator

Beautiful static HTML documentation generator for arty.sh projects.

**Features:**
- Responsive design with Tailwind CSS
- Syntax highlighting
- Dark/light theme
- Auto-parsing of project files
- Landing page generation

```bash
hammer leaf my-docs-generator
cd my-docs-generator
./leaf.sh /path/to/project
```

### 🚀 init - Project Initializer (NEW!)

Comprehensive project initialization system with templates and testing framework.

**Features:**
- Multiple templates (basic, cli, lib, web)
- Interactive mode with prompts
- Git integration
- Built-in test framework
- Auto-dependency installation
- Beautiful CLI with emojis

```bash
hammer init project-init-tool
cd project-init-tool
./init.sh --interactive

# Or direct usage
./init.sh my-new-project --template cli
```

**What it generates:**
- Complete project structure
- Test framework with assertions
- README with examples
- Git initialization
- arty.yml configuration
- LICENSE file

### 🎯 judge - Testing Framework

Bash testing framework with rich assertions and beautiful output.

**Features:**
- Assertion library
- Snapshot testing
- Colorful output
- CI/CD ready

```bash
hammer judge test-framework
cd test-framework
./judge.sh test examples/basic_test.sh
```

### 🎨 icony - Icon Manager

SVG icon management system for bash projects.

**Features:**
- Icon organization
- SVG optimization
- Asset management

```bash
hammer icony my-icon-manager
cd my-icon-manager
./icony.sh --help
```

### 🎯 whip - Release Manager (NEW!)

Complete release cycle management for arty.sh projects.

**Features:**
- Semantic versioning (major, minor, patch)
- Changelog generation from git history
- Git tag creation and pushing
- Commit hooks with bash validation (shellcheck, bash -n)
- Monorepo support with batch operations

```bash
hammer whip my-release-manager
cd my-release-manager
bash setup.sh

# Initialize git and create first release
git init
git add .
git commit -m "Initial commit"
./whip.sh release patch
```

**What it generates:**
- Complete release management tool (~600 lines)
- Pre-commit hooks with validation
- Changelog automation from git history
- Monorepo batch operations support
- Full arty.yml integration
- Version management with yq

## 🎯 Template Variables

Templates support variable substitution using `{{variable}}` syntax:

### Built-in Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{project_name}}` | Project name | my-project |
| `{{year}}` | Current year | 2025 |
| `{{date}}` | Current date | 2025-10-17 |

### Custom Variables

Pass custom variables with `-v`:

```bash
hammer starter my-app \
  -v author="Your Name" \
  -v email="you@example.com" \
  -v license=MIT \
  -v description="My awesome project"
```

In templates:
```bash
# Author: {{author}}
# Email: {{email}}
# License: {{license}}
```

## 🛠️ Creating Custom Templates

### Template Structure

```
templates/
└── mytemplate/
    ├── .template          # Metadata
    ├── README.md          
    ├── main.sh
    └── config.yml
```

### Metadata File (.template)

```bash
description="My custom template"
version="1.0.0"
organization_name="my-org"
```

### Using Variables

```bash
#!/usr/bin/env bash
# {{project_name}} - Version {{version}}
# Author: {{author}}

echo "Hello from {{project_name}}!"
```

### Example: Web App Template

```bash
# Create template directory
mkdir -p templates/webapp

# Metadata
cat > templates/webapp/.template << 'EOF'
description="A web application template"
version="1.0.0"
EOF

# Template files
cat > templates/webapp/server.sh << 'EOF'
#!/usr/bin/env bash
# {{project_name}} Server

echo "Starting {{project_name}}..."
python3 -m http.server 8080
EOF

chmod +x templates/webapp/server.sh

# Use it
hammer webapp my-webapp
```

## 🔧 Advanced Features

### Batch Generation

```bash
# Generate multiple projects
for name in lib1 lib2 lib3; do
  hammer starter "$name" --dir ./projects
done
```

### Smart Overwrite Handling

When files exist, hammer.sh prompts:
- `y` - Overwrite this file
- `n` - Skip this file
- `a` - Overwrite all remaining
- `N` - Skip all remaining

Or use `--force` to overwrite all without prompting.

### Integration with arty.sh

Generated projects work seamlessly with arty:

```yaml
# arty.yml
name: "my-project"
version: "0.1.0"
references:
  - https://github.com/user/dependency.git
main: "index.sh"
```

Install dependencies:
```bash
cd my-project
arty deps
```

## 💡 Bash One-Liners & Aliases

### Hammer Shortcuts

```bash
# Add to ~/.bashrc or ~/.zshrc

# Basic hammer aliases
alias h='hammer'
alias hl='hammer --list'
alias ha='hammer arty'
alias hs='hammer starter'
alias hi='hammer init'
alias hj='hammer judge'
alias hlf='hammer leaf'

# Quick project creation and enter
hcd() { hammer "$1" "$2" && cd "$2"; }
# Example: hcd starter my-app

# Generate with timestamp
htime() { hammer "$1" "$2-$(date +%Y%m%d-%H%M%S)"; }
# Example: htime starter quick-test

# Generate with author from git
hme() {
  local author=$(git config user.name)
  local email=$(git config user.email)
  hammer "$1" "$2" -v author="$author" -v email="$email"
}
# Example: hme starter my-project
```

### Advanced Aliases

```bash
# Generate with full setup (git + deps)
hfull() {
  hammer "$1" "$2" &&
  cd "$2" &&
  git init &&
  git add . &&
  git commit -m "🔨 Generated with hammer.sh" &&
  command -v arty >/dev/null && arty deps &&
  echo "✅ Project ready: $(pwd)"
}

# Generate and open in editor
hedit() {
  hammer "$1" "$2" && code "$2"  # or vim, nano, etc.
}

# Generate multiple from list
hmulti() { 
  while read -r name; do 
    [[ -n "$name" ]] && hammer starter "$name" --dir ./batch
  done
}
# Usage: echo -e "proj1\nproj2\nproj3" | hmulti

# Backup before regenerate
hbackup() {
  local proj="$2"
  [[ -d "$proj" ]] && cp -r "$proj" "${proj}.backup.$(date +%s)"
  hammer "$1" "$2" --force
}

# Quick test generation (temporary)
htest() { 
  hammer "$1" "test-$1-$$" --dir /tmp
  cd "/tmp/test-$1-$$"
}

# Clean test projects
hclean() {
  find . -maxdepth 1 -type d -name "test-*" -exec rm -rf {} +
}

# Generate and show tree
htree() {
  hammer "$1" "$2" && tree "$2" -L 3 -a
}

# Interactive template selector (requires fzf)
hselect() {
  local template=$(hammer --list | grep '^\s\+' | awk '{print $1}' | fzf --prompt="Select template: ")
  if [[ -n "$template" ]]; then
    read -p "Project name: " name
    [[ -n "$name" ]] && hammer "$template" "$name"
  fi
}

# Generate project matrix (all templates)
hmatrix() {
  for template in arty starter leaf init judge icony whip; do
    hammer "$template" "demo-${template}" --dir ./demo-projects
  done
}
```

### Creative One-Liners

```bash
# Find and count all bash files in templates
alias hcount='find templates -name "*.sh" | wc -l'

# Show template statistics
alias hstats='for t in templates/*/; do echo "$(basename $t): $(find $t -type f | wc -l) files"; done'

# Search in templates
hsearch() { grep -r "$1" templates/ --include="*.sh" --color=always -n; }

# List all template variables
hvars() { grep -roh '{{[^}]*}}' "templates/$1" | sort -u; }

# Validate template syntax
hvalidate() {
  find "templates/$1" -name "*.sh" -exec bash -n {} \; 2>&1 | grep -v "No such file"
}

# Compare two templates
hcompare() {
  diff -r "templates/$1" "templates/$2" --color=always
}

# Generate from template file (CSV)
hfrom() {
  while IFS=, read -r template name; do
    [[ -n "$name" ]] && hammer "$template" "$name"
  done < "$1"
}
# Usage: Create projects.csv with: template,name

# Watch template directory and regenerate
hwatch() {
  while inotifywait -q -r templates/"$1" -e modify; do
    echo "🔄 Template changed, regenerating..."
    hammer "$1" "$2" --force
  done
}

# Generate with custom license
hlicense() {
  hammer "$1" "$2" -v license="$3"
  [[ -f "$2/LICENSE" ]] && cat > "$2/LICENSE" << EOF
$3 License

Copyright (c) $(date +%Y) $(git config user.name)
...
EOF
}

# Parallel generation (requires GNU parallel)
hparallel() {
  echo "$@" | tr ' ' '\n' | parallel -j4 "hammer starter {}"
}

# Generate and initialize with git flow
hflow() {
  hammer "$1" "$2" && cd "$2" &&
  git init &&
  git checkout -b develop &&
  git add . &&
  git commit -m "Initial commit" &&
  git checkout -b main &&
  git merge develop
}

# Generate with version
hver() {
  hammer "$1" "$2" -v version="$3"
}

# Create project with README template
hreadme() {
  hammer "$1" "$2" &&
  cat > "$2/README.md" << EOF
# $2

> Generated with hammer.sh at $(date)

## Description

Add your description here.

## Installation

\`\`\`bash
git clone https://github.com/yourusername/$2.git
\`\`\`

## Usage

\`\`\`bash
./$2.sh
\`\`\`
EOF
}
```

### Project Management Aliases

```bash
# List all generated projects
alias hprojects='find . -maxdepth 2 -name "arty.yml" -exec dirname {} \;'

# Update all projects
hupdate() {
  find . -maxdepth 2 -name "arty.yml" -exec dirname {} \; | while read dir; do
    echo "Updating $dir..."
    (cd "$dir" && git pull && arty deps)
  done
}

# Archive old projects
harchive() {
  local archive_dir="$HOME/hammer-archive/$(date +%Y-%m)"
  mkdir -p "$archive_dir"
  mv "$1" "$archive_dir/"
}

# Generate project with tags
htag() {
  hammer "$1" "$2" &&
  cd "$2" &&
  git init &&
  git add . &&
  git commit -m "Initial commit" &&
  git tag -a "v0.1.0" -m "Initial release"
}

# Show project info
hinfo() {
  [[ -f "$1/arty.yml" ]] && {
    echo "Name: $(yq eval '.name' $1/arty.yml)"
    echo "Version: $(yq eval '.version' $1/arty.yml)"
    echo "Description: $(yq eval '.description' $1/arty.yml)"
  }
}
```

### Integration Aliases

```bash
# Generate and deploy to GitHub
hgithub() {
  hammer "$1" "$2" &&
  cd "$2" &&
  git init &&
  git add . &&
  git commit -m "🔨 Generated with hammer.sh" &&
  gh repo create "$2" --public --source=. --push
}

# Generate and create Docker setup
hdocker() {
  hammer "$1" "$2" &&
  cat > "$2/Dockerfile" << 'EOF'
FROM bash:latest
COPY . /app
WORKDIR /app
CMD ["bash", "index.sh"]
EOF
}

# Generate with CI/CD
hci() {
  hammer "$1" "$2" &&
  mkdir -p "$2/.github/workflows" &&
  cat > "$2/.github/workflows/test.yml" << 'EOF'
name: Test
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: bash tests/run-tests.sh
EOF
}
```

## 📊 Comparison with Other Tools

| Feature | hammer.sh | Yeoman | Cookiecutter |
|---------|-----------|---------|--------------|
| Language | Bash | JavaScript | Python |
| Templates | 6+ built-in | npm packages | Git repos |
| Size | <10KB | >100MB | >50MB |
| Speed | ⚡ Fast | 🐌 Slow | 🐇 Medium |
| Dependencies | None | Node.js | Python |
| Bash-native | ✅ Yes | ❌ No | ❌ No |
| arty.sh Integration | ✅ Yes | ❌ No | ❌ No |
| Overwrite Control | ✅ Interactive | ⚠️ Basic | ⚠️ Basic |

## 🏗️ Development

### Requirements

- bash 4.0+
- git (optional, for templates)

### Setup

```bash
git clone https://github.com/butter-sh/hammer.sh.git
cd hammer.sh
chmod +x hammer.sh
./hammer.sh --help
```

### Testing

```bash
# Run test script
./test.sh

# Generate test projects
./hammer.sh starter test-proj
./hammer.sh arty test-arty
./hammer.sh init test-init
```

## 📁 Directory Structure

```
hammer.sh/
├── hammer.sh              # Main CLI
├── README.md              # This file
├── LICENSE                # MIT license
├── QUICKSTART.md          # Quick start guide
├── test.sh                # Test script
├── examples/              # Usage examples
│   ├── usage.sh
│   └── leaf-usage.sh
├── templates/             # Template library
│   ├── arty/              # Library manager
│   ├── starter/           # Project skeleton
│   ├── leaf/              # Docs generator
│   ├── init/              # Project initializer (NEW!)
│   ├── judge/             # Test framework
│   └── icony/             # Icon manager
└── .github/
    └── workflows/
        └── hammer.docs.yml
```

## 🤝 Contributing

Contributions welcome! Areas for improvement:

- New templates
- Better variable handling
- Template validation
- Documentation improvements
- Bug fixes

### Adding a Template

1. Create directory: `templates/mytemplate/`
2. Add `.template` metadata
3. Create template files with `{{variables}}`
4. Test: `hammer mytemplate test-project`
5. Submit PR!

## 📄 License

MIT License - see LICENSE file

## 🔗 Related Projects

Part of the **butter.sh** ecosystem:

- [**arty.sh**](https://github.com/butter-sh/arty.sh) - Library manager
- [**leaf.sh**](https://github.com/butter-sh/leaf.sh) - Documentation generator
- [**init.sh**](https://github.com/butter-sh/init.sh) - Project initializer
- [**judge.sh**](https://github.com/butter-sh/judge.sh) - Testing framework
- [**icony.sh**](https://github.com/butter-sh/icony.sh) - Icon manager
- [**whip.sh**](https://github.com/butter-sh/whip.sh) - Release manager (NEW!)

## 🎓 Resources

- [Documentation](https://hammer.sh/docs)
- [Templates Guide](https://hammer.sh/templates)
- [API Reference](https://hammer.sh/api)
- [Examples](./examples/)

## 🆘 Troubleshooting

### Template not found
```bash
hammer --list  # Check available templates
ls -la templates/  # Verify template exists
```

### Variables not replaced
```bash
# Use correct syntax: {{variable}} not ${variable}
# Check variable names match exactly
# Use -v flag for custom variables
```

### Permission denied
```bash
chmod +x hammer.sh
chmod +x templates/*/setup.sh
```

## 🌟 Examples

### Create CLI Tool

```bash
hammer init my-cli
cd my-cli
./init.sh awesome-cli --template cli
cd awesome-cli
arty start
```

### Create Library with Documentation

```bash
hammer arty my-awesome-lib
cd my-awesome-lib
# Add your library code
hammer leaf my-lib-docs
cd my-lib-docs
./leaf.sh ../
open docs/index.html
```

### Full Project Setup

```bash
# Generate, initialize git, install deps
hammer starter my-project
cd my-project
git init
git add .
git commit -m "Initial commit"
arty deps
arty start
```

---

**Made with ❤️ by the butter.sh team**

Happy hammering! 🔨✨
