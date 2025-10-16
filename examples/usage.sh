#!/usr/bin/env bash

# Example usage of hammer.sh
# This script demonstrates how to use hammer.sh to generate projects

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAMMER_DIR="$(dirname "$SCRIPT_DIR")"
HAMMER="$HAMMER_DIR/hammer.sh"

echo "hammer.sh Usage Examples"
echo "========================"
echo

# Make sure hammer.sh is executable
chmod +x "$HAMMER"

# Example 1: List available templates
echo "1. List available templates:"
echo "   $ hammer --list"
echo
"$HAMMER" --list
echo

# Example 2: Show help
echo "2. Show help message:"
echo "   $ hammer --help"
echo
"$HAMMER" --help
echo

# Example 3: Generate an arty.sh project (commented out to avoid actual creation)
echo "3. Generate an arty.sh library manager:"
echo "   $ hammer arty my-library"
echo "   This will create: ./my-library/ with arty.sh and configuration"
echo

# Example 4: Generate a starter project
echo "4. Generate a starter project:"
echo "   $ hammer starter my-project"
echo "   This will create: ./my-project/ with basic bash setup"
echo

# Example 5: Generate with custom directory
echo "5. Generate in a custom directory:"
echo "   $ hammer starter my-app --dir ./projects"
echo "   This will create: ./projects/my-app/"
echo

# Example 6: Generate with variables
echo "6. Generate with custom variables:"
echo "   $ hammer starter my-app -v author=\"John Doe\" -v license=Apache-2.0"
echo "   Variables will be substituted in template files"
echo

# Example 7: Create a test project (uncomment to actually run)
echo "7. Example: Create a test project"
echo "   Uncomment the following lines in this script to try:"
echo ""
echo "   cd /tmp"
echo "   $HAMMER starter test-project"
echo "   cd test-project"
echo "   chmod +x index.sh"
echo "   ./index.sh"
echo

echo "========================"
echo "For more information, see README.md"
