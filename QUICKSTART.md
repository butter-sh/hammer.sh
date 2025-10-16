# Quick Start Guide

Get started with hammer.sh, arty.sh, and judge.sh in minutes!

## Installation

### 1. Clone the Repository

```bash
cd ~/Projects  # or your projects directory
git clone https://github.com/YOUR_USERNAME/hammer.sh.git
cd hammer.sh
```

### 2. Make Scripts Executable

```bash
chmod +x hammer.sh
chmod +x templates/arty/arty.sh
chmod +x templates/starter/index.sh
cd ../judge.sh
chmod +x judge.sh
chmod +x examples/basic_test.sh
```

### 3. Optional: Add to PATH

```bash
# Link hammer.sh
sudo ln -s "$(pwd)/hammer.sh" /usr/local/bin/hammer

# Test it
hammer --help
```

## Quick Examples

### Example 1: Generate a Library Manager

```bash
# Navigate to your projects directory
cd ~/Projects

# Generate arty.sh library manager
./hammer.sh/hammer.sh arty my-library-manager

# Navigate to the new project
cd my-library-manager

# Make executable
chmod +x arty.sh

# Test it
./arty.sh --help
```

### Example 2: Generate a Starter Project

```bash
# Generate a starter bash project
cd ~/Projects
./hammer.sh/hammer.sh starter my-awesome-project

# Navigate and test
cd my-awesome-project
chmod +x index.sh
./index.sh
```

### Example 3: Use judge.sh Testing Framework

```bash
# Navigate to judge.sh
cd ~/Projects/judge.sh

# Run example tests
./judge.sh test examples/basic_test.sh

# Create your own test
cat > my_test.sh << 'EOF'
#!/usr/bin/env bash
source ./judge.sh

describe "My Tests"

it "should pass" "
    assert_equals 'hello' 'hello'
"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_summary
fi
EOF

chmod +x my_test.sh
./judge.sh test my_test.sh
```

## Complete Workflow Example

Here's a complete workflow showing all components working together:

### 1. Create a New Library

```bash
cd ~/Projects

# Generate library project
./hammer.sh/hammer.sh starter my-utils

cd my-utils
chmod +x index.sh

# Add some utility functions
cat >> index.sh << 'EOF'

# Utility function
greet() {
    local name="$1"
    echo "Hello, $name!"
}

# Export function
export -f greet
EOF
```

### 2. Create Tests for Your Library

```bash
# Create test file
cat > my_utils_test.sh << 'EOF'
#!/usr/bin/env bash

# Source judge.sh (assuming it's installed)
source ~/Projects/judge.sh/judge.sh

# Source the library
source ./index.sh

describe "My Utils Tests"

it "should greet correctly" "
    result=$(greet 'World')
    assert_equals 'Hello, World!' \"$result\"
"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_summary
fi
EOF

chmod +x my_utils_test.sh

# Run tests
~/Projects/judge.sh/judge.sh test my_utils_test.sh
```

### 3. Publish to Git

```bash
# Initialize git repository
git init
git add .
git commit -m "Initial commit"

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/my-utils.git
git push -u origin main
```

### 4. Use Your Library in Another Project

```bash
cd ~/Projects

# Create a new project
./hammer.sh/hammer.sh arty my-app

cd my-app
chmod +x arty.sh

# Edit arty.yml to add your library as a reference
cat >> arty.yml << 'EOF'

references:
  - https://github.com/YOUR_USERNAME/my-utils.git
EOF

# Install dependencies
./arty.sh deps

# Use the library
cat > test_app.sh << 'EOF'
#!/usr/bin/env bash
source <(./arty.sh source my-utils)

greet "from my app"
EOF

chmod +x test_app.sh
./test_app.sh
```

## Common Use Cases

### Create Multiple Projects

```bash
# Generate multiple projects at once
for name in utils logger config; do
    ./hammer.sh/hammer.sh starter "bash-$name"
done
```

### Create a Library with Tests

```bash
# Create library
./hammer.sh/hammer.sh starter my-lib
cd my-lib

# Add judge.sh reference
echo "  - https://github.com/YOUR_USERNAME/judge.sh.git" >> arty.yml

# Create tests directory
mkdir tests

# Add test file
cat > tests/lib_test.sh << 'EOF'
#!/usr/bin/env bash
source <(arty source judge)

describe "Library Tests"
it "should work" "assert_true '1'"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_summary
fi
EOF
```

### Create a Project with Custom Variables

```bash
./hammer.sh/hammer.sh starter my-project \
    -v author="Jane Doe" \
    -v email="jane@example.com" \
    -v license="Apache-2.0" \
    --dir ./projects
```

## Tools Overview

### hammer.sh
- **Purpose**: Project generator
- **Command**: `hammer <template> <name> [options]`
- **Templates**: arty, starter (extensible)

### arty.sh
- **Purpose**: Library manager
- **Command**: `arty <command> [args]`
- **Key Commands**: install, deps, list, remove, init

### judge.sh
- **Purpose**: Testing framework
- **Command**: `judge test <file/dir>`
- **Features**: Assertions, colored output, summaries

## Next Steps

1. **Read the Documentation**
   - `hammer.sh/README.md` - Generator documentation
   - `judge.sh/README.md` - Testing framework guide

2. **Try the Examples**
   - Run `hammer.sh/examples/usage.sh`
   - Run `judge.sh/examples/basic_test.sh`

3. **Create Custom Templates**
   - Copy `hammer.sh/templates/starter` as a base
   - Modify files and add variables
   - Use with `hammer <your-template> <project>`

4. **Build Your Projects**
   - Use arty.sh to manage dependencies
   - Use judge.sh to write tests
   - Use hammer.sh to scaffold new projects

## Troubleshooting

### Scripts not executable
```bash
find . -name "*.sh" -type f -exec chmod +x {} \;
```

### Template not found
```bash
# List available templates
./hammer.sh/hammer.sh --list

# Check templates directory
ls -la hammer.sh/templates/
```

### arty.sh not sourcing libraries
```bash
# Make sure library is installed
arty list

# Install if missing
arty install https://github.com/user/library.git
```

### Tests not running
```bash
# Make sure judge.sh is sourced correctly
source /path/to/judge.sh

# Or use absolute path
~/Projects/judge.sh/judge.sh test my_test.sh
```

## Getting Help

- Check README files in each project directory
- Run commands with `--help` flag
- View examples in `examples/` directories

---

You're all set! Start building amazing bash projects! 🚀
