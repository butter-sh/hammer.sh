# init.sh

> 🚀 Comprehensive arty.sh Project Initialization System

A powerful project scaffolding tool that creates fully-configured arty.sh projects with templates, testing frameworks, documentation, and more!

## 🌟 Features

- **Multiple Templates** - Basic, CLI, Library, and Web service templates
- **Interactive Mode** - Guided project creation with prompts
- **Git Integration** - Automatic repository initialization
- **Dependency Management** - Auto-install arty.sh dependencies
- **Testing Framework** - Built-in test runner with assertions
- **Documentation Ready** - Pre-configured for leaf.sh docs generation
- **Beautiful CLI** - Colorful output with emojis and formatting
- **Smart Defaults** - Sensible configurations out of the box

## 📦 Installation

### Using hammer.sh

```bash
# Generate init.sh from template
hammer init my-init-tool

# Or install globally
cd my-init-tool
chmod +x init.sh
sudo ln -s "$(pwd)/init.sh" /usr/local/bin/init
```

### Manual Installation

```bash
git clone https://github.com/butter-sh/init.sh.git
cd init.sh
chmod +x init.sh
./init.sh --help
```

## 🚀 Quick Start

### Basic Usage

```bash
# Create a new project with default template
init.sh my-project

# Use specific template
init.sh --template cli my-cli-tool

# Interactive mode
init.sh --interactive
```

### Project Templates

#### 1. Basic Template (default)
Minimal project structure for general bash scripting:
```bash
init.sh my-project
```

#### 2. CLI Template
Command-line tool with argument parsing:
```bash
init.sh --template cli awesome-cli
```

#### 3. Library Template
Reusable bash library/module:
```bash
init.sh --template lib bash-utils
```

#### 4. Web Template
Web service with routes and middleware:
```bash
init.sh --template web api-server
```

## 🎯 Usage Examples

### Standard Project Creation

```bash
# Create project in current directory
init.sh my-app

# Create in specific directory
init.sh --dir ~/projects my-app

# Skip git initialization
init.sh --skip-git my-app

# Skip dependency installation
init.sh --skip-deps my-app
```

### Interactive Mode

```bash
# Launch interactive wizard
init.sh --interactive

# Follow the prompts:
# - Project name
# - Template selection
# - Target directory
# - Git initialization
# - Dependency installation
```

### Advanced Options

```bash
# Combine options
init.sh \
  --template cli \
  --dir ~/workspace \
  --skip-git \
  my-awesome-tool

# Verbose output for debugging
init.sh --verbose my-project
```

## 📋 Generated Project Structure

When you create a new project, init.sh generates:

```
my-project/
├── arty.yml              # Project configuration
├── README.md             # Comprehensive documentation
├── LICENSE               # MIT license
├── .gitignore            # Git ignore rules
├── index.sh              # Main entry point (executable)
│
├── src/                  # Source code
├── lib/                  # Libraries/modules
├── examples/             # Example scripts
├── tests/                # Test files
│   ├── run-tests.sh      # Test runner
│   └── example_test.sh   # Example tests
├── docs/                 # Documentation (generated)
│
└── .arty/                # arty.sh workspace
    ├── bin/              # Linked executables
    └── libs/             # Installed dependencies
```

## 🔧 Configuration

### arty.yml

Every generated project includes a comprehensive `arty.yml`:

```yaml
name: "my-project"
version: "0.1.0"
description: "A new arty.sh project"
author: "Your Name"
license: "MIT"

type: "basic"  # or cli, lib, web

references:
  # Your dependencies here

main: "index.sh"

scripts:
  start: "bash index.sh"
  test: "bash tests/run-tests.sh"
  build: "bash scripts/build.sh"
  docs: "leaf.sh . -o docs"
  clean: "rm -rf build/ dist/"

env:
  DEBUG: "0"
  LOG_LEVEL: "info"
```

### Main Script

The generated `index.sh` includes:

- Configuration loading from arty.yml
- Colored logging functions
- Argument parsing
- Help/version commands
- Template-specific functionality

## 🧪 Testing Framework

Every project includes a built-in testing framework:

### Writing Tests

Create test files in `tests/` directory:

```bash
#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/run-tests.sh"

# Test cases
assert_equals "hello" "hello"
assert_contains "hello world" "world"
```

### Running Tests

```bash
# Run all tests
cd my-project
bash tests/run-tests.sh

# Or use arty
arty test
```

### Available Assertions

- `assert_equals <actual> <expected>` - Test equality
- `assert_contains <string> <substring>` - Test string contains

## 📚 Documentation

Generate beautiful documentation with leaf.sh:

```bash
# Generate docs
arty docs

# Or manually
leaf.sh . -o docs

# Open in browser
open docs/index.html
```

## 🎨 Template Customization

### Creating Custom Templates

You can extend init.sh by modifying the template generation logic:

1. Edit `init.sh`
2. Add new template in `create_structure()`
3. Customize files in `generate_*()` functions
4. Add template to help text

### Template-Specific Features

Each template generates unique structures:

**CLI Template:**
- Command directory structure
- Argument parsing framework
- Subcommand support

**Library Template:**
- Module organization
- Export functions
- Usage examples

**Web Template:**
- Route handlers
- Middleware support
- Public assets directory

## 🔗 Integration

### With arty.sh

```bash
# Install init.sh as dependency
arty install https://github.com/butter-sh/init.sh.git

# Use it
arty exec init my-new-project
```

### With hammer.sh

```bash
# Generate init.sh from template
hammer init my-custom-init

# Customize and use
cd my-custom-init
./init.sh new-project
```

