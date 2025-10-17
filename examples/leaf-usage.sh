#!/usr/bin/env bash

# Example: Using leaf.sh for documentation and landing pages
# This demonstrates the dual functionality of leaf.sh

set -e

echo "=== leaf.sh Usage Examples ==="
echo

# Example 1: Generate documentation for current project
echo "Example 1: Generate documentation (default mode)"
echo "Command: ./leaf.sh"
echo "Result: Creates docs/index.html with full documentation"
echo

# Example 2: Generate documentation with custom logo
echo "Example 2: Documentation with custom logo"
echo "Command: ./leaf.sh --logo ./custom-icon.svg"
echo "Result: Uses custom SVG logo instead of auto-detected icon"
echo

# Example 3: Generate documentation with custom base path
echo "Example 3: Documentation with custom base path (for GitHub Pages)"
echo "Command: ./leaf.sh --base-path /my-project/"
echo "Result: All links use /my-project/ as base for subdirectory deployment"
echo

# Example 4: Complete documentation with all options
echo "Example 4: Full documentation configuration"
echo "Command:"
cat << 'EOF'
./leaf.sh /path/to/arty-project \
  --logo ./brand/icon.svg \
  --base-path /docs/ \
  --github https://github.com/my-org \
  -o ./public
EOF
echo "Result: Complete customized documentation site in ./public"
echo

# Example 5: Generate butter.sh landing page
echo "Example 5: Generate landing page"
echo "Command: ./leaf.sh --landing"
echo "Result: Creates docs/index.html with butter.sh landing page"
echo

# Example 6: Landing page with custom GitHub URL
echo "Example 6: Landing page with custom GitHub"
echo "Command: ./leaf.sh --landing --github https://github.com/acme-corp"
echo "Result: Landing page links to custom GitHub organization"
echo

# Example 7: Landing page with custom projects
echo "Example 7: Landing page with custom projects list"
echo "Command:"
cat << 'EOF'
./leaf.sh --landing --projects '[
  {
    "url": "https://hammer.sh",
    "label": "hammer.sh",
    "desc": "Configurable bash project generator",
    "class": "card-project"
  },
  {
    "url": "https://arty.sh",
    "label": "arty.sh",
    "desc": "Bash library repository manager",
    "class": "card-project"
  },
  {
    "url": "https://leaf.sh",
    "label": "leaf.sh",
    "desc": "Beautiful documentation generator",
    "class": "card-project"
  }
]'
EOF
echo "Result: Landing page displays custom project cards"
echo

# Example 8: Complete landing page setup
echo "Example 8: Complete butter.sh landing page"
echo "Command:"
cat << 'EOF'
./leaf.sh --landing \
  --logo ./butter.sh/_assets/brand/cube-carbon-light.svg \
  --github https://github.com/butter-sh \
  --base-path / \
  -o ./public
EOF
echo "Result: Full butter.sh landing page with branding"
echo

# Example 9: Real workflow - Generate and deploy to GitHub Pages
echo "Example 9: Complete workflow with GitHub Pages deployment"
echo "Commands:"
cat << 'EOF'
# Generate documentation
./leaf.sh --base-path /my-repo/ -o docs

# Commit and push
git add docs/
git commit -m "Update documentation"
git push origin main

# GitHub Pages will automatically serve from docs/ folder
# Access at: https://username.github.io/my-repo/
EOF
echo

# Example 10: Local testing
echo "Example 10: Generate and test locally"
echo "Commands:"
cat << 'EOF'
# Generate docs
./leaf.sh -o ./test-docs

# Open in browser (macOS)
open ./test-docs/index.html

# Open in browser (Linux)
xdg-open ./test-docs/index.html

# Open in browser (Windows)
start ./test-docs/index.html
EOF
echo

# Example 11: Multiple outputs
echo "Example 11: Generate both docs and landing page"
echo "Commands:"
cat << 'EOF'
# Generate project documentation
./leaf.sh . -o docs/project

# Generate organization landing page
./leaf.sh --landing -o docs/landing

# Project structure:
# docs/
# ├── project/
# │   └── index.html (project docs)
# └── landing/
#     └── index.html (landing page)
EOF
echo

# Example 12: Integration with CI/CD
echo "Example 12: Automated documentation in CI/CD"
echo "Example GitHub Actions workflow:"
cat << 'EOF'
name: Generate Documentation

on:
  push:
    branches: [main]

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Generate Documentation
        run: |
          chmod +x ./leaf.sh
          ./leaf.sh --base-path /${{ github.event.repository.name }}/ -o docs
      
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./docs
EOF
echo

echo "=== Additional Tips ==="
echo
echo "1. Always test locally before deploying"
echo "2. Use --base-path when deploying to subdirectories"
echo "3. Custom logos must be SVG format for best results"
echo "4. Landing page projects array must be valid JSON"
echo "5. Check browser console for any JavaScript errors"
echo "6. Both dark and light themes should be tested"
echo "7. Mobile responsiveness is built-in, but test on devices"
echo
echo "For more information, run: ./leaf.sh --help"
