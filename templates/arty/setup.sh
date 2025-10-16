#!/usr/bin/env bash

# setup.sh - Setup hook for {{project_name}}
# This script runs automatically when the library is installed via arty

set -euo pipefail

echo "Setting up {{project_name}}..."

# Create any necessary directories
mkdir -p "$HOME/.arty/libs/{{project_name}}"

# Run any initialization tasks
# For example:
# - Compile dependencies
# - Set up configuration files
# - Download additional resources

echo "Setup complete!"
