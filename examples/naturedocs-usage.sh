#!/usr/bin/env bash

# Example: Using hammer.sh to generate a leaf project

# This example demonstrates how to use the leaf template
# to create a documentation site generator for your arty.sh projects

set -euo pipefail

echo "=== hammer.sh leaf template example ==="
echo

# 1. Generate a new leaf project
echo "1. Generating leaf project..."
cd /tmp
hammer leaf my-docs-generator

echo "✓ Project generated at: /tmp/my-docs-generator"
echo

# 2. Navigate to the project
cd my-docs-generator
echo "2. Project structure:"
tree -L 1 || ls -la

echo
echo "3. The leaf.sh script can now be used to generate documentation"
echo "   for any arty.sh project!"
echo

# 3. Demo: Generate docs for itself
echo "4. Testing the generator on itself..."
chmod +x leaf.sh
./leaf.sh .

echo
echo "✓ Documentation generated at: ./docs/index.html"
echo

# 4. Show the output
echo "5. To view the documentation, open in a browser:"
echo "   file:///tmp/my-docs-generator/docs/index.html"
echo

# 5. Use on another project
echo "6. Example: Generate docs for another project"
echo "   ./leaf.sh /path/to/arty-project"
echo

echo "=== Example complete! ==="
echo
echo "The leaf template creates a powerful documentation generator that:"
echo "  • Parses arty.yml for project metadata"
echo "  • Converts README.md to beautiful HTML"
echo "  • Includes all source files with syntax highlighting"
echo "  • Shows examples with proper formatting"
echo "  • Uses modern design with Tailwind CSS v4"
echo "  • Supports dark/light theme toggle"
echo "  • Works with any arty.sh project"