### With leaf.sh

```bash
# Generate docs for any init-generated project
cd my-project
leaf.sh .

# Or use arty script
arty docs
```

## 🎯 Command Reference

### Options

| Option | Description |
|--------|-------------|
| `-t, --template <name>` | Use template (basic/cli/lib/web) |
| `-d, --dir <path>` | Target directory |
| `--skip-git` | Skip git initialization |
| `--skip-deps` | Skip dependency installation |
| `--interactive` | Interactive mode |
| `-v, --verbose` | Verbose output |
| `-h, --help` | Show help |
| `--version` | Show version |

### Commands

All generated projects support these arty commands:

```bash
arty start      # Start the application
arty test       # Run tests
arty build      # Build the project
arty docs       # Generate documentation
arty clean      # Clean build artifacts
arty deps       # Install dependencies
```

## 🏗️ Development

### Requirements

- bash 4.0+
- git
- yq (YAML parser)

### Setup

```bash
# Clone repository
git clone https://github.com/butter-sh/init.sh.git
cd init.sh

# Make executable
chmod +x init.sh

# Test
./init.sh test-project
```

### Testing init.sh

```bash
# Create test project
./init.sh --template cli test-cli --skip-git

# Verify structure
cd test-cli
tree

# Test functionality
arty start
arty test
```

## 💡 Tips & Best Practices

### Project Naming

- Use lowercase with hyphens: `my-awesome-tool`
- Avoid special characters
- Keep names descriptive but concise

### Template Selection

- **basic**: General scripts, utilities, tools
- **cli**: Command-line applications with arguments
- **lib**: Reusable modules, shared code
- **web**: Services, APIs, web applications

### Git Workflow

```bash
# After creating project
cd my-project

# Create remote repository on GitHub
# Then add remote
git remote add origin https://github.com/user/my-project.git
git push -u origin main
```

### Dependency Management

```bash
# Add dependencies to arty.yml
references:
  - https://github.com/user/bash-utils.git

# Install
arty deps

# Use in your code
source .arty/libs/bash-utils/utils.sh
```

## 🤝 Contributing

Contributions welcome! Areas for improvement:

- Additional templates (python, node, etc.)
- More test assertions
- Configuration presets
- CI/CD integration
- Docker support

## 📄 License

MIT License - see LICENSE file

## 🔗 Related Projects

- [**hammer.sh**](https://github.com/butter-sh/hammer.sh) - Project generator
- [**arty.sh**](https://github.com/butter-sh/arty.sh) - Library manager
- [**leaf.sh**](https://github.com/butter-sh/leaf.sh) - Documentation generator
- [**judge.sh**](https://github.com/butter-sh/judge.sh) - Testing framework

## 🌟 Examples

### Creating a CLI Tool

```bash
# Initialize
init.sh --template cli git-helper

cd git-helper

# Structure created:
# ├── cmd/
# │   └── main.sh
# ├── internal/
# ├── examples/
# └── tests/

# Develop your tool
vim cmd/main.sh

# Test
arty test

# Generate docs
arty docs
```

### Creating a Library

```bash
# Initialize
init.sh --template lib string-utils

cd string-utils

# Structure created:
# ├── lib/
# │   └── index.sh
# ├── modules/
# ├── utils/
# └── examples/

# Add functions
vim lib/index.sh

# Add examples
vim examples/usage.sh

# Generate docs
arty docs
```

### Creating a Web Service

```bash
# Initialize
init.sh --template web api-server

cd api-server

# Structure created:
# ├── server.sh
# ├── routes/
# ├── middleware/
# └── public/

# Develop API
vim routes/api.sh

# Start server
arty start
```

## 📊 Comparison

| Feature | init.sh | create-bash-script | bash-template |
|---------|---------|-------------------|---------------|
| Templates | ✅ 4 types | ❌ 1 type | ✅ 2 types |
| Interactive | ✅ Yes | ❌ No | ⚠️ Basic |
| Testing | ✅ Built-in | ❌ None | ❌ None |
| Docs Gen | ✅ leaf.sh | ❌ None | ❌ None |
| Git Init | ✅ Yes | ✅ Yes | ✅ Yes |
| Dependencies | ✅ arty.sh | ❌ None | ❌ None |
| Colorful CLI | ✅ Yes | ⚠️ Basic | ❌ No |

## 🎓 Tutorial

### From Zero to Published Tool in 5 Minutes

```bash
# 1. Create project
init.sh --template cli my-tool

# 2. Enter directory
cd my-tool

# 3. Edit main script
vim cmd/main.sh
# Add your functionality

# 4. Test it
arty test

# 5. Generate docs
arty docs

# 6. Commit
git add .
git commit -m "Initial version"

# 7. Push to GitHub
git remote add origin https://github.com/user/my-tool.git
git push -u origin main

# 8. Share!
# Users can install with:
# arty install https://github.com/user/my-tool.git
```

## 🆘 Troubleshooting

### Dependencies Not Found

```bash
# Install yq
brew install yq  # macOS
# or
pip install yq   # Python
# or see: https://github.com/mikefarah/yq
```

### Permission Denied

```bash
# Make script executable
chmod +x init.sh
```

### Git Not Initialized

```bash
# Skip git with flag
init.sh --skip-git my-project

# Or initialize manually
cd my-project
git init
```

## 📮 Support

- **Issues**: https://github.com/butter-sh/init.sh/issues
- **Discussions**: https://github.com/butter-sh/init.sh/discussions
- **Email**: support@butter.sh

---

**Made with ❤️ by the butter.sh team**

Part of the butter.sh ecosystem - Modern bash development tools
