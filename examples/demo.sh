#!/usr/bin/env bash

# Example usage script for hammer.sh
# Demonstrates different ways to use hammer.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HAMMER="${SCRIPT_DIR}/../hammer.sh"

echo "=== hammer.sh Usage Examples ==="
echo ""

# Example 1: List templates
echo "Example 1: Listing available templates"
echo "Command: hammer --list"
echo ""
"$HAMMER" --list
echo ""

# Example 2: Interactive mode (commented out as it requires user input)
# echo "Example 2: Interactive mode"
# echo "Command: hammer example-template ./output-interactive"
# "$HAMMER" example-template ./output-interactive

# Example 3: With CLI variables
echo "Example 3: Using CLI variables"
echo "Command: hammer example-template -v project_name='CLIProject' -v author='John Doe' -o ./output-cli --yes"
"$HAMMER" example-template \
  -v project_name="CLIProject" \
  -v author="John Doe" \
  -o ./output-cli \
  --yes \
  --force
echo ""

# Example 4: With JSON file
echo "Example 4: Using JSON data file"
echo "Command: hammer example-template -j example-data.json -o ./output-json --yes"
"$HAMMER" example-template \
  -j "${SCRIPT_DIR}/example-data.json" \
  -o ./output-json \
  --yes \
  --force
echo ""

# Example 5: With YAML file
echo "Example 5: Using YAML data file"
echo "Command: hammer example-template -y example-data.yaml -o ./output-yaml --yes"
if command -v yq &> /dev/null; then
    "$HAMMER" example-template \
      -y "${SCRIPT_DIR}/example-data.yaml" \
      -o ./output-yaml \
      --yes \
      --force
else
    echo "Skipped: yq not installed"
fi
echo ""

# Example 6: Combining options
echo "Example 6: Combining JSON file with CLI override"
echo "Command: hammer example-template -j example-data.json -v author='Override Author' -o ./output-combined --yes"
"$HAMMER" example-template \
  -j "${SCRIPT_DIR}/example-data.json" \
  -v author="Override Author" \
  -o ./output-combined \
  --yes \
  --force
echo ""

echo "=== Examples Complete ==="
echo ""
echo "Generated outputs:"
ls -la ./output-* 2>/dev/null || echo "  (none - check if directories were created)"
