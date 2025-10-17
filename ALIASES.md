# 🎨 Hammer.sh - Creative Bash Aliases & One-Liners

> A collection of creative, powerful, and fun bash aliases for hammer.sh

## 📚 Table of Contents

- [Basic Shortcuts](#basic-shortcuts)
- [Project Creation](#project-creation)
- [Advanced Operations](#advanced-operations)
- [Integration Helpers](#integration-helpers)
- [Development Tools](#development-tools)
- [Fun & Creative](#fun--creative)

## 🎯 Basic Shortcuts

```bash
# Essential aliases
alias h='hammer'
alias hl='hammer --list'
alias ha='hammer arty'
alias hs='hammer starter'
alias hi='hammer init'
alias hj='hammer judge'
alias hlf='hammer leaf'
alias hic='hammer icony'

# Help shortcuts
alias hh='hammer --help'
alias hv='hammer --version'

# Quick list with colors
alias hls='hammer --list | grep -E "^\s+" --color=always'
```

## 🚀 Project Creation

### Quick Create and Navigate

```bash
# Create and cd into project
hcd() { hammer "$1" "$2" && cd "$2"; }

# Create with timestamp
htime() { hammer "$1" "$2-$(date +%Y%m%d-%H%M%S)"; }

# Create with date suffix
hdate() { hammer "$1" "$2-$(date +%Y-%m-%d)"; }

# Create with random suffix
hrand() { hammer "$1" "$2-$(openssl rand -hex 4)"; }
```

### Templates with Auto-configuration

```bash
# Generate with git config author
hme() {
  local author=$(git config user.name 2>/dev/null || echo "Unknown")
  local email=$(git config user.email 2>/dev/null || echo "unknown@example.com")
  hammer "$1" "$2" \
    -v author="$author" \
    -v email="$email"
}

# Generate with custom description
hdesc() {
  read -p "Project description: " desc
  hammer "$1" "$2" -v description="$desc"
}

# Generate with version
hver() {
  hammer "$1" "$2" -v version="${3:-0.1.0}"
}

# Generate with license selection
hlic() {
  echo "Select license: 1) MIT 2) Apache-2.0 3) GPL-3.0 4) BSD-3"
  read -p "Choice: " choice
  case $choice in
    1) license="MIT" ;;
    2) license="Apache-2.0" ;;
    3) license="GPL-3.0" ;;
    4) license="BSD-3-Clause" ;;
    *) license="MIT" ;;
  esac
  hammer "$1" "$2" -v license="$license"
}
```

### Batch Operations

```bash
# Generate multiple projects
hmulti() {
  while read -r name; do
    [[ -n "$name" ]] && hammer "${1:-starter}" "$name" --dir "${2:-.}"
  done
}
# Usage: echo -e "proj1\nproj2\nproj3" | hmulti starter ./projects

# Generate from CSV file
hcsv() {
  while IFS=, read -r template name author; do
    [[ -n "$name" ]] && hammer "$template" "$name" -v author="$author"
  done < "$1"
}
# CSV format: template,name,author

# Generate project matrix
hmatrix() {
  local templates=(arty starter leaf init judge icony)
  local suffixes=(dev staging prod)
  for t in "${templates[@]}"; do
    for s in "${suffixes[@]}"; do
      hammer "$t" "${2:-demo}-${t}-${s}" --dir "${1:-./matrix}"
    done
  done
}

# Parallel generation (requires GNU parallel)
hpara() {
  echo "$@" | tr ' ' '\n' | parallel -j4 "hammer ${1:-starter} {}"
}
```

## 🔧 Advanced Operations

### Smart Regeneration

```bash
# Backup and regenerate
hbackup() {
  local proj="$2"
  if [[ -d "$proj" ]]; then
    local backup="${proj}.backup.$(date +%s)"
    echo "📦 Backing up to $backup"
    cp -r "$proj" "$backup"
  fi
  hammer "$1" "$2" --force
}

# Regenerate with confirmation
hregen() {
  [[ -d "$2" ]] && {
    read -p "⚠️  Directory exists. Regenerate? [y/N]: " confirm
    [[ ! "$confirm" =~ ^[Yy] ]] && return 1
  }
  hammer "$1" "$2" --force
}

# Safe regenerate (keeps custom files)
hsafe() {
  local proj="$2"
  local temp="/tmp/hammer-safe-$$"
  
  # Backup custom files
  [[ -d "$proj" ]] && {
    mkdir -p "$temp"
    [[ -f "$proj/.gitignore" ]] && cp "$proj/.gitignore" "$temp/"
    [[ -f "$proj/custom.sh" ]] && cp "$proj/custom.sh" "$temp/"
  }
  
  # Regenerate
  hammer "$1" "$proj" --force
  
  # Restore custom files
  [[ -d "$temp" ]] && {
    cp -r "$temp"/* "$proj/"
    rm -rf "$temp"
  }
}
```

### Version Control Integration

```bash
# Generate and initialize git
hgit() {
  hammer "$1" "$2" &&
  cd "$2" &&
  git init &&
  git add . &&
  git commit -m "🔨 Initial commit via hammer.sh"
}

# Generate with git flow
hflow() {
  hammer "$1" "$2" && cd "$2" &&
  git init &&
  git checkout -b develop &&
  git add . &&
  git commit -m "Initial commit" &&
  git checkout -b main &&
  git merge develop &&
  git checkout develop
}

# Generate and tag
htag() {
  hammer "$1" "$2" && cd "$2" &&
  git init &&
  git add . &&
  git commit -m "Initial release" &&
  git tag -a "v${3:-0.1.0}" -m "Version ${3:-0.1.0}"
}

# Generate and create GitHub repo (requires gh CLI)
hgithub() {
  hammer "$1" "$2" && cd "$2" &&
  git init &&
  git add . &&
  git commit -m "🔨 Generated with hammer.sh" &&
  gh repo create "$2" --public --source=. --push
}

# Generate with conventional commits
hconv() {
  hammer "$1" "$2" && cd "$2" &&
  git init &&
  git add . &&
  git commit -m "feat: initial project setup with hammer.sh"
}
```

### Testing & Quality

```bash
# Generate and run tests
htest() {
  hammer "$1" "$2" && cd "$2" &&
  [[ -f "tests/run-tests.sh" ]] && bash tests/run-tests.sh
}

# Generate with linting
hlint() {
  hammer "$1" "$2" && cd "$2" &&
  find . -name "*.sh" -exec shellcheck {} \;
}

# Generate and validate
hcheck() {
  hammer "$1" "$2" && {
    echo "🔍 Validating generated files..."
    find "$2" -name "*.sh" -exec bash -n {} \; 2>&1
    echo "✓ Syntax check complete"
  }
}

# Generate temporary test project
htemp() {
  local tmp_proj="/tmp/hammer-test-$1-$$"
  hammer "$1" "$tmp_proj" --skip-git
  cd "$tmp_proj"
  echo "📁 Temporary project: $tmp_proj"
  echo "💡 Will be cleaned on logout"
}
```

## 🔗 Integration Helpers

### Full Stack Setup

```bash
# Full setup: generate, git, deps, docs
hfull() {
  hammer "$1" "$2" &&
  cd "$2" &&
  echo "🔧 Initializing git..." &&
  git init &&
  git add . &&
  git commit -m "🔨 Generated with hammer.sh" &&
  echo "📦 Installing dependencies..." &&
  command -v arty >/dev/null && arty deps &&
  echo "📚 Generating documentation..." &&
  command -v leaf >/dev/null && leaf . &&
  echo "✅ Project ready: $(pwd)"
}

# Generate with Docker setup
hdocker() {
  hammer "$1" "$2" && cd "$2" &&
  cat > Dockerfile << 'EOF'
FROM bash:latest
WORKDIR /app
COPY . .
RUN chmod +x *.sh
CMD ["bash", "index.sh"]
EOF
  cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
EOF
  echo "🐳 Docker files created"
}

# Generate with CI/CD
hci() {
  hammer "$1" "$2" && cd "$2" &&
  mkdir -p .github/workflows &&
  cat > .github/workflows/test.yml << 'EOF'
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: |
          sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
          sudo chmod +x /usr/local/bin/yq
      - name: Run tests
        run: bash tests/run-tests.sh
      - name: Lint
        run: find . -name "*.sh" -exec shellcheck {} \;
EOF
  echo "🔄 CI/CD workflow created"
}

# Generate with VS Code setup
hvscode() {
  hammer "$1" "$2" && cd "$2" &&
  mkdir -p .vscode &&
  cat > .vscode/settings.json << 'EOF'
{
  "files.associations": {
    "*.sh": "shellscript"
  },
  "shellcheck.enable": true,
  "editor.formatOnSave": true
}
EOF
  cat > .vscode/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run",
      "type": "shell",
      "command": "bash index.sh",
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
EOF
  echo "📝 VS Code config created"
}
```

### Editor Integration

```bash
# Generate and open in editor
hedit() {
  hammer "$1" "$2" && code "$2"  # VS Code
}

hvim() {
  hammer "$1" "$2" && vim "$2/index.sh"
}

hemacs() {
  hammer "$1" "$2" && emacs "$2/index.sh" &
}

# Generate and open README
hreadme() {
  hammer "$1" "$2" && ${EDITOR:-vim} "$2/README.md"
}
```

## 🛠️ Development Tools

### Template Development

```bash
# Search in templates
hsearch() {
  grep -r "$1" templates/ --include="*.sh" --color=always -n
}

# Find template variables
hvars() {
  [[ -z "$1" ]] && echo "Usage: hvars <template>" && return 1
  grep -roh '{{[^}]*}}' "templates/$1" 2>/dev/null | sort -u
}

# Validate template syntax
hvalidate() {
  echo "🔍 Validating template: $1"
  find "templates/$1" -name "*.sh" -exec bash -n {} \; 2>&1
}

# Compare templates
hcompare() {
  diff -r "templates/$1" "templates/$2" --color=always | less -R
}

# Count template files
hcount() {
  [[ -n "$1" ]] && dir="templates/$1" || dir="templates"
  find "$dir" -type f | wc -l
}

# Template statistics
hstats() {
  echo "📊 Template Statistics:"
  echo
  for t in templates/*/; do
    local name=$(basename "$t")
    local files=$(find "$t" -type f | wc -l)
    local lines=$(find "$t" -name "*.sh" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
    printf "  %-15s %3d files, %5d lines\n" "$name:" "$files" "$lines"
  done
}

# Show template structure
htree() {
  tree "templates/$1" -L 3 -a --dirsfirst
}

# Extract template info
hinfo() {
  local template="$1"
  [[ -f "templates/$template/.template" ]] && {
    echo "📄 Template: $template"
    cat "templates/$template/.template"
  }
}
```

### Project Management

```bash
# List all hammer projects
hprojects() {
  find . -maxdepth 2 -name "arty.yml" -exec dirname {} \; | sort
}

# Show project info
hpinfo() {
  [[ ! -f "$1/arty.yml" ]] && echo "Not a project directory" && return 1
  echo "📦 Project: $1"
  yq eval '.' "$1/arty.yml"
}

# Update all projects
hupdate() {
  hprojects | while read dir; do
    echo "📦 Updating $dir..."
    (cd "$dir" && git pull && arty deps) || echo "⚠️  Failed: $dir"
  done
}

# Archive old projects
harchive() {
  local archive_dir="$HOME/hammer-archive/$(date +%Y-%m)"
  mkdir -p "$archive_dir"
  echo "📦 Archiving $1 to $archive_dir"
  mv "$1" "$archive_dir/"
}

# Clean test projects
hclean() {
  echo "🧹 Cleaning test projects..."
  find . -maxdepth 1 -type d -name "test-*" -exec rm -rf {} +
  find /tmp -maxdepth 1 -name "hammer-*" -mtime +1 -exec rm -rf {} +
  echo "✓ Cleanup complete"
}
```

### Documentation Helpers

```bash
# Generate project and docs
hdocs() {
  hammer "$1" "$2" && cd "$2" &&
  command -v leaf >/dev/null && {
    leaf . -o docs &&
    echo "📚 Documentation generated at docs/index.html"
  }
}

# Generate README with template
hreadme_full() {
  hammer "$1" "$2" &&
  cat > "$2/README.md" << EOF
# $2

> Generated with hammer.sh on $(date +%Y-%m-%d)

## 📖 Description

Add your project description here.

## 🚀 Quick Start

\`\`\`bash
# Install dependencies
arty deps

# Run the project
arty start
\`\`\`

## 📦 Installation

\`\`\`bash
git clone https://github.com/$(git config user.name)/$2.git
cd $2
\`\`\`

## 🔧 Usage

\`\`\`bash
./index.sh --help
\`\`\`

## 🧪 Testing

\`\`\`bash
arty test
\`\`\`

## 📄 License

MIT License - Copyright $(date +%Y) $(git config user.name)

## 🤝 Contributing

Contributions welcome! Please read CONTRIBUTING.md first.

---

Generated with [hammer.sh](https://github.com/butter-sh/hammer.sh)
EOF
}
```

## 🎨 Fun & Creative

### Themed Generation

```bash
# Space theme
hspace() {
  local names=(apollo gemini mercury skylab voyager)
  local name="${names[$RANDOM % ${#names[@]}]}"
  hammer "$1" "$name-$2"
}

# Greek gods theme
hgod() {
  local gods=(zeus apollo athena artemis poseidon hades)
  local god="${gods[$RANDOM % ${#gods[@]}]}"
  hammer "$1" "$god-$2"
}

# Color theme
hcolor() {
  local colors=(red blue green yellow purple orange)
  local color="${colors[$RANDOM % ${#colors[@]}]}"
  hammer "$1" "$color-$2"
}

# Animal theme
hanimal() {
  local animals=(tiger lion bear wolf eagle shark)
  local animal="${animals[$RANDOM % ${#animals[@]}]}"
  hammer "$1" "$animal-$2"
}
```

### Interactive Tools

```bash
# Interactive template selector (requires fzf)
hselect() {
  local template=$(hammer --list | grep '^\s\+' | awk '{print $1}' | fzf --prompt="Select template: ")
  if [[ -n "$template" ]]; then
    read -p "Project name: " name
    [[ -n "$name" ]] && hammer "$template" "$name"
  fi
}

# Interactive multi-option selector
hwizard() {
  echo "🧙 Hammer Wizard"
  echo
  
  # Select template
  local templates=(arty starter leaf init judge icony)
  echo "Select template:"
  select template in "${templates[@]}"; do
    [[ -n "$template" ]] && break
  done
  
  # Project name
  read -p "Project name: " name
  [[ -z "$name" ]] && echo "❌ Name required" && return 1
  
  # Directory
  read -p "Directory [.]: " dir
  dir="${dir:-.}"
  
  # Author
  read -p "Author [$(git config user.name)]: " author
  author="${author:-$(git config user.name)}"
  
  # Generate
  hammer "$template" "$name" -d "$dir" -v author="$author"
}

# Project idea generator
hidea() {
  local adjectives=(awesome cool super mega ultra)
  local nouns=(tool app lib service manager)
  local adj="${adjectives[$RANDOM % ${#adjectives[@]}]}"
  local noun="${nouns[$RANDOM % ${#nouns[@]}]}"
  echo "💡 How about: $adj-$noun?"
}
```

### Performance & Monitoring

```bash
# Time generation
htime_gen() {
  echo "⏱️  Timing generation..."
  time hammer "$1" "$2"
}

# Watch file changes
hwatch() {
  watch -n 2 "ls -lh $1/"
}

# Monitor project size
hsize() {
  du -sh "$1" 2>/dev/null || echo "Project not found"
}

# Show generation rate
hrate() {
  local start=$(date +%s)
  hammer "$1" "$2"
  local end=$(date +%s)
  local duration=$((end - start))
  echo "⚡ Generated in ${duration}s"
}
```

### Utility Functions

```bash
# Copy project to new location
hcopy() {
  [[ ! -d "$1" ]] && echo "Source not found" && return 1
  cp -r "$1" "$2"
  echo "📋 Copied $1 → $2"
}

# Move project
hmove() {
  [[ ! -d "$1" ]] && echo "Source not found" && return 1
  mv "$1" "$2"
  echo "➡️  Moved $1 → $2"
}

# Show project dependencies
hdeps() {
  [[ -f "$1/arty.yml" ]] && {
    echo "📦 Dependencies for $1:"
    yq eval '.references[]' "$1/arty.yml" 2>/dev/null
  }
}

# Create project shortcut
hlink() {
  [[ ! -d "$1" ]] && echo "Project not found" && return 1
  ln -s "$(pwd)/$1" ~/projects/$(basename "$1")
  echo "🔗 Created link in ~/projects/"
}
```

### Experimental & Advanced

```bash
# Generate with AI description (requires ollama)
hai() {
  local desc=$(echo "Generate a one-line description for a project called $2" | ollama run llama2 --format plain 2>/dev/null)
  hammer "$1" "$2" -v description="$desc"
}

# Generate from template string
hfrom_str() {
  local template="$1"
  shift
  local projects=("$@")
  for proj in "${projects[@]}"; do
    hammer "$template" "$proj"
  done
}

# Generate with auto-naming
hauto() {
  local num=1
  while [[ -d "$2-$num" ]]; do
    ((num++))
  done
  hammer "$1" "$2-$num"
}

# Generate with semantic versioning
hsem() {
  local version="${3:-0.1.0}"
  hammer "$1" "$2" -v version="$version"
  [[ -d "$2" ]] && echo "$version" > "$2/.version"
}
```

## 📝 Installation

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# Source hammer aliases
if [[ -f ~/hammer.sh/ALIASES.md ]]; then
  # Extract and source bash code blocks
  sed -n '/```bash/,/```/p' ~/hammer.sh/ALIASES.md | \
    grep -v '```' > ~/.hammer_aliases
  source ~/.hammer_aliases
fi
```

Or manually copy desired aliases to your shell config.

## 🎯 Pro Tips

1. **Combine aliases**: `hfull starter my-app` = generate + git + deps + docs
2. **Use fzf**: Install fzf for interactive template selection with `hselect`
3. **Customize**: Modify aliases to match your workflow
4. **Chain commands**: `hammer arty lib1 && hammer starter app1`
5. **Use tab completion**: Set up bash/zsh completion for hammer

## 🔗 Related

- [hammer.sh Documentation](../README.md)
- [Template Guide](../templates/)
- [Contributing](../CONTRIBUTING.md)

---

**Made with ❤️ by the butter.sh team**

Happy aliasing! 🎨✨
