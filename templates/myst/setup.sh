#!/usr/bin/env bash

# setup.sh - Setup script for {{project_name}}
set -euo pipefail

echo "Setting up {{project_name}}..."

# Check dependencies
command -v jq >/dev/null 2>&1 || { echo "Error: jq is required but not installed."; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "Warning: yq is not installed. YAML support will be limited."; }

# Make main script executable
chmod +x myst.sh

echo "✓ Setup complete!"
echo "Run './myst.sh --help' to get started"
