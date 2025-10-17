#!/usr/bin/env bash

# setup.sh - Setup hook for {{project_name}}
# This script runs when the tool is installed via arty

set -euo pipefail

echo "🔨 Setting up {{project_name}}..."

# Check for dependencies
if ! command -v yq &> /dev/null; then
    echo "⚠️  Warning: yq not found. Some features may not work."
    echo "   Install: https://github.com/mikefarah/yq#install"
fi

if ! command -v git &> /dev/null; then
    echo "⚠️  Warning: git not found. Git features will be disabled."
fi

# Make init.sh executable
chmod +x "$(dirname "$0")/init.sh"

echo "✓ Setup complete!"
echo "  Try: init.sh --help"
